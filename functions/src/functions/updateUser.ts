import { UserData } from "../types/userData"
import * as admin from 'firebase-admin'

export async function updateUser(userId: string, userData: UserData) {
  const groupsSnap = await admin.firestore()
    .collection('groups')
    .where('memberIds', 'array-contains', userId)
    .get();

  for(const groupDoc of groupsSnap.docs) {
    const members = groupDoc.data().members.map((member: any) => {
      return member.uid === userId ? { ...member, ...userData } : member
    })

    await groupDoc.ref.update({ members })
  }
}