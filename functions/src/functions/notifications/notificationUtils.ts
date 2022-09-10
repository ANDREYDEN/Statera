import { firestore } from 'firebase-admin';

export async function getGroupNotificationTokens(group: firestore.DocumentSnapshot<firestore.DocumentData>) {
  const userIds = (group?.data()?.memberIds ?? []) as string[]
  console.log(`Sending notifications to ${userIds.join(', ')}`)
  
  return getUsersNotificationTokens(userIds)
}

export async function getExpenseNotificationTokens(expense: firestore.DocumentSnapshot<firestore.DocumentData>, authorIncluded = false) {
  const assigneeIds = (expense?.data()?.assigneeIds ?? []) as string[]
  const authorId = (expense?.data()?.author.uid ?? []) as string
  const targetUserIds = assigneeIds.filter(uid => uid !== authorId)
  console.log(`Sending notifications to ${targetUserIds.join(', ')}`)
  
  return getUsersNotificationTokens(assigneeIds)
}

export async function getUsersNotificationTokens(uids: string[]) {
  const userDocs = await Promise.all(uids.map(uid => firestore().collection('users').doc(uid).get()))
  return userDocs.flatMap(doc => Object.keys(doc.data()?.notifications ?? {}))
}

export async function getUserNotificationTokens(uid: string) {
  const userDoc = await firestore().collection('users').doc(uid).get()
  return Object.keys(userDoc.data()?.notifications ?? {})
}