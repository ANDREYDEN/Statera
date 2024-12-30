import { Item } from '../types/item'

export function isItemCompleted(item: Item) : boolean {
  if (item.partition > 1) {
    const confirmedParts = item.assignees
      .map((a) => a.parts)
      .reduce((acc, cur) => (acc ?? 0) + (cur ?? 0), 0)
    return confirmedParts === item.partition
  }

  return item.assignees.every((a) => a.parts != null)
}
