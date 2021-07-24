import * as functions from "firebase-functions";
import * as vision from "@google-cloud/vision";
import * as admin from 'firebase-admin';
import 'firebase-functions';
admin.initializeApp();

// const serviceAccount = require('./serviceAccount.json');

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

export const quickstart = functions.https.onRequest(async (request, response) => {
  // Creates a client
  const client = new vision.ImageAnnotatorClient();

  // Performs label detection on the image file
  const [result] = await client.textDetection("https://firebasestorage.googleapis.com/v0/b/statera-0.appspot.com/o/receipt.jpg?alt=media&token=ae9766ca-063d-4aad-a510-d168b9dde125");
  const labels = result.textAnnotations;
  console.log("Text:");
  response.send(labels?.map((label) => label.description));
});


// const adminConfig = JSON.parse(process.env.FIREBASE_CONFIG ?? '');
// adminConfig.credential = admin.credential.cert(serviceAccount);
// admin.initializeApp(adminConfig);



