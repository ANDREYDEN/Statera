import { DocumentSnapshot, Timestamp } from 'firebase-admin/firestore'
import { Expense } from '../../types/expense'
import { isExpenseCompleted } from '../../utils/expenseUtils'
import { notifyWhenExpenseCompleted } from './notifyWhenExpenseCompleted'
import { notifyWhenExpenseFinalized } from './notifyWhenExpenseFinalized'
import { notifyWhenExpenseReverted } from './notifyWhenExpenseReverted'

export async function notifyWhenExpenseUpdated(
  oldExpenseSnap: DocumentSnapshot,
  newExpenseSnap: DocumentSnapshot
) {
  const oldExpense = oldExpenseSnap.data() as Expense
  const newExpense = newExpenseSnap.data() as Expense

  const oldFinalizedTimestamp = oldExpense.finalizedDate as (Timestamp | null)
  const newFinalizedTimestamp = newExpense.finalizedDate as (Timestamp | null)

  if (oldFinalizedTimestamp?.toMillis != newFinalizedTimestamp?.toMillis) {
    if (newExpense.finalizedDate) {
      await notifyWhenExpenseFinalized(newExpenseSnap)
    } else {
      await notifyWhenExpenseReverted(newExpenseSnap)
    }
  } else if (!newFinalizedTimestamp) {
    if (!isExpenseCompleted(oldExpense as Expense) && isExpenseCompleted(newExpense as Expense)) {
      await notifyWhenExpenseCompleted(newExpenseSnap.id)
    }
  }
}
