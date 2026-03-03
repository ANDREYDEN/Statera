import * as admin from 'firebase-admin'
import 'firebase-functions'
import * as functionsV1 from 'firebase-functions/v1'
import {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentWritten,
} from 'firebase-functions/v2/firestore'
import { onCall } from 'firebase-functions/v2/https'
import { analyzeReceipt } from './src/functions/analyzeReceipt'
import { deleteRelatedGroupData } from './src/functions/deleteRelatedGroupData'
import { updateUserExpenses } from './src/functions/docSync/updateUserExpenses'
import { updateUserGroupsWhenExpenseChanges } from './src/functions/docSync/updateUserGroupsWhenExpenseChanges'
import { updateUserGroupsWhenGroupChanges } from './src/functions/docSync/updateUserGroupsWhenGroupChanges'
import { getLatestRelease } from './src/functions/getLatestRelease'
import { notifyWhenExpenseCreated } from './src/functions/notifications/notifyWhenExpenseCreated'
import { notifyWhenExpenseUpdated } from './src/functions/notifications/notifyWhenExpenseUpdated'
import { notifyWhenGroupDebtThresholdReached } from './src/functions/notifications/notifyWhenGroupDebtThresholdReached'
import { removeUserFromGroups } from './src/functions/userManagement/removeUserFromGroups'
import { updateUser } from './src/functions/userManagement/updateUser'
import { UserData } from './src/types/userData'
require('firebase-functions/logger/compat')

admin.initializeApp()

export const setTimestampOnPaymentCreation = onDocumentCreated(
  'payments/{paymentId}',
  async (event) => {
    const snap = event.data
    if (!snap) return

    await snap.ref.update({ timeCreated: snap.createTime })
  }
)

export const getReceiptData = onCall(
  {
    timeoutSeconds: 300,
    memory: '4GiB',
  },
  async (event) => {
    if (!event.data.receiptUrl) {
      throw new Error('The parameter receiptUrl is required.')
    }

    return analyzeReceipt(
      event.data.receiptUrl,
      event.data.storeName,
      event.data.withNameImprovement
    )
  }
)

export const cleanUpOnAccountDeletion = functionsV1.auth
  .user()
  .onDelete(async (user, _) => {
    removeUserFromGroups(user.uid)
  })

export const changeUser = onDocumentUpdated('users/{userId}', async (event) => {
  const change = event.data
  if (!change) return

  const oldUserData = change.before.data() as UserData
  const newUserData = change.after.data() as UserData

  return await updateUser(event.params.userId, oldUserData, newUserData)
})

export const notifyWhenExpenceIsCreated = onDocumentCreated(
  'expenses/{expeseId}',
  async (event) => {
    const snap = event.data
    if (!snap) return

    return notifyWhenExpenseCreated(snap)
  }
)

export const handleExpenseUpdate = onDocumentWritten(
  'expenses/{expenseId}',
  async (event) => {
    const change = event.data
    if (!change) return

    try {
      await updateUserExpenses(change)
    } catch (e) {
      console.error('Error while updating user expenses:', e)
    }

    try {
      await updateUserGroupsWhenExpenseChanges(change)
    } catch (e) {
      console.error('Error while updating user groups: ', e)
    }

    const oldExpenseSnap = change.before
    const newExpenseSnap = change.after
    if (!newExpenseSnap.exists || !oldExpenseSnap.exists) return

    await notifyWhenExpenseUpdated(oldExpenseSnap, newExpenseSnap)
  }
)

export const notifyWhenGroupDebtThresholdIsReached = onDocumentUpdated(
  'groups/{groupId}',
  async (event) => {
    const change = event.data
    if (!change) return

    return notifyWhenGroupDebtThresholdReached(change)
  }
)

export const handleGroupUpdate = onDocumentWritten(
  'groups/{groupId}',
  async (event) => {
    const change = event.data
    if (!change) return

    try {
      await updateUserGroupsWhenGroupChanges(change)
    } catch (e) {
      console.error('Error while updating user groups:', e)
    }

    const groupDeleted = !change.after.exists
    if (groupDeleted) {
      await deleteRelatedGroupData(change.before.id)
    }
  }
)

export const getLatestAppVersion = onCall(async (event) => {
  if (!event.data.platform) throw new Error('parameter platform is required')

  const latestRelease = await getLatestRelease(event.data.platform)

  return latestRelease.displayVersion
})
