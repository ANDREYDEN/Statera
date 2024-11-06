import { analyzeReceipt, IAnnotateResponse } from '../../src/functions/analyzeReceipt'
import lcboReceiptShortData from '../__stubs__/receipt_data/lcbo/short/data.json'
import walmartReceiptLongData from '../__stubs__/receipt_data/walmart/long/data.json'
import walmartReceiptMediumData from '../__stubs__/receipt_data/walmart/medium/data.json'
import walmartReceiptMediumExpected from '../__stubs__/receipt_data/walmart/medium/expected.json'
import metroReceiptShortData from '../__stubs__/receipt_data/metro/short/data.json'
import metroReceiptMediumData from '../__stubs__/receipt_data/metro/medium/data.json'
import tiltedReceiptRightData from '../__stubs__/receipt_data/tilted/tilted_right/data.json'
import tiltedReceiptLeftData from '../__stubs__/receipt_data/tilted/tilted_left/data.json'
import { StoreName } from '../../src/types/stores'

const textDetection = jest.fn()
jest.mock('@google-cloud/vision', () => ({
  ImageAnnotatorClient: jest.fn().mockImplementation(function() {
    return { textDetection }
  }),
}))

describe('analyzeReceipt', () => {
  it('can analyze a medium Walmart receipt', async () => {
    textDetection.mockResolvedValue(walmartReceiptMediumData)
    const products = await analyzeReceipt('https://example.com', 'walmart')

    expect(products).toEqual(walmartReceiptMediumExpected)
  })

  it.each<{ title: string, visionResponse: IAnnotateResponse[], store: StoreName }>([
    { title: 'long Walmart', visionResponse: walmartReceiptLongData, store: 'walmart' },
    { title: 'short LCBO', visionResponse: lcboReceiptShortData, store: 'lcbo' },
    { title: 'short Metro', visionResponse: metroReceiptShortData, store: 'metro' },
    { title: 'medium Metro', visionResponse: metroReceiptMediumData, store: 'metro' },
    { title: 'tilted to left', visionResponse: tiltedReceiptLeftData, store: 'metro' },
    { title: 'tilted to right', visionResponse: tiltedReceiptRightData, store: 'metro' },
  ])('can analyze $title receipt', async ({ visionResponse, store }) => {
    textDetection.mockResolvedValue(visionResponse)
    const products = await analyzeReceipt('https://example.com', store)

    expect(products).toMatchSnapshot()
  })
})
