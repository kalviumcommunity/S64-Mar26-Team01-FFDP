import { db } from '../config/firebase';
import { NotificationPayload } from '../types';

/**
 * Secures a notification write by using a deterministic ID.
 * This naturally prevents duplicate notifications if the trigger runs multiple times.
 * @param notificationId Unique deterministic ID (e.g. `like_notification_${likeId}`)
 * @param payload The notification data
 */
export async function createIdempotentNotification(notificationId: string, payload: NotificationPayload): Promise<void> {
  const notificationRef = db.collection('notifications').doc(notificationId);
  
  // Using set() with merge: true or just set() creates the document safely.
  // We check if it exists first to avoid unnecessary overwrites, which saves writes and preserves createdAt.
  const doc = await notificationRef.get();
  if (doc.exists) {
    console.log(`Notification ${notificationId} already exists. Skipping duplicate.`);
    return;
  }

  await notificationRef.set(payload);
  console.log(`Successfully created idempotent notification: ${notificationId}`);
}
