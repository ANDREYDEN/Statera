import lcboReceiptData from '../../../__stubs__/lcbo_receipt_data.json'

export class ImageAnnotatorClient {
  constructor() {}

  async textDetection(url: string) {
    return Promise.resolve(lcboReceiptData)
  }
}