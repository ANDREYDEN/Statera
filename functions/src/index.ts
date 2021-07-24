import * as functions from "firebase-functions";
import * as vision from "@google-cloud/vision";
import "firebase-functions";

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

async function analyzeReceipt(receiptUrl: string): Promise<string[]> {
  const client = new vision.ImageAnnotatorClient();

  const [result] = await client.textDetection(receiptUrl);
  const labels = result.textAnnotations ?? [];
  
  return labels.map((label) => label.description ?? 'UNRECOGNIZABLE');
}
