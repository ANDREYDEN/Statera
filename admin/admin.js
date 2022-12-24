const admin = require('firebase-admin');
admin.initializeApp({
    credential: admin.credential.applicationDefault()
});

const db = admin.firestore();
const auth = admin.auth();

(async () => {
    // const groupId = '0i9Ni8Bz5qUk7yBIj5Cu'
    const groupId = '34zsdaQ63veJqM35MmhQ'
    const groupReference = await db.collection('groups').doc(groupId).get()
    const group = groupReference.data()

    // const userId = '92HncVCBiegd6rJP0Vt1gjVPz2cM'
    const userId = 'PA0rrExN4ddCby2jeeTKlfwmmVg1'
    const userReference = await db.collection('users').doc(userId).get()
    const user = {
        uid: userId,
        ...userReference.data()
    }

    // const newGroup = await addUserToGroup(group, user)
    // await groupReference.ref.set(newGroup)
    await removeUserFromAllFinalizedExpenses(groupId, user)
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

async function addUserToOutstandingExpenses(groupId, user) {
    const allExpenses = await db
        .collection('expenses')
        .where('groupId', '==', groupId)
        .get()

    const outstandingExpenses = allExpenses.docs.filter(e => e.finalizedDate == null)

    for (const expenseDoc of outstandingExpenses) {
        const expense = expenseDoc.data()
        expense.assigneeIds.push(user.uid)
        expense.unmarkedAssigneeIds.push(user.uid)

        for (const item of expense.items) {
            item.assignees.push({
                parts: null,
                uid: user.uid
            })
        }
        await expenseDoc.ref.set(expense)
    }
}

async function removeUserFromAllFinalizedExpenses(groupId, user) {
    const allExpenses = await db
        .collection('expenses')
        .where('groupId', '==', groupId)
        .get()

    const finalizedExpenses = allExpenses.docs.filter(e => e.data().finalizedDate != null)

    for (const expenseDoc of finalizedExpenses) {
        const expense = expenseDoc.data()
        expense.assigneeIds = expense.assigneeIds.filter(uid => uid != user.uid)
        expense.unmarkedAssigneeIds = expense.unmarkedAssigneeIds.filter(uid => uid != user.uid)

        for (const item of expense.items) {
            item.assignees = item.assignees.filter(a => a.uid != user.uid)
        }
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