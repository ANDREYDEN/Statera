import * as admin from 'firebase-admin'
import { QueryDocumentSnapshot } from 'firebase-functions/v1/firestore'
import { Expense } from '../../types/expense'

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
      console.log('Removing user from group...')
      await removeUserFromGroup(uid, groupDoc)

      console.log('Removing user from outstanding expenses...')
      await removeUserFromOutstandingExpenses(uid, groupDoc.id)
    }
  }
}

async function removeUserFromGroup(
  uid: string,
  groupDoc: QueryDocumentSnapshot
) {
  const memberIds = groupDoc.data()['memberIds']
  const members = groupDoc.data()['members']
  const balance = groupDoc.data()['balance']
  try {
    delete balance[uid]
    for (const id of Object.keys(balance)) {
      delete balance[id][uid]
    }
    const newMembers = members.filter(
      (member: { uid: string }) => member.uid !== uid
    )
    const newMemberIds = memberIds.filter((id: string) => id !== uid)
    groupDoc.ref.update({
      memberIds: newMemberIds,
      members: newMembers,
      balance,
    })
  } catch (e) {
    console.error(`Failed to remove user from group (${groupDoc.id}): ${e}`)
  }
}

async function removeUserFromOutstandingExpenses(uid: string, groupId: string) {
  const app = admin.app()
  const expenses = await admin
    .firestore(app)
    .collection('expenses')
    .where('groupId', '==', groupId)
    .where('finalizedDate', '==', null)
    .get()

  for (const expenseDoc of expenses.docs) {
    const expense = expenseDoc.data() as Expense

    expense.assigneeIds = expense.assigneeIds.filter(
      (ids: string) => ids != uid
    )
    for (const item of expense.items) {
      item.assignees = item.assignees.filter((assignee) => assignee.uid != uid)
    }

    await expenseDoc.ref.set(expense)
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
