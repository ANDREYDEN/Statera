import { analyzeReceipt } from "../../src/functions/analyzeReceipt"
import lcboReceiptProducts from '../__stubs__/lcbo_receipt_result.json'


describe('analyzeReceipt', () => {
  it('can analyze LCBO receipt', async () => {
    const products = await analyzeReceipt('https://example.com', false, 'lcbo')

    expect(products).toEqual(lcboReceiptProducts)
  })
})