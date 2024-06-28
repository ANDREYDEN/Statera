import { firestore } from 'firebase-admin'
import { Change } from 'firebase-functions/v1'
import { DocumentSnapshot } from 'firebase-functions/v1/firestore'
import { Group } from '../../types/group'
import { UserGroup } from '../../types/userGroup'

export async function updateUserGroupsWhenGroupChanges(change: Change<DocumentSnapshot>) {
  const oldGroupData = change.before.data() as (Group | undefined)
  const newGroupData = change.after.data() as (Group | undefined)
  const groupId = change.after.id

  const oldMemberUids = (oldGroupData?.members ?? [])
    .map((member) => member.uid)
    .filter((uid) => !!uid)
  const newMemberUids = (newGroupData?.members ?? [])
    .map((member) => member.uid)
    .filter((uid) => !!uid)

  const addedMemberUids = newMemberUids.filter((newUid) => !oldMemberUids.includes(newUid))
  const updatedMemberUids = newMemberUids.filter((newUid) => oldMemberUids.includes(newUid))
  const deletedMemberUids = oldMemberUids.filter((oldUid) => !newMemberUids.includes(oldUid))

  for (const uid of addedMemberUids) {
    const userGroupRef = firestore()
      .collection('users')
      .doc(uid!)
      .collection('groups')
      .doc(groupId)

    const newUserGroup: UserGroup = {
      groupId,
      name: newGroupData!.name,
      memberCount: newGroupData!.members.length,
    }

    await userGroupRef.set(newUserGroup)
  }

  for (const uid of updatedMemberUids) {
    const userGroupRef = firestore()
      .collection('users')
      .doc(uid!)
      .collection('groups')
      .doc(groupId)

    const newUserGroup: UserGroup = {
      groupId,
      name: newGroupData!.name,
      memberCount: newGroupData!.members.length,
    }

    await userGroupRef.update(newUserGroup)
  }

  for (const uid of deletedMemberUids) {
    const userGroupRef = firestore()
      .collection('users')
      .doc(uid!)
      .collection('groups')
      .doc(groupId)

    await userGroupRef.delete()
  }
}
