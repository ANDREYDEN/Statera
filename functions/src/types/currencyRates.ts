import { firestore } from 'firebase-admin'

export type CurrencyRates = {
  /** ISO code of the currency that all rates are relative to */
  base: string
  /** Day the rates were fetched for, formatted as YYYY-MM-DD */
  date: string
  /** Amount of each currency that equals one unit of the base currency */
  rates: { [code: string]: number }
  updatedAt: firestore.Timestamp
}
