import 'firebase-functions'
import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'
import { firestoreBackup } from './src/admin'
import { analyzeReceipt } from './src/functions/analyzeReceipt'
import { removeUserFromGroups } from './src/functions/removeUserFromGroups'
import { handleTokenUpdate } from './src/functions/notifications/handleTokenUpdate'
import { notifyAboutExpenseCreation as notifyWhenExpenseCreated } from './src/functions/notifications/notifyAboutExpenseCreation'
import { updateUser } from './src/functions/updateUser'
import { UserData } from './src/types/userData'
import { notifyWhenExpenseCompleted } from './src/functions/notifications/notifyWhenExpenseCompleted'

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

export const changeUser = functions.firestore
    .document('users/{userId}')
    .onUpdate(async (change, context) => {
      const oldUserData = change.before.data() as UserData
      const newUserData = change.after.data() as UserData
      if (oldUserData.name !== newUserData.name 
        || oldUserData.photoURL !== newUserData.photoURL) {
        await updateUser(context.params.userId, newUserData)
      }
      return null
    })

export const notifyWhenExpenceIsCreated = functions.firestore
  .document('expenses/{expeseId}')
  .onCreate((snap, _) => {
    return notifyWhenExpenseCreated(snap)
  })

export const notifyWhenExpenseIsCompleted = functions.https
  .onCall((data, _) => {
    if (!data.expenseId) throw new Error('parameter expenseId is required')
    return notifyWhenExpenseCompleted(data.expenseId)
  })

export const updateUserNotificationToken = functions.https
  .onCall((data, _) => {
    if (!data.uid) throw new Error('parameter uid is required')
    if (!data.token) throw new Error('parameter token is required')

    return handleTokenUpdate(data.uid, data.token)
  })