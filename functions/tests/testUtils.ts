import * as admin from 'firebase-admin'
import { CollectionReference } from 'firebase-admin/firestore'

export async function deleteAllData() {
  const collections = await admin.firestore().listCollections()
  for (const collectionRef of collections) {
    await deleteCollection(collectionRef)
  }
}

async function deleteCollection(colRef: CollectionReference) {
  const docs = await colRef.listDocuments()
  for (const docRef of docs) {
    const subCollections = await docRef.listCollections()
    for (const subColRef of subCollections) {
      await deleteCollection(subColRef)
    }
    await docRef.delete()
  }
}
