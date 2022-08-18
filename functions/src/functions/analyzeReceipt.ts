import * as vision from '@google-cloud/vision'
import { Product } from '../types/products'
import { defaultStore, stores } from '../types/stores'
import { verticalSegment } from '../utils'

export async function analyzeReceipt(
    receiptUrl: string,
    isWalmart: boolean, //TODO: deprecate
    storeName: string,
    withNameImprovement?: boolean
): Promise<Product[]> {
  console.log(`Analyzing receipt at ${receiptUrl}`)
  const client = new vision.ImageAnnotatorClient()

  console.log('Reading text from the image...')
  const [result] = await client.textDetection(receiptUrl)

  // first element contains information about all lines
  const labels = result.textAnnotations?.slice(1) ?? []
  console.log(labels.length > 0 ?
    `This image has some text: ${labels.length}` :
    'This image has no text')

  type LabelBox = { p1: number; p2: number; description: string }
  const lines: LabelBox[][] = []

  labels.forEach((label) => {
    const labelSegment = verticalSegment(label)
    const center = (labelSegment.p1 + labelSegment.p2) / 2
    const labelBox = { ...labelSegment, description: label.description ?? '' }

    for (const line of lines) {
      if (line[0].p1 < center && center < line[0].p2) {
        line.push(labelBox)
        return
      }
    }

    lines.push([labelBox])
  })

  const rows = lines.map((line) => line.map((label) => label.description))
  console.log('Raw image text data:', rows)

  const store = isWalmart ? stores.walmart : stores[storeName] ?? defaultStore

  let products = store.normalize(rows)
  products = store.filter(products)
  products = store.merge(products)

  if (withNameImprovement) {
    console.log('Applying name improvements...')
    products = await store.improveNaming(products)
  }

  return products
}
