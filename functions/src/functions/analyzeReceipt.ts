import { ImageAnnotatorClient } from '@google-cloud/vision'
import { Product } from '../types/products'
import { defaultStore, stores } from '../types/stores'
import { verticalSegment } from '../utils'
import { VerticalSegment } from '../types/geometry'
import { google } from '@google-cloud/vision/build/protos/protos'

type IAnnotateResponse = google.cloud.vision.v1.IAnnotateImageResponse

export async function analyzeReceipt(
    receiptUrl: string,
    isWalmart: boolean, // TODO: deprecate
    storeName: string,
    withNameImprovement?: boolean
): Promise<Product[]> {
  console.log(`Analyzing receipt at ${receiptUrl}`)
  console.log('Reading text from the image...')

  const client = new ImageAnnotatorClient()
  const [result] = await client.textDetection(receiptUrl)

  const rows = buildRows(result)
  console.log('Image text data:', rows)

  const store = isWalmart ? stores.walmart : stores[storeName] ?? defaultStore

  let products = store.normalize(rows)
  console.log('Normalized products:', products)
  products = store.merge(products)
  products = store.filter(products)
  console.log('Filtered products:', products)

  if (withNameImprovement) {
    console.log('Applying name improvements...')
    products = await store.improveNaming(products)
  }

  return products
}

function buildRows(response: IAnnotateResponse): string[][] {
  // first element contains information about all lines
  const labels = response.textAnnotations?.slice(1) ?? []

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

  lines = lines.map((line) => line.sort((element1, element2) => element1.x - element2.x))
  lines = lines.sort((line1, line2) => line1[0].yTop - line2[0].yTop)

  return lines.map((line) => line.map((label) => label.description))
}
