import { FieldValue, getFirestore } from 'firebase-admin/firestore'
import { Change } from 'firebase-functions/v1'
import { DocumentSnapshot } from 'firebase-functions/v1/firestore'
import { Expense } from '../../types/expense'

export async function updateUserGroupsWhenExpenseChanges(change: Change<DocumentSnapshot>) {
  const expenseBefore = change.before.data() as Expense | undefined
  const expenseAfter = change.after.data() as Expense | undefined
  const expenseData = (expenseAfter ?? expenseBefore)!
  if (!expenseData) return

  const relatedUids = [
    ...new Set([
      ...(expenseBefore?.assigneeIds ?? []),
      ...(expenseAfter?.assigneeIds ?? []),
    ]),
  ]

  const db = getFirestore()
  for (const uid of relatedUids) {
    const wasUnmarked = (expenseBefore?.unmarkedAssigneeIds ?? []).includes(uid)
    const becameUnmarked = (expenseAfter?.unmarkedAssigneeIds ?? []).includes(uid)

    if (wasUnmarked === becameUnmarked) continue

    const diff = wasUnmarked ? -1 : 1
    const userGroupRef = db
      .collection('users')
      .doc(uid!)
      .collection('groups')
      .doc(expenseData.groupId)

    const userGroupDocSnap = await userGroupRef.get()
    if (!userGroupDocSnap.exists) {
      console.warn(`Tried updating user group for user (${uid}) in group (${expenseData.groupId}), but it did not exist`)
      continue
    }

    await userGroupRef.update({
      unmarkedExpenses: FieldValue.increment(diff),
    })
  }
}
