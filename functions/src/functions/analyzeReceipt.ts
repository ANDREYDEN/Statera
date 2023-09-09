import { ImageAnnotatorClient } from '@google-cloud/vision'
import { Product } from '../types/products'
import { defaultStore, stores } from '../types/stores'
import { verticalSegment } from '../utils'
import { google } from '@google-cloud/vision/build/protos/protos'
import { VerticalSegment } from '../types/geometry'

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
  const longLabel = labels.find((l) => l.description?.length && l.description.length > 5)
  const longLabelVertices = longLabel?.boundingPoly?.vertices
  if (!longLabelVertices || longLabelVertices.length != 4) return labels

  const xCoords = longLabel.boundingPoly!.vertices!.map(v => v.x).sort((a, b) => a! - b!)
  const yCoords = longLabel.boundingPoly!.vertices!.map(v => v.y).sort((a, b) => a! - b!)
  const longLabelWidth = (xCoords[2]! + xCoords[3]!) / 2 - (xCoords[0]! + xCoords[1]!) / 2
  const longLabelHeight = (yCoords[2]! + yCoords[3]!) / 2 - (yCoords[0]! + yCoords[1]!) / 2
  const needsRotation = longLabelWidth < longLabelHeight
  if (!needsRotation) return labels

  console.log('Rotating labels...')
  return labels.map((l) => {
    const rotatedVertices = l.boundingPoly?.vertices?.map((v) => ({ x: v.y, y: v.x }))

    return {
      ...l,
      boundingPoly: {
        vertices: rotatedVertices,
      },
    }
  })
}

function buildRows(response: IAnnotateResponse): string[][] {
  // first element contains information about all lines
  const labels = response.textAnnotations?.slice(1) ?? []

  
  console.log(labels.length > 0 ?
    `This image has some text: ${labels.length}` :
    'This image has no text')
  
    const orientedLabels = rotateLabels(labels)
    
  type LabelBox = VerticalSegment & { description: string }
  let lines: LabelBox[][] = []

  orientedLabels.forEach((label) => {
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
