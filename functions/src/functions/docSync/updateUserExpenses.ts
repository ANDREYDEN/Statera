import { firestore } from 'firebase-admin'
import { DocumentSnapshot } from 'firebase-admin/firestore'
import { Change } from 'firebase-functions/v1'
import { calculateStage, getParticipantIds } from '../../utils/expenseUtils'
import { Expense } from '../../types/expense'
import { UserExpense } from '../../types/userExpense'

export async function updateUserExpenses(change: Change<DocumentSnapshot>) {
  const oldExpenseData = change.before.data() as (Expense | undefined)
  const newExpenseData = change.after.data() as (Expense | undefined)
  const expenseId = change.after.id

  const oldParticipantIds = oldExpenseData ? getParticipantIds(oldExpenseData) : []
  const newParticipantIds = newExpenseData ? getParticipantIds(newExpenseData) : []

  const addedParticipantIds = newParticipantIds.filter((newUid) => !oldParticipantIds.includes(newUid))
  const updatedParticipantIds = newParticipantIds.filter((newUid) => oldParticipantIds.includes(newUid))
  const deletedParticipantIds = oldParticipantIds.filter((oldUid) => !newParticipantIds.includes(oldUid))

  for (const uid of addedParticipantIds) {
    const userExpenseRef = firestore().doc(`users/${uid}/expenses/${expenseId}`)

    const newUserExpense: UserExpense = {
      ...newExpenseData!,
      stage: calculateStage(newExpenseData!, uid),
    }

    await userExpenseRef.set(newUserExpense)
  }

  for (const uid of updatedParticipantIds) {
    const userExpenseRef = firestore().doc(`users/${uid}/expenses/${expenseId}`)

    const newUserExpense: UserExpense = {
      ...newExpenseData!,
      stage: calculateStage(newExpenseData!, uid),
    }

    await userExpenseRef.update(newUserExpense)
  }

  for (const uid of deletedParticipantIds) {
    const userExpenseRef = firestore().doc(`users/${uid}/expenses/${expenseId}`)

    await userExpenseRef.delete()
  }
}
