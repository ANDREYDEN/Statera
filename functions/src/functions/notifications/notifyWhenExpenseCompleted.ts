import { firestore, messaging } from 'firebase-admin';
import { getUserNotificationTokens } from './notificationUtils'

export async function notifyWhenExpenseCompleted(expenseId: string) {
  const expenseSnap = await firestore().collection('expenses').doc(expenseId).get()
  if (!expenseSnap.exists) {
    console.log(`Expense ${expenseId} no longer exists`);
    return
  }

  const groupId = expenseSnap.data()?.groupId

  const author = expenseSnap.data()?.author
  const authorTokens = await getUserNotificationTokens(author?.uid)
  console.log('Retrieved tokens:', authorTokens)

  if (authorTokens.length === 0) return null
  
  return messaging().sendMulticast({
      tokens: authorTokens as string[],
      notification: {
          title: 'Expense completed',
          body: `Expense "${expenseSnap.data()?.name}" is ready to be finalized`
      },
      data: {
          type: 'expense_completed',
          groupId
      }
  })
}
