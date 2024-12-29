import { Item } from '../../src/types/item'
import { isItemCompleted } from '../../src/utils/itemUtils'

describe('itemUtils', () => {
  describe('isItemCompleted', () => {
    it('should return true when item is completed', () => {
      const item: Item = {
        name: 'Item 1',
        assignees: [
          {
            uid: 'Assignee 1',
            parts: 1,
          },
        ],
        partition: 1,
      }

      const result = isItemCompleted(item)

      expect(result).toBe(true)
    })

    it.each([
      { parts: 1, partition: 2 },
      { parts: null, partition: 1 },
      { parts: null, partition: 2 },
    ])('should return false when item is not completed', ({ parts, partition }) => {
      const item: Item = {
        name: 'Item 1',
        assignees: [
          {
            uid: 'Assignee 1',
            parts,
          },
        ],
        partition,
      }

      const result = isItemCompleted(item)

      expect(result).toBe(false)
    })
  })
})
