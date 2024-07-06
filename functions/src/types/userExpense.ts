import { Expense } from './expense'

export type UserExpense = Expense & { stage: 0 | 1 | 2 }
