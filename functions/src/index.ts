import * as functions from "firebase-functions";
import * as vision from "@google-cloud/vision";
import "firebase-functions";

export const quickstart = functions.https.onRequest(
  async (request, response) => {
    if (!request.query.receiptUrl) {
      response.status(400).send("Parameter receiptUrl is required");
    }
    // Creates a client
    const client = new vision.ImageAnnotatorClient();

    // Performs label detection on the image file
    const [result] = await client.textDetection(
      request.query.receiptUrl as string
    );
    const labels = result.textAnnotations;
    response.send(labels?.map((label) => label.description));
  }
);
