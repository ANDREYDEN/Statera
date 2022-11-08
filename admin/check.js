const admin = require('firebase-admin');
admin.initializeApp({
    credential: admin.credential.applicationDefault()
});

const expenseId = 'b6QEwJq0zVw2v53OYKzz'
const userId = 'e5y4QBL0JNhZ1bTPVA8E2XraXjq1'
const excludeId = '9zjw4NRYUKQR479BdPzJNG8ZCqU2'

;(async () => {
    const userDoc = await admin.firestore().collection('users').doc(userId).get()
    const { name: userName } = userDoc.data()
    const expenseDoc = await admin.firestore().collection('expenses').doc(expenseId).get()
    const { items, name } = expenseDoc.data()
    console.log(`Breakdown of expense "${name}" for user ${userName}:`)

    const itemsData = []
    for (const item of items) {
        const claimedPartsTotal = item.assignees
            .filter(a => a.uid != excludeId)
            .reduce((acc, cur) => acc + cur.parts, 0)
        const claimedPartsByUser = item.assignees.find(assignee => assignee.uid === userId).parts
        const userValue = item.value / claimedPartsTotal * claimedPartsByUser

        console.log(`${item.name}: claimed ${claimedPartsByUser} of ${claimedPartsTotal} -- ${item.value} / ${claimedPartsTotal} * ${claimedPartsByUser} = ${userValue}`)
        itemsData.push({
            claimedPartsTotal,
            claimedPartsByUser,
            value: item.value,
            name: item.name,
            userValue
        })
    }
    
    const totalForUser = itemsData.reduce((acc, cur) => acc + cur.userValue, 0)
    console.log(`TOTAL: ${totalForUser}`);
})()