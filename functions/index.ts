import 'firebase-functions'
import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'
import { firestoreBackup } from './src/admin'
import { analyzeReceipt } from './src/functions/analyzeReceipt'
import { removeUserFromGroups } from './src/functions/userManagement/removeUserFromGroups'
import { updateUser } from './src/functions/userManagement/updateUser'
import { UserData } from './src/types/userData'
import { notifyWhenExpenseCreated } from './src/functions/notifications/notifyWhenExpenseCreated'
import { notifyWhenExpenseCompleted } from './src/functions/notifications/notifyWhenExpenseCompleted'
import { notifyWhenExpenseFinalized } from './src/functions/notifications/notifyWhenExpenseFinalized'
import { notifyWhenGroupDebtThresholdReached } from './src/functions/notifications/notifyWhenGroupDebtThresholdReached'
import { createUserDoc } from './src/functions/userManagement/createUserDoc'
import fetch from 'node-fetch'

admin.initializeApp()

export const scheduledBackup = firestoreBackup

export const setTimestampOnPaymentCreation = functions.firestore
  .document('payments/{paymentId}')
  .onCreate(async (snap, _) => {
    await snap.ref.update({ timeCreated: snap.createTime })
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
      data.isWalmart,
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

export const notifyWhenExpenseIsFinalized = functions.https
  .onCall((data, _) => {
    if (!data.expenseId) throw new Error('parameter expenseId is required')
    return notifyWhenExpenseFinalized(data.expenseId)
  })

export const getLatestAppVersion = functions.https.onCall(async (data, _) => {
  const platform = data.platform
  const listApps = platform == 'android'
    ? admin.projectManagement().listAndroidApps()
    : admin.projectManagement().listIosApps()
  const apps = await listApps
  if (!apps || apps.length === 0) throw new Error(`No ${platform} apps found`)

  const app = apps[0]
  const appId = app.appId
  const projectNumber = app.appId.split(':')[1]

  const accessToken = await admin.app().options.credential?.getAccessToken()
  const response = await fetch(
    `https://firebaseappdistribution.googleapis.com/v1/projects/${projectNumber}/apps/${appId}/releases`,
    {
      headers: {
        Authorization: `Bearer ${accessToken?.access_token}`,
      }
    })
  const result = await response.json()
  const releases = result.releases
  if (!releases || releases.length === 0) throw new Error(`No ${platform} releases found`)

  const latestAppVersion = releases[0].displayVersion
  return latestAppVersion
})