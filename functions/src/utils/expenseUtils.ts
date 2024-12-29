import { Expense } from '../types/expense'
import { isItemCompleted } from './itemUtils'

export function calculateStage(expense: Expense, assigneeId: string) {
  if (expense.finalizedDate) return 2

  if (expense.unmarkedAssigneeIds.includes(assigneeId)) return 0

  return 1
}

export function getParticipantIds(expense: Expense): string[] {
  return [
    ...new Set([...expense.assigneeIds, expense.authorUid]),
  ].filter((e) => e)
}

export function isExpenseCompleted(expense: Expense) {
  return expense.items.length > 0 && expense.items.every((item) => isItemCompleted(item))
}
