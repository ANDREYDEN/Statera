import * as admin from 'firebase-admin'
import { firestore, messaging } from 'firebase-admin';
import { getGroupNotificationTokens } from './notificationUtils'

export async function notifyWhenExpenseCreated(expenseSnap: firestore.QueryDocumentSnapshot) {
    const app = admin.app()
    const groupId = expenseSnap.data().groupId
    const authorName = expenseSnap.data()?.author?.name ?? "anonymous"
    const group = await firestore(app).collection('groups').doc(groupId).get()
    const userTokens = await getGroupNotificationTokens(group)
    console.log('Retrieved tokens:', userTokens);

    return messaging(app).sendMulticast({
        tokens: userTokens as string[],
        notification: {
            title: 'New Expense',
            body: `${authorName} created "${expenseSnap.data().name}" in group ${group?.data()?.name}`
        },
        data: {
            type: 'new_expense',
            expenseId: expenseSnap.id
        }
    })
}
