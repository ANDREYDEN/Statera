import firebaseFunctionsTest from 'firebase-functions-test'
import { Expense } from '../../../src/types/expense'
import * as admin from 'firebase-admin'
import { UserExpense } from '../../../src/types/userExpense'
import { Change } from 'firebase-functions/v1'
import { DocumentSnapshot } from 'firebase-admin/firestore'
import { updateUserExpenses } from '../../../src/functions/docSync/updateUserExpenses'
import { deleteAllData } from '../../testUtils'

const { firestore } = firebaseFunctionsTest()
admin.initializeApp()

describe('updateUserExpenses', () => {
  beforeEach(deleteAllData)

  describe('adds user expense when', () => {
    it('expense is created', async () => {
      const userId = '1'
      const authorUid = 'author'
      const expenseAfter: Partial<Expense> = {
        authorUid,
        assigneeIds: [userId],
        unmarkedAssigneeIds: [userId],
      }

      const expenseId = 'expense-1'
      const userExpenseDocRef = admin.firestore().collection('users').doc(userId).collection('expenses').doc(expenseId)

      const before = { id: expenseId, exists: false, data: () => undefined }
      const after = firestore.makeDocumentSnapshot(expenseAfter, `expenses/${expenseId}`)
      const change = { before, after } as unknown as Change<DocumentSnapshot>

      await updateUserExpenses(change)

      const newUserExpenseDocSnap = await userExpenseDocRef.get()
      expect(newUserExpenseDocSnap.exists).toBe(true)
      const newUserExpense = newUserExpenseDocSnap.data() as UserExpense
      expect(newUserExpense.stage).toBe(0)
    })

    it('user is added to existing expense', async () => {
      const userId = '1'
      const authorUid = 'author'
      const expenseBefore: Partial<Expense> = {
        assigneeIds: [],
        authorUid,
        unmarkedAssigneeIds: [],
      }
      const expenseAfter: Partial<Expense> = {
        ...expenseBefore,
        assigneeIds: [userId],
        unmarkedAssigneeIds: [userId],
      }
      const authorExpense: Partial<UserExpense> = {
        ...expenseBefore,
        stage: 0,
      }

      const expenseId = 'expense-1'
      await admin.firestore().collection('expenses').doc(expenseId).set(expenseBefore)
      await admin.firestore().doc(`users/${authorUid}/expenses/${expenseId}`).set(authorExpense)
      const userExpenseDocRef = admin.firestore().collection('users').doc(userId).collection('expenses').doc(expenseId)

      const before = firestore.makeDocumentSnapshot(expenseBefore, `expenses/${expenseId}`)
      const after = firestore.makeDocumentSnapshot(expenseAfter, `expenses/${expenseId}`)
      const change = { before, after } as unknown as Change<DocumentSnapshot>

      await updateUserExpenses(change)

      const newUserExpenseDocSnap = await userExpenseDocRef.get()
      expect(newUserExpenseDocSnap.exists).toBe(true)
      const newUserExpense = newUserExpenseDocSnap.data() as UserExpense
      expect(newUserExpense.stage).toBe(0)
    })
  })

  it('updates user expense if expense changes', async () => {
    const userId = '1'
    const authorUid = 'author'
    const expenseBefore: Partial<Expense> = {
      assigneeIds: [userId],
      authorUid,
      unmarkedAssigneeIds: [userId],
    }
    const expenseAfter: Partial<Expense> = {
      ...expenseBefore,
      unmarkedAssigneeIds: [],
    }
    const exisingUserExpense: Partial<UserExpense> = {
      ...expenseBefore,
      stage: 0,
    }
    const authorExpense: Partial<UserExpense> = {
      ...expenseBefore,
      stage: 0,
    }

    const expenseId = 'expense-1'
    await admin.firestore().collection('expenses').doc(expenseId).set(expenseBefore)
    const userExpenseDocRef = admin.firestore().doc(`users/${userId}/expenses/${expenseId}`)
    await userExpenseDocRef.set(exisingUserExpense)
    await admin.firestore().doc(`users/${authorUid}/expenses/${expenseId}`).set(authorExpense)


    const before = firestore.makeDocumentSnapshot(expenseBefore, `expenses/${expenseId}`)
    const after = firestore.makeDocumentSnapshot(expenseAfter, `expenses/${expenseId}`)
    const change = { before, after } as unknown as Change<DocumentSnapshot>

    await updateUserExpenses(change)

    const newUserExpenseDocSnap = await userExpenseDocRef.get()
    expect(newUserExpenseDocSnap.exists).toBe(true)
    const newUserExpense = newUserExpenseDocSnap.data() as UserExpense
    expect(newUserExpense.stage).toBe(1)
  })

  it('deletes user expense if user is removed from expense', async () => {
    const userId = '1'
    const authorUid = 'author'
    const expenseBefore: Partial<Expense> = {
      assigneeIds: [userId],
      authorUid,
      unmarkedAssigneeIds: [],
    }
    const expenseAfter: Partial<Expense> = {
      ...expenseBefore,
      assigneeIds: [],
    }
    const exisingUserExpense: Partial<UserExpense> = {
      ...expenseBefore,
      stage: 1,
    }
    const authorExpense: Partial<UserExpense> = {
      ...expenseBefore,
      stage: 0,
    }

    const expenseId = 'expense-1'
    await admin.firestore().collection('expenses').doc(expenseId).set(expenseBefore)
    const userExpenseDocRef = admin.firestore().doc(`users/${userId}/expenses/${expenseId}`)
    await userExpenseDocRef.set(exisingUserExpense)
    await admin.firestore().doc(`users/${authorUid}/expenses/${expenseId}`).set(authorExpense)


    const before = firestore.makeDocumentSnapshot(expenseBefore, `expenses/${expenseId}`)
    const after = firestore.makeDocumentSnapshot(expenseAfter, `expenses/${expenseId}`)
    const change = { before, after } as unknown as Change<DocumentSnapshot>

    await updateUserExpenses(change)

    const newUserExpense = await userExpenseDocRef.get()
    expect(newUserExpense.exists).toBe(false)
  })
})
