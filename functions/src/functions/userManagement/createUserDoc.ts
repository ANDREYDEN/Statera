import { firestore } from 'firebase-admin'
import { UserRecord } from 'firebase-admin/lib/auth/user-record'

export async function createUserDoc(user: UserRecord) {
    await firestore().collection('users').doc(user.uid).set({
        name: user.displayName ?? 'anonymous',
        photoURL: user.photoURL
    })
}