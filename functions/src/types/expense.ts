import { Item } from './item'

export type Expense = {
    assigneeIds: string[]
    items: Item[]
    finalizedDate: string | null
    unmarkedAssigneeIds: string[]
    authorUid: string
    groupId: string
}
