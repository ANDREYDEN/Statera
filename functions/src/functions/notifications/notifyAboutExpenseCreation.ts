import * as admin from 'firebase-admin'
import { firestore, messaging } from 'firebase-admin';

export async function notifyAboutExpenseCreation(expenseSnap: firestore.QueryDocumentSnapshot) {
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

async function getGroupNotificationTokens(group: firestore.DocumentSnapshot<firestore.DocumentData>) {
    const app = admin.app()
    const userIds = (group?.data()?.memberIds ?? []) as string[];
    console.log(`Sending notifications to ${userIds.join(', ')}`);
    
    const userDocs = await Promise.all(userIds.map(uid => firestore(app).collection('users').doc(uid).get()))
    return userDocs.flatMap(doc => Object.keys(doc.data()?.notifications ?? {}))
}