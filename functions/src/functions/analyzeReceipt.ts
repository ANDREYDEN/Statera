import { ImageAnnotatorClient } from '@google-cloud/vision'
import { google } from '@google-cloud/vision/build/protos/protos'
import { max, min } from 'lodash'
import { BoxWithText, RowOfText, Vector } from '../types/geometry'
import { Product } from '../types/products'
import { defaultStore, StoreName, stores } from '../types/stores'
import { isWithin, rotateToHorizontal, sub, toBoxWithText } from '../utils/geometryUtils'
import { avg } from '../utils/mathUtils'

type IEntityAnnotation = google.cloud.vision.v1.IEntityAnnotation
export type IAnnotateResponse = google.cloud.vision.v1.IAnnotateImageResponse

export async function analyzeReceipt(
  receiptUrl: string,
  storeName: StoreName,
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

function buildRows(response: IAnnotateResponse): RowOfText[] {
  // first element contains information about all lines
  const annotations = response.textAnnotations?.slice(1) ?? []
  console.log(`Detected ${annotations.length} text parts`)

  const horizontalAnnotations = fixVerticalAnnotations(annotations)
  const boxesWithText = horizontalAnnotations.map(toBoxWithText)
  const leveledBoxesWithText = rotateAnnotations(boxesWithText)

  console.log({ leveledBoxesWithText: leveledBoxesWithText.map((b) => ({ ty: b.top.y, by: b.bottom.y, cy: b.center.y, content: b.content })) })

  let rows: BoxWithText[][] = []
  leveledBoxesWithText.forEach((boxWithText) => {
    for (const row of rows) {
      if (isWithin(boxWithText.center.y, row[0])) {
        row.push(boxWithText)
        return
      }
    }

    rows.push([boxWithText])
  })

  rows = rows.map((row) =>
    row.sort((element1, element2) => element1.center.x - element2.center.x)
  )
  rows.sort((row1, row2) => row1[0].top.y - row2[0].top.y)

  const avgRowStart = min(rows.map((row) => row[0].left.x)) ?? 0
  const avgRowEnd = max(rows.map((row) => row[row.length - 1].right.x)) ?? 0
  const receiptMiddle = (avgRowStart + avgRowEnd) / 2

  return rows.map((row) => ({
    leftText: row.filter((box) => box.left.x < receiptMiddle).map((box) => box.content ?? ''),
    rightText: row.filter((box) => box.left.x >= receiptMiddle).map((box) => box.content ?? ''),
  }))
}

function fixVerticalAnnotations(labels: IEntityAnnotation[]): IEntityAnnotation[] {
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

  console.log('Flipping annotations...')
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

function rotateAnnotations(annotations: BoxWithText[]): BoxWithText[] {
  const directions = annotations.map(getBoxDirection)
  const avgDirection: Vector = {
    x: avg(...directions.map((d) => d.x)),
    y: avg(...directions.map((d) => d.y)),
  }
  if (!avgDirection) return []

  console.log('TEST', JSON.stringify(rotateToHorizontal({
    top: { y: 3.5, x: 1.5 },
    bottom: { y: 4.5, x: 2.5 },
    right: { y: 3.5, x: 2.5 },
    left: { y: 4.5, x: 1.5 },
    center: { y: 4, x: 2 },
    content: 'test',
  }), null, 2))
  return annotations.map(rotateToHorizontal)
}

function getBoxDirection(boxWithText: BoxWithText): Vector {
  return sub(boxWithText.right, boxWithText.left)
}
