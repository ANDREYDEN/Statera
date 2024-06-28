const admin = require('firebase-admin');
admin.initializeApp({
    credential: admin.credential.applicationDefault()
});

const db = admin.firestore();
const auth = admin.auth();

(async () => {
    const groups = await db.collection('groups').get()
    console.log(`Found ${groups.docs.length} groups`)
    for (const groupDoc of groups.docs) {
        const group = groupDoc.data()
        const members = group.members
        for (const member of members) {
            const memberDocRef = db.collection('users').doc(member.uid)
            const userGroupSnap = await memberDocRef.collection('groups').doc(groupDoc.id).get()
            if (userGroupSnap.exists) {
                continue
            }

            const unmarkedExpensesQuerySnap = await db.collection('expenses')
                .where('groupId', '==', groupDoc.id)
                .where('unmarkedAssigneeIds', 'array-contains', member.uid)
                .count()
                .get()
            const unmarkedExpenses = unmarkedExpensesQuerySnap.data().count
            const newUserGroup = {
                groupId: groupDoc.id,
                name: group.name,
                memberCount: members.length,
                unmarkedExpenses
            }
            await userGroupSnap.ref.set(newUserGroup)
            console.log(member.uid, newUserGroup)
        }
    }
})();

function addUserToGroup(group, user) {
    for (const memberId1 of Object.keys(group.balance)) {
        group.balance[memberId1][user.uid] = 0
    }

    group.balance[user.uid] = Object.keys(group.balance).reduce((result, id) => ({ ...result, [id]: 0 }), {})

    group.members.push(user)
    group.memberIds.push(user.uid)
    console.log(group);

    return group
}

async function addUserToOutstandingExpenses(groupId, userId) {
    const allExpenses = await db
        .collection('expenses')
        .where('groupId', '==', groupId)
        .get()

    const outstandingExpenses = allExpenses.docs.filter(e => e.finalizedDate == null)

    for (const expenseDoc of outstandingExpenses) {
        const expense = expenseDoc.data()
        expense.assigneeIds.push(userId)
        expense.unmarkedAssigneeIds.push(userId)

        for (const item of expense.items) {
            item.assignees.push({
                parts: null,
                uid: userId
            })
        }
        await expenseDoc.ref.set(expense)
    }
}

async function removeUserFromAllFinalizedExpenses(groupId, userId) {
    const allExpenses = await db
        .collection('expenses')
        .where('groupId', '==', groupId)
        .get()

    const finalizedExpenses = allExpenses.docs.filter(e => e.data().finalizedDate != null)

    for (const expenseDoc of finalizedExpenses) {
        const expense = expenseDoc.data()
        // console.log('BEFORE: ', expense);
        expense.assigneeIds = expense.assigneeIds.filter(uid => uid != userId)
        expense.unmarkedAssigneeIds = expense.unmarkedAssigneeIds.filter(uid => uid != userId)

        for (const item of expense.items) {
            item.assignees = item.assignees.filter(a => a.uid != userId)
        }
        // console.log('AFTER: ', expense);
        await expenseDoc.ref.set(expense)
    }
}

function finalizeExpense(group, expense) {
    const authorId = expense.author?.uid ?? expense.authorUid
    console.log(authorId);

    for (const assigneeId of expense.assigneeIds.filter(a => a != authorId)) {
        const owedValueToAuthor = getTotalDebt(expense, assigneeId)
        console.log({ assigneeId, owedValueToAuthor });
        group.balance[assigneeId][authorId] += owedValueToAuthor;
        group.balance[authorId][assigneeId] -= owedValueToAuthor;
    }

    return group
}

async function getUserExpenses(groupId, userId) {
    const userExpenses = await db
        .collection('expenses')
        .where('groupId', '==', groupId)
        .where('assigneeIds', 'array-contains', userId)
        .get()

    return userExpenses.docs.map(e => ({
        name: e.data().name,
        finalizedDate: e.data().finalizedDate,
    }))
}

function getTotalDebt(expense, assigneeId) {
    const owage = expense.items.reduce(
        (acc, item) => {
            const totalParts = item.assignees.reduce((acc, assignee) => acc + assignee.parts, 0)
            if (totalParts == 0) return acc
            return acc + item.value *
                (item.assignees.find(a => a.uid === assigneeId).parts / totalParts)
        },
        0
    );

    return owage;
}

async function fixAnonymousMembers(group) {
    const correctMembers = []

    for (const member of groupData.members) {
        if (member.name == 'anonymous') {
            console.log(member);
            try {
                const userRecord = await auth.getUser(member.uid)
                correctMembers.push({
                    uid: member.uid,
                    name: userRecord.displayName ?? 'anonymous',
                    photoURL: userRecord.photoURL ?? null
                })
            } catch {
                correctMembers.push(member)
            }
        } else {
            correctMembers.push(member)
        }
    }

    return {
        ...group,
        members: correctMembers
    }
}

function createPayment(value, reason, payerId, receiverId, group, groupId) {
    return {
        value: Math.abs(value),
        reason: reason,
        payerId,
        receiverId,
        groupId,
        oldPayerBalance: group.balance[payerId][receiverId],
        timeCreated: admin.firestore.Timestamp.now(),
    }
}

async function getPayments(groupId, fromId, toId) {
    const payments = await db
        .collection('payments')
        .where('groupId', '==', groupId)
        .where('payerId', '==', fromId)
        .where('receiverId', '==', toId)
        .get()

    return payments.docs.map(p => p.data())
}

function calculateStage(expense, assigneeId) {
    if (expense.finalizedDate != null) return 2

    if (expense.unmarkedAssigneeIds.includes(assigneeId)) return 0

    return 1
}

function getHasItemsDeniedByAll(expense) {
    return expense.items.some(item => {
        return item.assignees.every(a => a.parts === 0)
    })
}