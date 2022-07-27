import * as admin from 'firebase-admin'
import { QueryDocumentSnapshot } from 'firebase-functions/v1/firestore'

export async function removeUserFromGroups(uid: string) {
  const app = admin.app()
  const groupsSnaps = await admin
      .firestore(app)
      .collection('groups')
      .where('memberIds', 'array-contains', uid)
      .get()
  for (const groupDoc of groupsSnaps.docs) {
    const memberIds = groupDoc.data()['memberIds']
    if (memberIds.length === 1) {
      await deleteGroup(groupDoc)
    } else {
      await removeUserFromGroup(uid, groupDoc)
    }
  }
}

async function removeUserFromGroup(uid: string, groupDoc: QueryDocumentSnapshot) {
  const app = admin.app()

  const memberIds = groupDoc.data()['memberIds']
  const members = groupDoc.data()['members']
  const balance = groupDoc.data()['balance']
  try {
    delete balance[uid]
    for (const id of Object.keys(balance)) {
      delete balance[id][uid]
    }
    const newMembers = members.filter((member: { uid: string }) => member.uid !== uid)
    const newMemberIds = memberIds.filter((id: string) => id !== uid)
    await admin
        .firestore(app)
        .collection('groups')
        .doc(groupDoc.id)
        .update({
          memberIds: newMemberIds,
          members: newMembers,
          balance,
        })
  } catch (e) {
    console.log(`Failed to remove user from group (${groupDoc.id}): ${e}`)
  }
}

async function deleteGroup(groupDoc: QueryDocumentSnapshot) {
  const app = admin.app()

  const expenses = await admin
      .firestore(app)
      .collection('expenses')
      .where('groupId', '==', groupDoc.id)
      .get()

  for (const expense of expenses.docs) {
    await admin.firestore(app).collection('expenses').doc(expense.id).delete()
  }
  await admin.firestore(app).collection('groups').doc(groupDoc.id).delete()
}
