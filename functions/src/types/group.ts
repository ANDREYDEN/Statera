import { UserData } from './userData'

export type Group = {
    name: string
    debtThreshold: number
    balance: {[from: string]: {[to: string]: number }}
    members: UserData[]
}
