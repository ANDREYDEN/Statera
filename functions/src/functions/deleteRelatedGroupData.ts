import * as admin from 'firebase-admin'

export async function deleteRelatedGroupData(groupId: string): Promise<void> {
  const expenseQuerySnap = await admin.firestore()
    .collection('expenses')
    .where('groupId', '==', groupId)
    .get()

  for (const expenseDoc of expenseQuerySnap.docs) {
    await expenseDoc.ref.delete()
  }
}
