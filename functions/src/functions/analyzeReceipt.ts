import { ImageAnnotatorClient } from '@google-cloud/vision'
import { google } from '@google-cloud/vision/build/protos/protos'
import { max, min } from 'lodash'
import { BoxWithText, RowOfText } from '../types/geometry'
import { Product } from '../types/products'
import { defaultStore, stores } from '../types/stores'
import { center, isWithin, toBoxWithText } from '../utils/geometryUtils'

type IEntityAnnotation = google.cloud.vision.v1.IEntityAnnotation
type IAnnotateResponse = google.cloud.vision.v1.IAnnotateImageResponse

export async function analyzeReceipt(
  receiptUrl: string,
  storeName: string,
  withNameImprovement?: boolean
): Promise<Product[]> {
  console.log(`Analyzing receipt at ${receiptUrl}`)
  console.log('Reading text from the image...')

  const client = new ImageAnnotatorClient()
  const [result] = await client.textDetection(receiptUrl)

  const rows = buildRows(result)
  console.log('Image text data:', rows)

  const store = stores[storeName] ?? defaultStore

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

function rotateLabels(labels: IEntityAnnotation[]) {
  const longLabel = labels.find(
    (l) => l.description?.length && l.description.length > 5
  )
  const longLabelVertices = longLabel?.boundingPoly?.vertices
  if (!longLabelVertices || longLabelVertices.length != 4) return labels

  const xCoords = longLabel
    .boundingPoly!.vertices!.map((v) => v.x)
    .sort((a, b) => a! - b!)
  const yCoords = longLabel
    .boundingPoly!.vertices!.map((v) => v.y)
    .sort((a, b) => a! - b!)
  const longLabelWidth =
    (xCoords[2]! + xCoords[3]!) / 2 - (xCoords[0]! + xCoords[1]!) / 2
  const longLabelHeight =
    (yCoords[2]! + yCoords[3]!) / 2 - (yCoords[0]! + yCoords[1]!) / 2
  const needsRotation = longLabelWidth < longLabelHeight
  if (!needsRotation) return labels

  console.log('Rotating labels...')
  return labels.map((l) => {
    const rotatedVertices = l.boundingPoly?.vertices?.map((v) => ({
      x: v.y,
      y: v.x,
    }))

    return {
      ...l,
      boundingPoly: {
        vertices: rotatedVertices,
      },
    }
  })
}

function buildRows(response: IAnnotateResponse): RowOfText[] {
  // first element contains information about all lines
  const annotations = response.textAnnotations?.slice(1) ?? []

  console.log(
    annotations.length > 0 ?
      `This image has some text: ${annotations.length}` :
      'This image has no text'
  )

  const orientedAnnotations = rotateLabels(annotations)

  let rows: BoxWithText[][] = []
  orientedAnnotations.forEach((annotation) => {
    const boxWithText = toBoxWithText(annotation)

    for (const line of rows) {
      if (isWithin(center(boxWithText), line[0])) {
        line.push(boxWithText)
        return
      }
    }

    rows.push([boxWithText])
  })

  rows = rows.map((row) =>
    row.sort((element1, element2) => element1.x - element2.x)
  )
  rows.sort((row1, row2) => row1[0].yTop - row2[0].yTop)

  const avgRowStart = min(rows.map((row) => row[0].xLeft)) ?? 0
  const avgRowEnd = max(rows.map((row) => row[row.length - 1].xRight)) ?? 0
  const receiptMiddle = (avgRowStart + avgRowEnd) / 2

  return rows.map((row) => ({
    leftText: row.filter((box) => box.xLeft < receiptMiddle).map((box) => box.content ?? ''),
    rightText: row.filter((box) => box.xLeft >= receiptMiddle).map((box) => box.content ?? ''),
  }))
}
