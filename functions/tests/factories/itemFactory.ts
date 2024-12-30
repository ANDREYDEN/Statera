import { Item } from '../../src/types/item'

export class ItemFactory {
  static create(partial: Partial<Item>): Item {
    return {
      name: 'Item 1',
      assignees: [],
      partition: 1,
      ...partial,
    }
  }
}
