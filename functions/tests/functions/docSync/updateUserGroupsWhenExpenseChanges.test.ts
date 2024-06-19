import firebaseFunctionsTest from 'firebase-functions-test'

import * as admin from 'firebase-admin'
import { Change } from 'firebase-functions/v1'
import { DocumentSnapshot } from 'firebase-functions/v1/firestore'
import { updateUserGroupsWhenExpenseChanges } from '../../../src/functions/docSync/updateUserGroupsWhenExpenseChanges'
import { Expense } from '../../../src/types/expense'
import { UserData } from '../../../src/types/userData'
import { UserGroup } from '../../../src/types/userGroup'
const { firestore } = firebaseFunctionsTest()

admin.initializeApp()

describe('updateUserGroupsWhenExpenseChanges', () => {
  it.each([
    { existingUnmarkedAssigneeIds: ['user1'], newUnmarkedAssigneeIds: ['user1'], expectedUnmarkedExpenses: 1 },
    { existingUnmarkedAssigneeIds: [], newUnmarkedAssigneeIds: [], expectedUnmarkedExpenses: 1 },
    { existingUnmarkedAssigneeIds: ['user1'], newUnmarkedAssigneeIds: [], expectedUnmarkedExpenses: 0 },
    { existingUnmarkedAssigneeIds: [], newUnmarkedAssigneeIds: ['user1'], expectedUnmarkedExpenses: 2 },
  ])('updates unmarked expenses count when an expense becomes marked', async ({ existingUnmarkedAssigneeIds, newUnmarkedAssigneeIds, expectedUnmarkedExpenses }) => {
    const groupId = 'foo'
    const userId = 'user1'
    const user: UserData = {
      uid: userId,
      name: 'Bob',
    }
    const expenseId = 'expense_foo'
    const existingExpense:Expense = {
      items: [],
      assigneeIds: [userId],
      authorUid: userId,
      groupId,
      unmarkedAssigneeIds: existingUnmarkedAssigneeIds,
    }
    const newExpense:Expense = {
      ...existingExpense,
      unmarkedAssigneeIds: newUnmarkedAssigneeIds,
    }
    const existingUserGroup: UserGroup = {
      groupId,
      name: 'Foo',
      memberCount: 1,
      unmarkedExpenses: 1,
    }
    const userGroupPath = `users/${user.uid}/groups/${groupId}`
    await admin.firestore().doc(userGroupPath).set(existingUserGroup)
    const before = firestore.makeDocumentSnapshot(existingExpense, `expenses/${expenseId}`)
    const after = firestore.makeDocumentSnapshot(newExpense, `expenses/${expenseId}`)
    const change = { before, after } as unknown as Change<DocumentSnapshot>

    await updateUserGroupsWhenExpenseChanges(change)

    const userGroupDocRef = await admin.firestore().doc(userGroupPath).get()
    const freshUserGroup = userGroupDocRef.data() as UserGroup
    expect(freshUserGroup.unmarkedExpenses).toEqual(expectedUnmarkedExpenses)
  })
})
