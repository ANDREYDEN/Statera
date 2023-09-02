import { analyzeReceipt } from '../../src/functions/analyzeReceipt'
import lcboReceiptData from '../__stubs__/lcbo_receipt_data.json'
import walmartReceiptData from '../__stubs__/walmart_receipt_data.json'
import walmartReceiptMediumData from '../__stubs__/walmart_receipt_medium/data.json'
import walmartReceiptMediumExpected from '../__stubs__/walmart_receipt_medium/expected.json'

const textDetection = jest.fn()
jest.mock('@google-cloud/vision', () => ({
  ImageAnnotatorClient: jest.fn().mockImplementation(function() {
    return { textDetection }
  }),
}))

describe('analyzeReceipt', () => {
  it('can analyze Walmart receipt', async () => {
    textDetection.mockResolvedValue(walmartReceiptData)
    const products = await analyzeReceipt('https://example.com', 'walmart')

    expect(products).toMatchSnapshot()
  })

  it('can analyze a medium Walmart receipt', async () => {
    textDetection.mockResolvedValue(walmartReceiptMediumData)
    const products = await analyzeReceipt('https://example.com', 'walmart')

    expect(products).toEqual(walmartReceiptMediumExpected)
  })

  it('can analyze LCBO receipt', async () => {
    textDetection.mockResolvedValue(lcboReceiptData)
    const products = await analyzeReceipt('https://example.com', 'lcbo')

    expect(products).toMatchSnapshot()
  })
})
