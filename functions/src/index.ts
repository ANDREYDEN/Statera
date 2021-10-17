/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions";
import * as vision from "@google-cloud/vision";
// import * as admin from "firebase-admin";
import "firebase-functions";
import { mergeProducts, normalize } from "./normalizers";
import { firestoreBackup } from "./admin";

// admin.initializeApp();
// const db = admin.firestore();

export const scheduledBackup = firestoreBackup;

// export const updateBalanceOnExpenseCompletion = functions.firestore
//   .document("expenses/{expenseId}")
//   .onUpdate(async (change, context) => {
//     const logWithReason = (reason: string) =>
//       `[eid: ${context.params.expenseId}] Balance not updated: ${reason}`;
//     const expense = change.after.data();
//     if (expense.completedDate) {
//       logWithReason("Expense has already been completed");
//       return;
//     }
//     const isCompleted = expense.items.every((item: any) =>
//       item.assignees.every((assignee: any) => assignee.decision !== "Undefined")
//     );

//     if (!isCompleted) {
//       logWithReason("Expense has not been completed yet");
//       return;
//     }

//     const groupDoc = await db.collection("groups").doc(expense.groupId).get();
//     if (!groupDoc.exists) {
//       logWithReason("Expense does not have a group");
//     }
//     const group = groupDoc.data()!;

//     // update the balance

//     await groupDoc.ref.update(group);
//   });

export const setTimestampOnPaymentCreation = functions.firestore
  .document("payments/{paymentId}")
  .onCreate(async (snap, context) => {
    await snap.ref.update({ timeCreated: snap.createTime });
  });

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

  // first element contains information about all lines
  const labels = result.textAnnotations?.slice(1) ?? [];

  type LabelBox = { p1: number; p2: number; description: string };
  const lines: LabelBox[][] = [];

  labels.forEach((label) => {
    const labelSegment = verticalSegment(label);
    const center = (labelSegment.p1 + labelSegment.p2) / 2;
    const labelBox = { ...labelSegment, description: label.description ?? "" };

    for (const line of lines) {
      if (line[0].p1 < center && center < line[0].p2) {
        line.push(labelBox);
        return;
      }
    }

    lines.push([labelBox]);
  });

  const rows = lines.map((line) => line.map((label) => label.description));
  console.log(rows);

  let products = rows.map(normalize);

  products = mergeProducts(products);
  console.log(products);

  return products;
}

function verticalSegment(label: any): { p1: number; p2: number } {
  const corners = label.boundingPoly.vertices;
  const sortedCorners = corners.sort(
    (corner: any, otherCorner: any) => corner.y - otherCorner.y
  );
  return {
    p1: (sortedCorners[0].y + sortedCorners[1].y) / 2,
    p2: (sortedCorners[2].y + sortedCorners[3].y) / 2,
  };
}
