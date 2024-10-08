export type UserGroup = {
    groupId: string
    name: string
    memberCount: number
    unmarkedExpenses?: number
    balance?: {[from: string]: {[to: string]: number }}
}
