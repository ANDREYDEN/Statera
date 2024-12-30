import { notifyWhenExpenseCompleted } from '../../../src/functions/notifications/notifyWhenExpenseCompleted'
import { notifyWhenExpenseFinalized } from '../../../src/functions/notifications/notifyWhenExpenseFinalized'
import { notifyWhenExpenseReverted } from '../../../src/functions/notifications/notifyWhenExpenseReverted'
import { notifyWhenExpenseUpdated } from '../../../src/functions/notifications/notifyWhenExpenseUpdated'

import { DocumentSnapshot } from 'firebase-admin/firestore'
import { ExpenseFactory } from '../../factories/expenseFactory'
import { ItemFactory } from '../../factories/itemFactory'
jest.mock('../../../src/functions/notifications/notifyWhenExpenseFinalized')
jest.mock('../../../src/functions/notifications/notifyWhenExpenseReverted')
jest.mock('../../../src/functions/notifications/notifyWhenExpenseCompleted')

describe('notifyWhenExpenseUpdated', () => {
  it('should notify when expense is finalized', async () => {
    const oldExpenseSnap = {
      data: jest.fn(() => ({
        finalizedDate: null,
      })),
    }
    const newExpenseSnap = {
      data: jest.fn(() => ({
        finalizedDate: {
          toMillis: jest.fn(() => 1),
        },
      })),
    }

    await notifyWhenExpenseUpdated(
      oldExpenseSnap as unknown as DocumentSnapshot,
      newExpenseSnap as unknown as DocumentSnapshot
    )

    expect(notifyWhenExpenseFinalized).toHaveBeenCalledWith(newExpenseSnap)
  })

  it('should notify when expense is reverted', async () => {
    const oldExpenseSnap = {
      data: jest.fn(() => ({
        finalizedDate: {
          toMillis: jest.fn(() => 1),
        },
      })),
    }
    const newExpenseSnap = {
      data: jest.fn(() => ({
        finalizedDate: null,
      })),
    }

    await notifyWhenExpenseUpdated(
      oldExpenseSnap as unknown as DocumentSnapshot,
      newExpenseSnap as unknown as DocumentSnapshot
    )

    expect(notifyWhenExpenseReverted).toHaveBeenCalledWith(newExpenseSnap)
  })

  it('should notify when expense is completed', async () => {
    const oldExpenseSnap = {
      data: jest.fn(() => (ExpenseFactory.create({
        finalizedDate: null,
        items: [
          ItemFactory.create({
            assignees: [
              { uid: 'Assignee 1', parts: null },
            ],
          }),
        ],
      }))),
    }
    const newExpenseSnap = {
      id: 'asd',
      data: jest.fn(() => (ExpenseFactory.create({
        finalizedDate: null,
        items: [
          ItemFactory.create({
            assignees: [
              { uid: 'Assignee 1', parts: 1 },
            ],
          }),
        ],
      }))),
    }

    await notifyWhenExpenseUpdated(
      oldExpenseSnap as unknown as DocumentSnapshot,
      newExpenseSnap as unknown as DocumentSnapshot
    )

    expect(notifyWhenExpenseCompleted).toHaveBeenCalledWith(newExpenseSnap.id)
  })
})
