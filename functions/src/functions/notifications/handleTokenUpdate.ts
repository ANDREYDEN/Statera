import * as admin from 'firebase-admin'
import { auth } from 'firebase-admin'

const app = admin.initializeApp()

export async function handleTokenUpdate(userId: string, token: string) {
    const user = await auth(app).getUser(userId);
    const timestamp = new Date().getTime()

    await auth(app).setCustomUserClaims(userId, {
        ...user.customClaims,
        notifications: { token, timestamp }
    })
}