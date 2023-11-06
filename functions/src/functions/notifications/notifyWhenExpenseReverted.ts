import { messaging } from 'firebase-admin'
import { DocumentSnapshot } from 'firebase-admin/firestore'
import { getExpenseNotificationTokens } from './notificationUtils'

export async function notifyWhenExpenseReverted(expenseSnap: DocumentSnapshot) {
  if (!expenseSnap.exists) {
    console.log(`Expense ${expenseSnap.id} no longer exists`)
    return
  }

  const groupId = expenseSnap.data()?.groupId
  console.log('Sending Notification', expenseSnap.id, 'expense_reverted')

  const authorTokens = await getExpenseNotificationTokens(expenseSnap)

  if (authorTokens.length === 0) return null

  return messaging().sendMulticast({
    tokens: authorTokens as string[],
    notification: {
      title: 'Expense Reverted',
      body: `Expense "${expenseSnap.data()?.name}" was reverted`,
    },
    data: {
      type: 'expense_reverted',
      groupId,
    },
  })
}
