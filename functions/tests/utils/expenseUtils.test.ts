import { Expense } from '../../src/types/expense'
import { isExpenseCompleted } from '../../src/utils/expenseUtils'
import { ExpenseFactory } from '../factories/expenseFactory'
import { ItemFactory } from '../factories/itemFactory'

describe('expenseUtils', () => {
  describe('isExpenseCompleted', () => {
    it('should return true when all items are completed', () => {
      const expense: Expense = ExpenseFactory.create({
        items: [
          ItemFactory.create({
            assignees: [
              { uid: 'Assignee 1', parts: 1 },
            ],
            partition: 1,
          }),
        ],
      })

      const result = isExpenseCompleted(expense)

      expect(result).toBe(true)
    })

    it('should return false when some items are not completed', () => {
      const expense = ExpenseFactory.create({
        items: [
          ItemFactory.create({
            assignees: [
              { uid: 'Assignee 1', parts: 1 },
            ],
            partition: 1,
          }),
          ItemFactory.create({
            assignees: [
              { uid: 'Assignee 1', parts: null },
            ],
            partition: 1,
          }),
        ],
      })

      const result = isExpenseCompleted(expense)

      expect(result).toBe(false)
    })

    it('should return false when expense is empty', () => {
      const expense = ExpenseFactory.create({ items: [] })

      const result = isExpenseCompleted(expense)

      expect(result).toBe(false)
    })
  })
})
