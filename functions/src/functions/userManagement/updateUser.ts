import { UserData } from '../../types/userData'
import * as admin from 'firebase-admin'
import { auth } from 'firebase-admin'
import { propertyChanged } from '../../utils'

export async function updateUser(userId: string, oldUserData: UserData, newUserData: UserData) {
  const targetPropertyChanged = propertyChanged(oldUserData, newUserData, 'name', 'photoURL', 'paymentInfo')

  console.log('updateUser params', { userId, oldUserData, newUserData, targetPropertyChanged })
  if (targetPropertyChanged) {
    try {
      await updateUsersInGroups(userId, newUserData)
    } catch (e) {
      console.error('Something went wrong while updating user in groups', e)
    }

    try {
      await updateAuthUser(userId, newUserData)
    } catch (e) {
      console.error('Something went wrong while updating user in Auth', e)
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
        return {
          ...member,
          name: userData.name,
          photoURL: userData.photoURL,
          paymentInfo: userData.paymentInfo,
        }
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
  log(`Updated auth user ${userId}`)
}
