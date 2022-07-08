import 'firebase-functions'
import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { firestoreBackup } from './src/admin'
import { analyzeReceipt } from './src/functions/analyzeReceipt'
import { handleTokenUpdate } from './src/functions/notifications/handleTokenUpdate'
import { notifyAboutExpenseCreation } from './src/functions/notifications/notifyAboutExpenseCreation'
import { removeUserFromGroups } from './src/functions/removeUserFromGroups'

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
          data.withNameImprovement
      )
    })

export const cleanUpOnAccountDeletion = functions.auth
    .user()
    .onDelete(async (user, _) => {
      removeUserFromGroups(user.uid)
    })

export const notifyOnExpenceCreation = functions.firestore
  .document('expenses/{expeseId}')
  .onCreate((snap, _) => {
    return notifyAboutExpenseCreation(snap)
  })

export const updateUserNotificationToken = functions.https
  .onCall((data, _) => {
    if (!data.uid) throw new Error('parameter uid is required')
    if (!data.token) throw new Error('parameter token is required')

    return handleTokenUpdate(data.uid, data.token)
  })