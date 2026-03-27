import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as logger from 'firebase-functions/logger';
import { createIdempotentNotification } from '../utils/idempotency';
import { db } from '../config/firebase';

export const onNewLike = onDocumentCreated('likes/{likeId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.error('No data associated with the event.');
    return;
  }

  const data = snapshot.data();
  const actorId = data?.userId || data?.actorId;
  const postId = data?.postId;
  
  // Safe default to server time if unset by client for some reason
  const createdAt = data?.createdAt || new Date();

  if (!actorId || !postId) {
    logger.warn(`Like ${event.params.likeId} missing actorId or postId. Cannot process.`);
    return;
  }

  try {
    // Fetch post to determine owner
    const postSnap = await db.collection('posts').doc(postId).get();
    if (!postSnap.exists) {
        logger.warn(`Post ${postId} does not exist. Cannot notify owner.`);
        return;
    }

    const postData = postSnap.data();
    const ownerId = postData?.ownerId || postData?.userId;

    if (!ownerId) {
        logger.warn(`Post ${postId} missing ownerId.`);
        return;
    }

    // Protect against self-notification
    if (ownerId === actorId) {
      logger.info(`User ${actorId} liked their own post. Skipping notification.`);
      return;
    }

    // Creating notification deterministically based on likeId guarantees idempotency.
    // Retried functions will skip over if the document already exists.
    const notificationId = `like_${event.params.likeId}`;
    
    await createIdempotentNotification(notificationId, {
      id: notificationId,
      type: 'like',
      actorId,
      recipientId: ownerId,
      entityId: postId,
      createdAt,
      read: false,
    });
  } catch (error) {
    logger.error('Error processing onNewLike', error);
  }
});
