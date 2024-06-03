import * as admin from 'firebase-admin'
import 'firebase-functions'
import * as functions from 'firebase-functions'
import { firestoreBackup } from './src/admin'
import { analyzeReceipt } from './src/functions/analyzeReceipt'
import { getLatestRelease } from './src/functions/getLatestRelease'
import { notifyWhenExpenseCompleted } from './src/functions/notifications/notifyWhenExpenseCompleted'
import { notifyWhenExpenseCreated } from './src/functions/notifications/notifyWhenExpenseCreated'
import { notifyWhenExpenseFinalized } from './src/functions/notifications/notifyWhenExpenseFinalized'
import { notifyWhenExpenseReverted } from './src/functions/notifications/notifyWhenExpenseReverted'
import { notifyWhenGroupDebtThresholdReached } from './src/functions/notifications/notifyWhenGroupDebtThresholdReached'
import { createUserDoc } from './src/functions/userManagement/createUserDoc'
import { removeUserFromGroups } from './src/functions/userManagement/removeUserFromGroups'
import { updateUser } from './src/functions/userManagement/updateUser'
import { UserData } from './src/types/userData'
import { Timestamp } from 'firebase-admin/firestore'
import { updateUserExpenses } from './src/functions/docSync/updateUserExpenses'
require('firebase-functions/logger/compat')

admin.initializeApp()

export const scheduledBackup = firestoreBackup

export const setTimestampOnPaymentCreation = functions.firestore
    .document('payments/{paymentId}')
    .onCreate(async (snap, _) => {
      await snap.ref.update({ timeCreated: snap.createTime })
    })

export const handleExpenseUpdate = functions.firestore
    .document('expenses/{expenseId}')
    .onWrite(async (change, _) => {
      const oldExpense = change.before.data()
      const newExpense = change.after.data()

      await updateUserExpenses(change)

      if (!newExpense || !oldExpense) return

      const oldFinalizedTimestamp = oldExpense.finalizedDate as (Timestamp | null)
      const newFinalizedTimestamp = newExpense.finalizedDate as (Timestamp | null)

      if (oldFinalizedTimestamp?.toMillis != newFinalizedTimestamp?.toMillis) {
        if (newExpense.finalizedDate) {
          await notifyWhenExpenseFinalized(change.after)
        } else {
          await notifyWhenExpenseReverted(change.after)
        }
      }
    })

export const getReceiptData = functions
    .runWith({
      timeoutSeconds: 300,
      memory: '4GB',
    })
    .https.onCall(async (data, _) => {
      if (!data.receiptUrl) {
        throw Error('The parameter receiptUrl is required.')
      }

      return analyzeReceipt(
          data.receiptUrl,
          data.storeName,
          data.withNameImprovement
      )
    })

export const cleanUpOnAccountDeletion = functions.auth
    .user()
    .onDelete(async (user, _) => {
      removeUserFromGroups(user.uid)
    })

export const createUser = functions.auth.user().onCreate((user, context) => {
  return createUserDoc(user)
})

export const changeUser = functions.firestore
    .document('users/{userId}')
    .onUpdate(async (change, context) => {
      const oldUserData = change.before.data() as UserData
      const newUserData = change.after.data() as UserData

      return await updateUser(context.params.userId, oldUserData, newUserData)
    })

export const notifyWhenExpenceIsCreated = functions.firestore
    .document('expenses/{expeseId}')
    .onCreate((snap, _) => {
      return notifyWhenExpenseCreated(snap)
    })

export const notifyWhenGroupDebtThresholdIsReached = functions.firestore
    .document('groups/{groupId}')
    .onUpdate((change, _) => {
      return notifyWhenGroupDebtThresholdReached(change)
    })

export const notifyWhenExpenseIsCompleted = functions.https
    .onCall((data, _) => {
      if (!data.expenseId) throw new Error('parameter expenseId is required')
      return notifyWhenExpenseCompleted(data.expenseId)
    })

export const getLatestAppVersion = functions.https.onCall(async (data, _) => {
  if (!data.platform) throw new Error('parameter platform is required')

  const latestRelease = await getLatestRelease(data.platform)

  return latestRelease.displayVersion
})
