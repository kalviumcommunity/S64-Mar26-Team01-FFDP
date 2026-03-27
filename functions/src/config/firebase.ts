import * as admin from 'firebase-admin';

// Initialize the app only if it hasn't been initialized yet
if (!admin.apps.length) {
  admin.initializeApp();
}

export const db = admin.firestore();
export const messaging = admin.messaging();
