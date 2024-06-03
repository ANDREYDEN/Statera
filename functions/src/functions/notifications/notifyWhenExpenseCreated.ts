import { firestore, messaging } from 'firebase-admin'
import { getExpenseNotificationTokens } from './notificationUtils'

export async function notifyWhenExpenseCreated(
  expenseSnap: firestore.QueryDocumentSnapshot
) {
  const groupId = expenseSnap.data().groupId
  const group = await firestore().collection('groups').doc(groupId).get()
  const authorUid = expenseSnap.data()?.authorUid
  const author = group.data()?.members.find((m: any) => m.uid === authorUid)
  const authorName = author?.name || 'anonymous'
  const userTokens = await getExpenseNotificationTokens(expenseSnap)

  if (userTokens.length === 0) return null

  return messaging().sendMulticast({
    tokens: userTokens as string[],
    notification: {
      title: 'New Expense',
      body: `${authorName} created "${expenseSnap.data().name}" in group ${group?.data()?.name}`,
    },
    data: {
      type: 'expense_created',
      expenseId: expenseSnap.id,
    },
  })
}
