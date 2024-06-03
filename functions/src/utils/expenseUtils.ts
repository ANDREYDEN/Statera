import { Expense } from '../types/expense'

export function calculateStage(expense: Expense, assigneeId: string) {
  if (expense.finalizedDate) return 2

  if (expense.unmarkedAssigneeIds.includes(assigneeId)) return 0

  return 1
}
