import firebaseFunctionsTest from 'firebase-functions-test'
import {
  updateUserGroupsWhenGroupChanges,
} from '../../../src/functions/docSync/updateUserGroupsWhenGroupChanges'
import { Group } from '../../../src/types/group'

import * as admin from 'firebase-admin'
import { UserGroup } from '../../../src/types/userGroup'
import { UserData } from '../../../src/types/userData'
import { Change } from 'firebase-functions/v1'
import { DocumentSnapshot } from 'firebase-functions/v1/firestore'
import { deleteAllData } from '../../testUtils'
const { firestore } = firebaseFunctionsTest()

admin.initializeApp()

describe('updateUserGroupsWhenGroupChanges', () => {
  beforeEach(deleteAllData)

  it('creates user group when a group is created', async () => {
    const groupId = 'foo'
    const user: UserData = {
      uid: 'user1',
      name: 'Bob',
    }
    await admin.firestore().collection('users').doc(user.uid!).set(user)
    const newGroup:Group = {
      name: 'Foo',
      balance: {},
      members: [user],
      debtThreshold: 50,
    }
    const before = { id: groupId, exists: false, data: () => undefined }
    const after = firestore.makeDocumentSnapshot(newGroup, `groups/${groupId}`)
    const change = { before, after } as unknown as Change<DocumentSnapshot>

    await updateUserGroupsWhenGroupChanges(change)

    const userGroupDocRef = await admin.firestore().doc(`users/${user.uid}/groups/${groupId}`).get()
    const userGroup = userGroupDocRef.data() as UserGroup
    expect(userGroup).toEqual({
      groupId,
      name: newGroup.name,
      memberCount: 1,
    })
  })

  it('creates user group when the user is added to a group', async () => {
    const groupId = 'foo'
    const user: UserData = {
      uid: 'user1',
      name: 'Bob',
    }
    await admin.firestore().collection('users').doc(user.uid!).set(user)
    const existingGroup:Group = {
      name: 'Foo',
      balance: {},
      members: [],
      debtThreshold: 50,
    }
    const before = firestore.makeDocumentSnapshot(existingGroup, `groups/${groupId}`)
    const after = firestore.makeDocumentSnapshot(
      { ...existingGroup, members: [user] },
      `groups/${groupId}`
    )
    const change = { before, after } as unknown as Change<DocumentSnapshot>

    await updateUserGroupsWhenGroupChanges(change)

    const userGroupDocRef = await admin.firestore().doc(`users/${user.uid}/groups/${groupId}`).get()
    const userGroup = userGroupDocRef.data() as UserGroup
    expect(userGroup).toEqual({
      groupId,
      name: existingGroup.name,
      memberCount: 1,
    })
  })

  it('deletes user group when a group is deleted', async () => {
    const groupId = 'foo'
    const user: UserData = {
      uid: 'user1',
      name: 'Bob',
    }
    const existingGroup:Group = {
      name: 'Foo',
      balance: {},
      members: [user],
      debtThreshold: 50,
    }
    const existingUserGroup: UserGroup = {
      groupId,
      name: existingGroup.name,
      memberCount: 1,
    }
    const userGroupPath = `users/${user.uid}/groups/${groupId}`
    await admin.firestore().doc(userGroupPath).set(existingUserGroup)
    const before = firestore.makeDocumentSnapshot(existingGroup, `groups/${groupId}`)
    const after = { id: groupId, exists: false, data: () => undefined }
    const change = { before, after } as unknown as Change<DocumentSnapshot>

    await updateUserGroupsWhenGroupChanges(change)

    const userGroupDocRef = await admin.firestore().doc(userGroupPath).get()
    expect(userGroupDocRef.exists).toBeFalsy()
  })
})
