import * as admin from 'firebase-admin'
import { firestore, messaging } from 'firebase-admin';
import { QueryDocumentSnapshot } from "firebase-functions/v1/firestore";

const app = admin.initializeApp()

export async function notifyAboutExpenseCreation(expenseSnap: QueryDocumentSnapshot) {
    const groupId = expenseSnap.data().groupId
    const group = await firestore(app).collection('groups').doc(groupId).get()
    const userTokens = await getGroupNotificationTokens(group)

    return messaging(app).sendMulticast({
        tokens: userTokens as string[],
        notification: {
            title: 'New Expense',
            body: `New expense "${expenseSnap.data().name}" in group ${group?.data()?.name}`
        },
        data: {
            type: 'new_expense',
            expenseId: expenseSnap.id
        }
    })
}

async function getGroupNotificationTokens(group: any) {
    const userIds = (group?.data()?.memberIds ?? []) as string[];
    const userDocs = await Promise.all(userIds.map(uid => firestore(app).collection('users').doc(uid).get()))
    return userDocs.map(doc => doc.data()?.notification.token)
}