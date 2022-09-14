import { firestore, messaging } from 'firebase-admin'
import { getExpenseNotificationTokens } from './notificationUtils'

export async function notifyWhenExpenseFinalized(expenseId: string) {
  const expenseSnap = await firestore().collection('expenses').doc(expenseId).get()
  if (!expenseSnap.exists) {
    console.log(`Expense ${expenseId} no longer exists`);
    return
  }

  const groupId = expenseSnap.data()?.groupId

  const authorTokens = await getExpenseNotificationTokens(expenseSnap, false)
  console.log('Retrieved tokens:', authorTokens);

  if (authorTokens.length === 0) return null

  return messaging().sendMulticast({
      tokens: authorTokens as string[],
      notification: {
          title: 'Expense finalized',
          body: `Expense "${expenseSnap.data()?.name}" was finalized`
      },
      data: {
          type: 'expense_finalized',
          groupId
      }
  })
}