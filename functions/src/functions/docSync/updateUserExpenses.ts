import { firestore } from "firebase-admin";
import { DocumentSnapshot } from "firebase-admin/firestore";
import { Change } from "firebase-functions/v1";
import { calculateStage } from "../../utils/expenseUtils";

export async function updateUserExpenses(change: Change<DocumentSnapshot>) {
    const expenseData = change.after.data() ?? change.before.data()
    const expenseDeleted = !change.after.exists
    if (!expenseData) return

    const relatedUids = new Set([
        ...expenseData.assigneeIds, 
        expenseData.authorUid
    ]).values()

    for (const uid of relatedUids) {
        const userExpenseRef = firestore().collection('users').doc(uid).collection('expenses').doc(change.after.id)
        if (expenseDeleted) {
            await userExpenseRef.delete()    
        } else {
            const stage = calculateStage(expenseData, uid)
            await userExpenseRef.set({
                ...expenseData,
                stage
            })
        }
    }
}