const admin = require('firebase-admin');
admin.initializeApp({
    credential: admin.credential.applicationDefault()
});

const db = admin.firestore();
const auth = admin.auth();

(async () => {
    const expenses = await db.collection('expenses').get()
    console.log(`Found ${expenses.docs.length} expenses...`);

    for (const expenseDoc of expenses.docs) {
        console.log(`Updating expense ${expenseDoc.id}...`);
        const expense = expenseDoc.data()
        try {
            const relatedUids = new Set([...expense.assigneeIds, expense.authorUid]).values()
            for (const uid of relatedUids) {
                const stage = calculateStage(expense, uid)
                const canBeFinalized = getCanBeFinalized(expense, uid)
                const total = getTotal(expense)
                const confirmedTotal = getConfirmedTotal(expense, uid)
                const hasItemsDeniedByAll = getHasItemsDeniedByAll(expense)
                await db.collection('users').doc(uid)
                    .collection('expenses').doc(expenseDoc.id)
                    .set({
                        authorUid: expense.authorUid, 
                        groupId: expense.groupId,
                        name: expense.name,
                        itemQuantity: expense.items.length,
                        date: expense.date,
                        stage,
                        canBeFinalized,
                        total,
                        confirmedTotal,
                        hasItemsDeniedByAll
                    })
            }

            // console.log(expense);
            // await expenseDoc.ref.set(expense)
        } catch (error) {
            console.log(`Could not update expense ${expenseDoc.id}: `, error);
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

function getCanBeFinalized(expense, uid) {
    return !expense.finalizedDate && 
            expense.authorUid === uid && 
            !expense.unmarkedAssigneeIds.length
}

function getTotal(expense) {
    return expense.items.reduce((acc, item) => acc + item.value, 0)
}

function getConfirmedTotal(expense, uid) {
    return expense.items.reduce((acc, item) => {
        const assignee = item.assignees.find(a => a.uid === uid)
        if (assignee == null) return acc
        return acc + item.value * assignee.parts
    }, 0)
}

function getHasItemsDeniedByAll(expense) {
    return expense.items.some(item => {
        return item.assignees.every(a => a.parts === 0)
    })
}