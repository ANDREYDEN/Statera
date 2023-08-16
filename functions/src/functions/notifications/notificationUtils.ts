import { firestore } from 'firebase-admin'

export async function getGroupNotificationTokens(group: firestore.DocumentSnapshot<firestore.DocumentData>) {
  const userIds = (group?.data()?.memberIds ?? []) as string[]
  console.log(`Sending notifications to ${userIds.join(', ')}`)

  return getUsersNotificationTokens(userIds)
}

export async function getExpenseNotificationTokens(expense: firestore.DocumentSnapshot<firestore.DocumentData>) {
  const assigneeIds = (expense?.data()?.assigneeIds ?? []) as string[]
  const authorId = (expense?.data()?.authorUid ?? []) as string
  const targetUserIds = assigneeIds.filter((uid) => uid !== authorId)
  console.log(`Sending notifications to ${targetUserIds.join(', ')}`)

  const tokens = await getUsersNotificationTokens(targetUserIds)
  console.log('Retrieved tokens:', tokens)
  return tokens
}

export async function getUsersNotificationTokens(uids: string[]) {
  const userDocs = await Promise.all(uids.map((uid) => firestore().collection('users').doc(uid).get()))
  return userDocs.flatMap((doc) =>
    Object.values(doc.data()?.notifications ?? {})
      .map((platform: any) => platform.token)
  )
}

export async function getUserNotificationTokens(uid: string) {
  const userDoc = await firestore().collection('users').doc(uid).get()
  return Object.values(userDoc.data()?.notifications ?? {})
    .map((platform: any) => platform.token)
}
