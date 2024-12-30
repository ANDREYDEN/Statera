import { Expense } from '../../src/types/expense'

export class ExpenseFactory {
  static create(partial: Partial<Expense>): Expense {
    return {
      groupId: 'Group 1',
      assigneeIds: [],
      authorUid: '',
      finalizedDate: null,
      items: [],
      unmarkedAssigneeIds: [],
      ...partial,
    }
  }
}
