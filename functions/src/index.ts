/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions";
import * as vision from "@google-cloud/vision";
import "firebase-functions";
import { mergeProducts, normalize} from "./normalizers";

export const getReceiptDataTest = functions.https.onRequest(
    async (request, response) => {
      const receiptUrl = request.query.receiptUrl;
      if (!receiptUrl) {
        response.status(400).send("Parameter receiptUrl is required");
      }

      const result = await analyzeReceipt(receiptUrl as string);
      response.send(result);
    }
);

export const getReceiptData = functions.https.onCall(async (data, context) => {
  if (!data.receiptUrl) {
    throw Error("The parameter receiptUrl is required.");
  }

  return analyzeReceipt(data.receiptUrl);
});

async function analyzeReceipt(receiptUrl: string): Promise<any[]> {
  const client = new vision.ImageAnnotatorClient();

  const [result] = await client.textDetection(receiptUrl);
  const labels = result.textAnnotations ?? [];

  const lines: Map<number, any[]> = new Map();

  console.log(JSON.stringify(labels));
  
  labels.forEach((label) => {
    const THRESHOLD = 12;
    const labelHeight = baselineHeight(label);

    let similarHeight = labelHeight;
    for (const height of lines.keys()) {
      if (Math.abs(labelHeight - height) < THRESHOLD) {
        similarHeight = height;
      }
    }

    const previousValue = lines.has(similarHeight) ? lines.get(similarHeight)! : [];
    lines.set(similarHeight, [...previousValue, label.description]);
  });

  // first element contains information about all lines
  const rows = Array.from(lines.values()).slice(1);

  let products = rows.map(normalize);

  products = mergeProducts(products);
  console.log(products);
  
  return products;
}

function baselineHeight(label: any): number {
  const corners = label.boundingPoly.vertices;
  const sortedCorners = corners.sort((corner: any, otherCorner: any) => otherCorner.y - corner.y);
  return (sortedCorners[0].y + sortedCorners[1].y) / 2;
}
