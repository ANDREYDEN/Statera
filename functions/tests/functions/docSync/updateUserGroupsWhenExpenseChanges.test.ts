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
  const groupId = 'foo'
  const userId = 'user1'
  const user: UserData = {
    uid: userId,
    name: 'Bob',
  }
  const expenseId = 'expense_foo'

  it('sets unmarked expenses count when an expense is created', async () => {
    const newExpense:Expense = {
      items: [],
      assigneeIds: [userId],
      authorUid: userId,
      groupId,
      unmarkedAssigneeIds: [userId],
    }
    const existingUserGroup: UserGroup = {
      groupId,
      name: 'Foo',
      memberCount: 1,
      unmarkedExpenses: 0,
    }
    const userGroupRef = admin.firestore().doc( `users/${user.uid}/groups/${groupId}`)
    await userGroupRef.set(existingUserGroup)
    const before = { id: expenseId, exists: false, data: () => undefined }
    const after = firestore.makeDocumentSnapshot(newExpense, `expenses/${expenseId}`)
    const change = { before, after } as unknown as Change<DocumentSnapshot>

    await updateUserGroupsWhenExpenseChanges(change)

    const userGroupDocSnap = await userGroupRef.get()
    const freshUserGroup = userGroupDocSnap.data() as UserGroup
    expect(freshUserGroup.unmarkedExpenses).toEqual(1)
  })

  it.each([
    { existingUnmarkedAssigneeIds: ['user1'], newUnmarkedAssigneeIds: ['user1'], expectedUnmarkedExpenses: 1 },
    { existingUnmarkedAssigneeIds: [], newUnmarkedAssigneeIds: [], expectedUnmarkedExpenses: 1 },
    { existingUnmarkedAssigneeIds: ['user1'], newUnmarkedAssigneeIds: [], expectedUnmarkedExpenses: 0 },
    { existingUnmarkedAssigneeIds: [], newUnmarkedAssigneeIds: ['user1'], expectedUnmarkedExpenses: 2 },
  ])('updates unmarked expenses count when an expense is updated', async ({ existingUnmarkedAssigneeIds, newUnmarkedAssigneeIds, expectedUnmarkedExpenses }) => {
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
    const userGroupRef = admin.firestore().doc( `users/${user.uid}/groups/${groupId}`)
    await userGroupRef.set(existingUserGroup)
    const before = firestore.makeDocumentSnapshot(existingExpense, `expenses/${expenseId}`)
    const after = firestore.makeDocumentSnapshot(newExpense, `expenses/${expenseId}`)
    const change = { before, after } as unknown as Change<DocumentSnapshot>

    await updateUserGroupsWhenExpenseChanges(change)

    const userGroupDocSnap = await userGroupRef.get()
    const freshUserGroup = userGroupDocSnap.data() as UserGroup
    expect(freshUserGroup.unmarkedExpenses).toEqual(expectedUnmarkedExpenses)
  })

  describe('decreases unmarked expenses count when', () => {
    it('user is removed from an expense', async () => {
      const existingExpense:Expense = {
        items: [],
        assigneeIds: [userId],
        authorUid: userId,
        groupId,
        unmarkedAssigneeIds: [userId],
      }
      const newExpense:Expense = {
        ...existingExpense,
        assigneeIds: [],
        unmarkedAssigneeIds: [],
      }
      const existingUserGroup: UserGroup = {
        groupId,
        name: 'Foo',
        memberCount: 1,
        unmarkedExpenses: 1,
      }
      const userGroupRef = admin.firestore().doc( `users/${user.uid}/groups/${groupId}`)
      await userGroupRef.set(existingUserGroup)
      const before = firestore.makeDocumentSnapshot(existingExpense, `expenses/${expenseId}`)
      const after = firestore.makeDocumentSnapshot(newExpense, `expenses/${expenseId}`)
      const change = { before, after } as unknown as Change<DocumentSnapshot>

      await updateUserGroupsWhenExpenseChanges(change)

      const userGroupSnap = await userGroupRef.get()
      const freshUserGroup = userGroupSnap.data() as UserGroup
      expect(freshUserGroup.unmarkedExpenses).toEqual(0)
    })

    it('an expense is deleted', async () => {
      const existingExpense:Expense = {
        items: [],
        assigneeIds: [userId],
        authorUid: userId,
        groupId,
        unmarkedAssigneeIds: [userId],
      }
      const existingUserGroup: UserGroup = {
        groupId,
        name: 'Foo',
        memberCount: 1,
        unmarkedExpenses: 1,
      }
      const userGroupRef = admin.firestore().doc( `users/${user.uid}/groups/${groupId}`)
      await userGroupRef.set(existingUserGroup)
      const before = firestore.makeDocumentSnapshot(existingExpense, `expenses/${expenseId}`)
      const after = { id: expenseId, exists: false, data: () => undefined }
      const change = { before, after } as unknown as Change<DocumentSnapshot>

      await updateUserGroupsWhenExpenseChanges(change)

      const userGroupSnap = await userGroupRef.get()
      const freshUserGroup = userGroupSnap.data() as UserGroup
      expect(freshUserGroup.unmarkedExpenses).toEqual(0)
    })
  })
})
