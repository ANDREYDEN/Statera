import { DocumentSnapshot } from 'firebase-functions/v1/firestore'
import { Group } from '../../types/group'
import { Change } from 'firebase-functions/v1'
import { firestore } from 'firebase-admin'

export async function updateUserGroupsWhenGroupChanges(change: Change<DocumentSnapshot>) {
  const groupData = (change.after.data() ?? change.before.data()) as Group
  const groupDeleted = !change.after.exists
  const groupAdded = !change.before.exists
  const groupId = change.after.id
  if (!groupData) return

  const relatedUids = groupData.members.map((member) => member.uid).filter((uid) => !!uid)


  for (const uid of relatedUids) {
    const userGroupRef = firestore()
      .collection('users')
      .doc(uid!)
      .collection('groups')
      .doc(groupId)
    if (groupDeleted) {
      await userGroupRef.delete()
    } else if (groupAdded) {
      await userGroupRef.set({
        groupId,
        name: groupData.name,
        memberCount: groupData.members.length,
      })
    } else {
      await userGroupRef.update({
        groupId,
        name: groupData.name,
        memberCount: groupData.members.length,
      })
    }
  }
}
