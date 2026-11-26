import * as admin from 'firebase-admin'
import { CurrencyRates } from '../../types/currencyRates'

const LATEST_RATES_URL = 'https://api.freecurrencyapi.com/v1/latest'
export const BASE_CURRENCY = 'USD'
export const LATEST_RATES_DOC_ID = 'latest'

type FreeCurrencyApiResponse = {
  data: { [code: string]: number }
}

/**
 * Fetches the latest exchange rates and stores them in the `currencies`
 * collection, both as a daily snapshot (`currencies/{YYYY-MM-DD}`) and as
 * `currencies/latest`, which is the only document the app reads.
 */
export async function updateCurrencyRates(
  apiKey: string,
  fetchFn: typeof fetch = fetch,
  now: Date = new Date()
): Promise<CurrencyRates> {
  const rates = await fetchLatestRates(apiKey, fetchFn)
  const date = now.toISOString().slice(0, 10)
  const currencyRates: CurrencyRates = {
    base: BASE_CURRENCY,
    date,
    rates,
    updatedAt: admin.firestore.Timestamp.fromDate(now),
  }

  const currencies = admin.firestore().collection('currencies')
  const batch = admin.firestore().batch()
  batch.set(currencies.doc(date), currencyRates)
  batch.set(currencies.doc(LATEST_RATES_DOC_ID), currencyRates)
  await batch.commit()

  console.log(`Stored ${Object.keys(rates).length} exchange rates for ${date}`)
  return currencyRates
}

async function fetchLatestRates(
  apiKey: string,
  fetchFn: typeof fetch
): Promise<CurrencyRates['rates']> {
  const url = `${LATEST_RATES_URL}?base_currency=${BASE_CURRENCY}`
  const response = await fetchFn(url, { headers: { apikey: apiKey } })
  if (!response.ok) {
    const error = await response.text()
    throw new Error(`Error fetching exchange rates: ${error}`)
  }

  const result = (await response.json()) as FreeCurrencyApiResponse
  const hasRates = !!result.data && Object.keys(result.data).length > 0
  if (!hasRates) throw new Error('Exchange rate response has no rates')

  return result.data
}
