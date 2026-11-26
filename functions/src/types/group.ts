import { UserData } from './userData'

export type Group = {
    name: string
    debtThreshold: number
    currencyCode?: string
    currencySign?: string
    balance: {[from: string]: {[to: string]: number }}
    members: UserData[]
}
