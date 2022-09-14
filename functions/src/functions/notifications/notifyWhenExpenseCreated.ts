import { firestore, messaging } from 'firebase-admin';
import { getGroupNotificationTokens } from './notificationUtils'

export async function notifyWhenExpenseCreated(expenseSnap: firestore.QueryDocumentSnapshot) {
    const groupId = expenseSnap.data().groupId
    const authorName = expenseSnap.data()?.author?.name ?? "anonymous"
    const group = await firestore().collection('groups').doc(groupId).get()
    const userTokens = await getGroupNotificationTokens(group)
    console.log('Retrieved tokens:', userTokens);

    if (userTokens.length === 0) return null

    return messaging().sendMulticast({
        tokens: userTokens as string[],
        notification: {
            title: 'New Expense',
            body: `${authorName} created "${expenseSnap.data().name}" in group ${group?.data()?.name}`
        },
        data: {
            type: 'expense_created',
            expenseId: expenseSnap.id
        }
    })
}
