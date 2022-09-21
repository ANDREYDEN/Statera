import { firestore } from 'firebase-admin'

export async function handleTokenUpdate(userId: string, token: string, platform: string) {
    const userDoc = await firestore().collection('users').doc(userId).get();

    const notifications = userDoc.data()?.notifications ?? {}
    notifications[platform] = {
        token: token,
        lastUpdatedAt: firestore.FieldValue.serverTimestamp()
    }
    
    await firestore().collection('users').doc(userId).set({notifications}, { merge: true })
}