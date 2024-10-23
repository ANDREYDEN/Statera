import { analyzeReceipt } from '../../src/functions/analyzeReceipt'
import lcboReceiptShortData from '../__stubs__/receipt_data/lcbo/short/data.json'
import walmartReceiptLongData from '../__stubs__/receipt_data/walmart/long/data.json'
import walmartReceiptMediumData from '../__stubs__/receipt_data/walmart/medium/data.json'
import walmartReceiptMediumExpected from '../__stubs__/receipt_data/walmart/medium/expected.json'
import metroReceiptShortData from '../__stubs__/receipt_data/metro/short/data.json'
import metroReceiptMediumData from '../__stubs__/receipt_data/metro/medium/data.json'

const textDetection = jest.fn()
jest.mock('@google-cloud/vision', () => ({
  ImageAnnotatorClient: jest.fn().mockImplementation(function() {
    return { textDetection }
  }),
}))

describe('analyzeReceipt', () => {
  it('can analyze Walmart receipt', async () => {
    textDetection.mockResolvedValue(walmartReceiptLongData)
    const products = await analyzeReceipt('https://example.com', 'walmart')

    expect(products).toMatchSnapshot()
  })

  it('can analyze a medium Walmart receipt', async () => {
    textDetection.mockResolvedValue(walmartReceiptMediumData)
    const products = await analyzeReceipt('https://example.com', 'walmart')

    expect(products).toEqual(walmartReceiptMediumExpected)
  })

  it('can analyze LCBO receipt', async () => {
    textDetection.mockResolvedValue(lcboReceiptShortData)
    const products = await analyzeReceipt('https://example.com', 'lcbo')

    expect(products).toMatchSnapshot()
  })

  it('can analyze short Metro receipt', async () => {
    textDetection.mockResolvedValue(metroReceiptShortData)
    const products = await analyzeReceipt('https://example.com', 'other')

    expect(products).toMatchSnapshot()
  })

  it('can analyze medium Metro receipt', async () => {
    textDetection.mockResolvedValue(metroReceiptMediumData)
    const products = await analyzeReceipt('https://example.com', 'other')

    expect(products).toMatchSnapshot()
  })
})
