import * as admin from 'firebase-admin'
import { messaging } from 'firebase-admin';
import { QueryDocumentSnapshot } from "firebase-functions/v1/firestore";

const app = admin.initializeApp()

export async function notifyAboutExpenseCreation(expenseSnap: QueryDocumentSnapshot) {
    const groupId = expenseSnap.data().groupId
    const group = await expenseSnap.ref.parent.parent?.collection('groups').doc(groupId).get()

    return messaging(app).sendMulticast({
        tokens: ['asd'],
        notification: {
            title: 'New Expense',
            body: `New expense "${expenseSnap.data().name}" in group ${group?.data()?.name}`
        }
    })
}