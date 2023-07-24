import { messaging } from 'firebase-admin'
import { getExpenseNotificationTokens } from './notificationUtils'
import { QueryDocumentSnapshot } from 'firebase-admin/firestore'

export async function notifyWhenExpenseFinalized(expenseSnap: QueryDocumentSnapshot) {
  if (!expenseSnap.exists) {
    console.log(`Expense ${expenseSnap.id} no longer exists`)
    return
  }

  const groupId = expenseSnap.data()?.groupId

  const authorTokens = await getExpenseNotificationTokens(expenseSnap, false)
  console.log('Retrieved tokens:', authorTokens)

  if (authorTokens.length === 0) return null

  return messaging().sendMulticast({
    tokens: authorTokens as string[],
    notification: {
      title: 'Expense finalized',
      body: `Expense "${expenseSnap.data()?.name}" was finalized`,
    },
    data: {
      type: 'expense_finalized',
      groupId,
    },
  })
}
