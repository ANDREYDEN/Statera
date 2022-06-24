import 'firebase-functions'
import * as functions from 'firebase-functions'
import { firestoreBackup } from './admin'
import { analyzeReceipt } from './functions/analyzeReceipt'
import { handleTokenUpdate } from './functions/notifications/handleTokenUpdate'
import { notifyAboutExpenseCreation } from './functions/notifications/notifyAboutExpenseCreation'
import { removeUserFromGroups } from './functions/removeUserFromGroups'

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