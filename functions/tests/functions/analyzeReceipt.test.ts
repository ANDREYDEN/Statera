import {
  analyzeReceipt,
  IAnnotateResponse,
} from '../../src/functions/analyzeReceipt'
import lcboReceiptShortData from '../__stubs__/receipt_data/lcbo/short/data.json'
import walmartReceiptLongData from '../__stubs__/receipt_data/walmart/long/data.json'
import walmartReceiptMediumData from '../__stubs__/receipt_data/walmart/medium/data.json'
import walmartReceiptMediumExpected from '../__stubs__/receipt_data/walmart/medium/expected.json'
import metroReceiptShortData from '../__stubs__/receipt_data/metro/short/data.json'
import metroReceiptMediumData from '../__stubs__/receipt_data/metro/medium/data.json'
import tiltedReceiptRightData from '../__stubs__/receipt_data/tilted/tilted_right/data.json'
import tiltedReceiptLeftData from '../__stubs__/receipt_data/tilted/tilted_left/data.json'
import { StoreName } from '../../src/types/stores'

const documentTextDetection = jest.fn()
jest.mock('@google-cloud/vision', () => ({
  ImageAnnotatorClient: jest.fn().mockImplementation(function() {
    return { documentTextDetection }
  }),
}))

jest.mock(
  'node-fetch',
  () => () =>
    Promise.resolve({
      arrayBuffer: jest.fn().mockResolvedValue(new ArrayBuffer(8)),
    })
)

describe('analyzeReceipt', () => {
  it('can analyze a medium Walmart receipt', async () => {
    documentTextDetection.mockResolvedValue([walmartReceiptMediumData])
    const products = await analyzeReceipt('https://example.com', 'walmart')

    expect(products).toEqual(walmartReceiptMediumExpected)
  })

  it.each<{
    title: string
    visionResponse: IAnnotateResponse
    store: StoreName
  }>([
    {
      title: 'long Walmart',
      visionResponse: walmartReceiptLongData as IAnnotateResponse,
      store: 'walmart',
    },
    {
      title: 'short LCBO',
      visionResponse: lcboReceiptShortData as IAnnotateResponse,
      store: 'lcbo',
    },
    {
      title: 'short Metro',
      visionResponse: metroReceiptShortData as IAnnotateResponse,
      store: 'metro',
    },
    {
      title: 'medium Metro',
      visionResponse: metroReceiptMediumData as IAnnotateResponse,
      store: 'metro',
    },
    {
      title: 'tilted to left',
      visionResponse: tiltedReceiptLeftData as IAnnotateResponse,
      store: 'metro',
    },
    {
      title: 'tilted to right',
      visionResponse: tiltedReceiptRightData as IAnnotateResponse,
      store: 'metro',
    },
  ])('can analyze $title receipt', async ({ visionResponse, store }) => {
    documentTextDetection.mockResolvedValue([visionResponse])
    const products = await analyzeReceipt('https://example.com', store)

    expect(products).toMatchSnapshot()
  })
})
