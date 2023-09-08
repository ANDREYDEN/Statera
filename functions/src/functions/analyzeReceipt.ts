import { ImageAnnotatorClient } from '@google-cloud/vision'
import { Product } from '../types/products'
import { defaultStore, stores } from '../types/stores'
import { verticalSegment } from '../utils'
import { google } from '@google-cloud/vision/build/protos/protos'

type IEntityAnnotation = google.cloud.vision.v1.IEntityAnnotation

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
  // console.log('Text read from the image:', labels.map((l) => ({ text: l.description, vertices: l.boundingPoly?.vertices?.map(v => `(${v.x},${v.y})`).join(' ') })))

  const orientedLabels = rotateLabels(labels)
  
  console.log(labels.length > 0 ?
    `This image has some text: ${labels.length}` :
    'This image has no text')

  type LabelBox = { p1: number; p2: number; description: string }
  const lines: LabelBox[][] = []

  orientedLabels.forEach((label) => {
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
  }
}
