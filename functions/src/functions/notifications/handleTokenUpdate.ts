import * as admin from 'firebase-admin'
import { firestore } from 'firebase-admin'

export async function handleTokenUpdate(userId: string, token: string) {
    const app = admin.app()
    const userDoc = await firestore(app).collection('users').doc(userId).get();

    const notifications = userDoc.data()?.notifications ?? {}
    notifications[token] = firestore.FieldValue.serverTimestamp()
    
    await firestore(app).collection('users').doc(userId).set({notifications}, { merge: true })
}