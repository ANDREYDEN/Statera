import * as functions from "firebase-functions";
import * as vision from "@google-cloud/vision";
import * as admin from 'firebase-admin';
import 'firebase-functions';

import serviceAccount from '../serviceAccount.json';
import { ServiceAccount } from "firebase-admin";

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as ServiceAccount)
});

export const quickstart = functions.https.onRequest(async (request, response) => {
  // Creates a client
  const client = new vision.ImageAnnotatorClient();

  // Performs label detection on the image file
  const [result] = await client.textDetection("https://firebasestorage.googleapis.com/v0/b/statera-0.appspot.com/o/receipt.jpg?alt=media&token=ae9766ca-063d-4aad-a510-d168b9dde125");
  const labels = result.textAnnotations;
  response.send(labels?.map((label) => label.description));
});
