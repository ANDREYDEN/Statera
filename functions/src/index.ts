import * as vision from "@google-cloud/vision"
import "firebase-functions"
import * as functions from "firebase-functions"
import { firestoreBackup } from "./admin"
import { Product } from "./types/products"
import { defaultStore, walmart } from "./types/stores"
import { verticalSegment } from "./utils"

export const scheduledBackup = firestoreBackup

export const setTimestampOnPaymentCreation = functions.firestore
    .document("payments/{paymentId}")
    .onCreate(async (snap, context) => {
      await snap.ref.update({ timeCreated: snap.createTime })
    })

export const getReceiptDataTest = functions.https.onRequest(
    async (request, response) => {
      const receiptUrl = request.query.receiptUrl
      const isWalmart = request.query.isWalmart
      if (!receiptUrl) {
        response.status(400).send("Parameter receiptUrl is required")
      }

      const result = await analyzeReceipt(
      receiptUrl as string,
      isWalmart === "true"
      )
      response.send(result)
    }
)

export const getReceiptData = functions.https.onCall(async (data, context) => {
  if (!data.receiptUrl) {
    throw Error("The parameter receiptUrl is required.")
  }

  return analyzeReceipt(data.receiptUrl, data.isWalmart)
})

async function analyzeReceipt(
    receiptUrl: string,
    isWalmart: boolean
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
    const labelBox = { ...labelSegment, description: label.description ?? "" }

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
  console.log({ products })

  products = store.filter(products)
  products = store.merge(products)
  console.log({ mergedProducts: products })

  return products
}
