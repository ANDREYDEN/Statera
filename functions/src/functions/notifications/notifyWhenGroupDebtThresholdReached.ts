import { messaging } from 'firebase-admin'
import { Change } from 'firebase-functions/v1'
import { getUsersNotificationTokens } from './notificationUtils'
import { Group } from '../../types/group'

export async function notifyWhenGroupDebtThresholdReached(
  groupSnap: Change<FirebaseFirestore.QueryDocumentSnapshot>
) {
  const oldGroup = groupSnap.before.data() as Group
  const newGroup = groupSnap.after.data() as Group

  if (JSON.stringify(oldGroup.balance) === JSON.stringify(newGroup.balance)) {
    return
  }

  const userIds = getUsersWithBalanceModificationsThatExceedThreshold(
    oldGroup,
    newGroup
  )

  const userTokens = await getUsersNotificationTokens(userIds)
  console.log('Retrieved tokens:', userTokens)

  if (userTokens.length === 0) return

  return messaging().sendEachForMulticast({
    tokens: userTokens as string[],
    notification: {
      title: 'Debt threshold reached',
      body: `Seems like you have some outstanding balance in "${newGroup.name}". Consider making a payment.`,
    },
    data: {
      type: 'group_debt_threshold_reached',
      groupId: groupSnap.after.id,
    },
  })
}

function getUsersWithBalanceModificationsThatExceedThreshold(
  oldGroup: Group,
  newGroup: Group
): string[] {
  const oldThreshold = oldGroup.debtThreshold
  const newThreshold = newGroup.debtThreshold

  const usersWhoPassedThreshold = []
  for (const fromUid of Object.keys(newGroup.balance)) {
    for (const [toUid, debt] of Object.entries<number>(
      newGroup.balance[fromUid]
    )) {
      if (oldGroup.balance[fromUid]?.[toUid] === undefined) continue

      const debtWasHigherThanThreshold =
        oldGroup.balance[fromUid][toUid] > oldThreshold
      const debtIsHigherThanThreshold = debt > newThreshold

      if (!debtWasHigherThanThreshold && debtIsHigherThanThreshold) {
        usersWhoPassedThreshold.push(fromUid)
      }
    }
  }

  return usersWhoPassedThreshold
}
