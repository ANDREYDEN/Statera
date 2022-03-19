/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions"
import firestore from "@google-cloud/firestore"
const client = new firestore.v1.FirestoreAdminClient()

const bucket = "gs://statera-firestore-backup"

export const firestoreBackup = functions.pubsub
    .schedule("0 0 1 * *")
    .onRun(async (context) => {
      const projectId: string | undefined =
      process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT
      if (!projectId) throw new Error("Project ID not specified")

      const databaseName = client.databasePath(projectId, "(default)")

      try {
        const responses = await client.exportDocuments({
          name: databaseName,
          outputUriPrefix: bucket,
        })
        const response = responses[0]
        console.log(`Operation Name: ${response["name"]}`)
        return responses
      } catch (err) {
        console.error(err)
        throw new Error("Export operation failed")
      }
    })
