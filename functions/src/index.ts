import 'firebase-functions'
import * as functions from 'firebase-functions'
import { firestoreBackup } from './admin'
import { analyzeReceipt } from './functions/analyzeReceipt'

export const scheduledBackup = firestoreBackup

export const setTimestampOnPaymentCreation = functions.firestore
    .document('payments/{paymentId}')
    .onCreate(async (snap, _) => {
      await snap.ref.update({ timeCreated: snap.createTime })
    })

export const getReceiptData = functions
    .runWith({ 
      timeoutSeconds: 300,
      memory: "4GB"
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
