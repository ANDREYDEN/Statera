import { UserData } from './userData'

export type Group = {
    debtThreshold: number
    balance: {[from: string]: {[to: string]: number }}
    members: UserData[]
}
