import { UserData } from '../../types/userData'
import * as admin from 'firebase-admin'
import { auth } from 'firebase-admin'
import { propertyChanged } from '../../utils'

export async function updateUser(userId: string, oldUserData: UserData, newUserData: UserData) {
  const targetPropertyChanged = propertyChanged(oldUserData, newUserData, 'name', 'photoURL', 'paymentMethod')

  if (targetPropertyChanged) {
    try {
      await updateUsersInGroups(userId, newUserData)
    } catch (e: any) {
      console.log(`Something went wrong while updating user in groups: ${e.toString()}`)
    }

    try {
      await updateAuthUser(userId, newUserData)
    } catch (e: any) {
      console.log(`Something went wrong while updating user in Auth: ${e.toString()}`)
    }
  }
}

async function updateUsersInGroups(userId: string, userData: UserData) {
  const groupsSnap = await admin.firestore()
      .collection('groups')
      .where('memberIds', 'array-contains', userId)
      .get()

  for (const groupDoc of groupsSnap.docs) {
    const members = groupDoc.data().members.map((member: any) => {
      if (member.uid === userId) {
        return { ...member, name: userData.name, photoURL: userData.photoURL }
      }
      return member
    })

    await groupDoc.ref.update({ members })
    console.log(`Updated user in group ${groupDoc.id}`)
  }
}

async function updateAuthUser(userId: string, userData: UserData) {
  await auth().updateUser(userId, {
    photoURL: userData.photoURL,
    displayName: userData.name,
  })
  console.log(`Updated auth user ${userId}`)
}
