import { Expense } from '../../src/types/expense'
import { isExpenseCompleted } from '../../src/utils/expenseUtils'

describe('expenseUtils', () => {
  describe('isExpenseCompleted', () => {
    it('should return true when all items are completed', () => {
      // TODO: create factory
      const expense: Expense = {
        items: [
          {
            name: 'Item 1',
            assignees: [
              {
                uid: 'Assignee 1',
                parts: 1,
              },
            ],
            partition: 1,
          },
        ],
        assigneeIds: ['Assignee 1'],
        finalizedDate: null,
        unmarkedAssigneeIds: [],
        authorUid: 'Author 1',
        groupId: 'Group 1',
      }

      const result = isExpenseCompleted(expense)

      expect(result).toBe(true)
    })

    it('should return false when some items are not completed', () => {
      const expense = {
        items: [
          {
            name: 'Item 1',
            assignees: [
              {
                uid: 'Assignee 1',
                parts: 1,
              },
            ],
            partition: 1,
          },
          {
            name: 'Item 2',
            assignees: [
              {
                uid: 'Assignee 1',
                parts: null,
              },
            ],
            partition: 1,
          },
        ],
        assigneeIds: ['Assignee 1'],
        finalizedDate: null,
        unmarkedAssigneeIds: [],
        authorUid: 'Author 1',
        groupId: 'Group 1',
      }

      const result = isExpenseCompleted(expense)

      expect(result).toBe(false)
    })

    it('should return false when expense is empty', () => {
      const expense = {
        items: [],
        assigneeIds: [],
        finalizedDate: null,
        unmarkedAssigneeIds: [],
        authorUid: 'Author 1',
        groupId: 'Group 1',
      }

      const result = isExpenseCompleted(expense)

      expect(result).toBe(false)
    })
  })
})
