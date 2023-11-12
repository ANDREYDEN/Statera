export function calculateStage(expense: any, assigneeId: string) {
    if (expense.finalizedDate != null) return 2

    if (expense.unmarkedAssigneeIds.includes(assigneeId)) return 0

    return 1
}