import { ImageAnnotatorClient } from '@google-cloud/vision'
import { google } from '@google-cloud/vision/build/protos/protos'
import { max, min } from 'lodash'
import { BoxWithText, RowOfText } from '../types/geometry'
import { Product } from '../types/products'
import { defaultStore, StoreName, stores } from '../types/stores'
import { distanceToRow, height, toBoxWithText } from '../utils/geometryUtils'
import fetch from 'node-fetch'

type IEntityAnnotation = google.cloud.vision.v1.IEntityAnnotation
export type IAnnotateResponse = google.cloud.vision.v1.IAnnotateImageResponse

export async function analyzeReceipt(
  receiptUrl: string,
  storeName: StoreName,
  withNameImprovement?: boolean
): Promise<Product[]> {
  console.log(`Analyzing receipt at ${receiptUrl}`)
  console.log('Reading text from the image...')

  const annotationResponse = await getTextDataFromImage(receiptUrl)
  const rows = buildRows(annotationResponse)
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

async function getTextDataFromImage(url: string): Promise<IAnnotateResponse> {
  const safeUrl = url.replace('localhost', '127.0.0.1')
  const response = await fetch(safeUrl)
  const buffer = await response.buffer()
  const client = new ImageAnnotatorClient()
  const [result] = await client.documentTextDetection(buffer)
  return result
}

function buildRows(response: IAnnotateResponse): RowOfText[] {
  const annotations = getWordAnnotations(response)
  console.log(`Detected ${annotations.length} text parts`)

  const horizontalAnnotations = fixVerticalAnnotations(annotations)
  const boxesWithText = horizontalAnnotations.map(toBoxWithText)
  let rows = placeBoxesIntoRows(boxesWithText)

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

function placeBoxesIntoRows(boxes: BoxWithText[]): BoxWithText[][] {
  const rows: BoxWithText[][] = []
  boxes.forEach((box) => {
    const minDist = height(box)
    let chosenRow = null
    for (const row of rows) {
      const curDist = distanceToRow(row, box)
      if (curDist < minDist) {
        chosenRow = row
      }
    }
    if (chosenRow) {
      chosenRow.push(box)
    } else {
      rows.push([box])
    }
  })

  return rows
}

function getWordAnnotations(response: IAnnotateResponse): IEntityAnnotation[] {
  const page = response.fullTextAnnotation?.pages?.[0]
  if (!page) return []
  return page.blocks
    ?.flatMap((block) => block.paragraphs
      ?.flatMap((para) => para.words
        ?.map((word) => ({
          boundingPoly: word.boundingBox,
          description: word.symbols
            ?.map((s) => s.text)
            .join(''),
        })) ?? []
      ) ?? [],
    ) ?? []
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
