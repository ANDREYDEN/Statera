import * as admin from 'firebase-admin'
import {
  updateCurrencyRates,
} from '../../../src/functions/currencies/updateCurrencyRates'
import { CurrencyRates } from '../../../src/types/currencyRates'
import { deleteAllData } from '../../testUtils'

admin.initializeApp()

const API_KEY = 'test-key'
const NOW = new Date('2026-11-25T00:00:00Z')

describe('updateCurrencyRates', () => {
  beforeEach(deleteAllData)

  it('stores the latest rates and a daily snapshot', async () => {
    const fetchFn = mockFetch({ data: { EUR: 0.9, GBP: 0.8 } })

    await updateCurrencyRates(API_KEY, fetchFn, NOW)

    for (const docId of ['latest', '2026-11-25']) {
      const doc = await admin.firestore().doc(`currencies/${docId}`).get()
      const currencyRates = doc.data() as CurrencyRates
      expect(currencyRates.base).toEqual('USD')
      expect(currencyRates.date).toEqual('2026-11-25')
      expect(currencyRates.rates).toEqual({ EUR: 0.9, GBP: 0.8 })
    }
  })

  it('sends the api key and requests USD-based rates', async () => {
    const fetchFn = mockFetch({ data: { EUR: 0.9 } })

    await updateCurrencyRates(API_KEY, fetchFn, NOW)

    const [url, options] = fetchFn.mock.calls[0]
    expect(url).toContain('base_currency=USD')
    expect(options.headers).toEqual({ apikey: API_KEY })
  })

  it('does not overwrite rates when the request fails', async () => {
    const fetchFn = mockFetch({ message: 'Invalid key' }, false)

    await expect(updateCurrencyRates(API_KEY, fetchFn, NOW)).rejects.toThrow()

    const doc = await admin.firestore().doc('currencies/latest').get()
    expect(doc.exists).toBe(false)
  })

  it('does not store an empty response', async () => {
    const fetchFn = mockFetch({ data: {} })

    await expect(updateCurrencyRates(API_KEY, fetchFn, NOW)).rejects.toThrow()

    const doc = await admin.firestore().doc('currencies/latest').get()
    expect(doc.exists).toBe(false)
  })
})

function mockFetch(body: object, ok = true) {
  return jest.fn().mockResolvedValue({
    ok,
    json: async () => body,
    text: async () => JSON.stringify(body),
  })
}
