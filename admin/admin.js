const admin = require('firebase-admin');
admin.initializeApp({
    credential: admin.credential.applicationDefault()
});

const db = admin.firestore();
const auth = admin.auth();

(async () => {
    // const groupId = 'YRhfpXAsOiRH9eOvFpBr';
    const groupId = 'mX6FbRb5do50QYzEAmoS';
    const groupSnap = await db.collection('groups').doc(groupId).get();
    let group = groupSnap.data();

    // const expenseId = 'G3vGbiZOx0Pbovy886NK'
    const expenseId = 'G3vGbiZOx0Pbovy886NK'
    const expenseSnap = await db.collection('expenses').doc(expenseId).get();
    let expense = expenseSnap.data();

    group = finalizeExpense(group, expense)

    console.log(group);
    // await groupSnap.ref.set(group)
})();

/**
 * 
 * @param {FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>} doc 
 */
async function operateOnDoc(doc) {
    console.log(doc.data());
}

function addUserToGroup(group, user) {
    for (const memberId1 of Object.keys(group.balance)) {
        group.balance[memberId1][user.uid] = 0
    }

    group.balance[user.uid] = Object.keys(group.balance).reduce((result, id) => ({ ...result, [id]: 0 }), {})

    group.members.push(user)
    group.memberIds.push(user.uid)

    return group
}

function finalizeExpense(group, expense) {
    const authorId = expense.author.uid
    
    for (const assigneeId of expense.assigneeIds) {
        const owedValueToAuthor = getTotalDebt(expense, assigneeId)
        group.balance[assigneeId][authorId] += owedValueToAuthor;
        group.balance[authorId][assigneeId] -= owedValueToAuthor;
    }

    return group
}

function getTotalDebt(expense, assigneeId) {
    const owage = expense.items.reduce(
        (acc, item) => acc + item.value *
            (item.assignees.find(a => a.uid === assigneeId).parts
                / item.assignees.reduce((acc, assignee) => acc + assignee.parts, 0)),
        0
    );

    return owage;
}