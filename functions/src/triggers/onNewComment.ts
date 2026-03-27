import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as logger from 'firebase-functions/logger';
import { createIdempotentNotification } from '../utils/idempotency';
import { db } from '../config/firebase';
import { CommentDocument } from '../types';

export const onNewComment = onDocumentCreated('comments/{commentId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.error('No data associated with the comment event.');
    return;
  }

  const data = snapshot.data() as CommentDocument;
  const actorId = data?.userId || data?.actorId;
  const postId = data?.postId;
  const text = data?.text || data?.content || '';
  const createdAt = data?.createdAt || new Date();

  if (!actorId || !postId) {
    logger.warn(`Comment ${event.params.commentId} missing actorId or postId.`);
    return;
  }

  try {
    const postSnap = await db.collection('posts').doc(postId).get();
    if (!postSnap.exists) {
        logger.warn(`Post ${postId} does not exist.`);
        return;
    }

    const postData = postSnap.data();
    const ownerId = postData?.ownerId || postData?.userId;

    if (!ownerId) {
        logger.warn(`Post ${postId} missing ownerId. Cannot notify.`);
        return;
    }

    if (ownerId === actorId) {
      logger.info(`User ${actorId} commented on their own post. Skipping notification.`);
      return;
    }

    const snippet = text.length > 50 ? text.substring(0, 47) + '...' : text;
    const notificationId = `comment_${event.params.commentId}`;
    
    await createIdempotentNotification(notificationId, {
      id: notificationId,
      type: 'comment',
      actorId,
      recipientId: ownerId,
      entityId: postId,
      createdAt,
      read: false,
      messageSnippet: snippet,
    });
  } catch (error) {
    logger.error('Error processing onNewComment', error);
  }
});
