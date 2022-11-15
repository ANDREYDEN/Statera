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
