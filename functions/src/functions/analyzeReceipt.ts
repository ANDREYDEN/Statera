import { ImageAnnotatorClient } from '@google-cloud/vision'
import { Product } from '../types/products'
import { defaultStore, stores } from '../types/stores'
import { verticalSegment } from '../utils'
import { VerticalSegment } from '../types/geometry'

export async function analyzeReceipt(
    receiptUrl: string,
    isWalmart: boolean, // TODO: deprecate
    storeName: string,
    withNameImprovement?: boolean
): Promise<Product[]> {
  console.log(`Analyzing receipt at ${receiptUrl}`)
  const client = new ImageAnnotatorClient()

  console.log('Reading text from the image...')
  const [result] = await client.textDetection(receiptUrl)

  // first element contains information about all lines
  const labels = result.textAnnotations?.slice(1) ?? []
  console.log(labels.length > 0 ?
    `This image has some text: ${labels.length}` :
    'This image has no text')

  type LabelBox = VerticalSegment & { description: string }
  let lines: LabelBox[][] = []

  labels.forEach((label) => {
    const labelSegment = verticalSegment(label)
    const center = (labelSegment.yTop + labelSegment.yBottom) / 2
    const labelBox = { ...labelSegment, description: label.description ?? '' }

    for (const line of lines) {
      if (line[0].yTop < center && center < line[0].yBottom) {
        line.push(labelBox)
        return
      }
    }

    lines.push([labelBox])
  })

  lines = lines.map((line) => line.sort((line1, line2) => line1.x - line2.x))

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
