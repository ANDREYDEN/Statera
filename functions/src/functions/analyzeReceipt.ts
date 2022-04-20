import * as vision from '@google-cloud/vision'
import { Product } from '../types/products'
import { defaultStore, walmart } from '../types/stores'
import { verticalSegment } from '../utils'

export async function analyzeReceipt(
    receiptUrl: string,
    isWalmart: boolean,
    withNameImprovement?: boolean
): Promise<Product[]> {
  const client = new vision.ImageAnnotatorClient()

  const [result] = await client.textDetection(receiptUrl)

  // first element contains information about all lines
  const labels = result.textAnnotations?.slice(1) ?? []

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
  console.log({ rows })

  const store = isWalmart ? walmart : defaultStore

  let products = store.normalize(rows)
  products = store.filter(products)
  products = store.merge(products)

  if (withNameImprovement) {
    products = await store.improveNaming(products)
  }

  return products
}
