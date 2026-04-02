import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as logger from 'firebase-functions/logger';
import { createIdempotentNotification } from '../utils/idempotency';
import { db } from '../config/firebase';

/**
 * Trigger: When a new review is created for a babysitter.
 * Action: Notify the babysitter and update their average rating.
 */
export const onNewReview = onDocumentCreated('reviews/{reviewId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.error('No data associated with the review event.');
    return;
  }

  const data = snapshot.data();
  const parentId = data?.parentId;
  const babysitterId = data?.babysitterId;
  const jobId = data?.jobId;
  const rating = data?.rating ?? 0;
  const createdAt = data?.createdAt || new Date();

  if (!parentId || !babysitterId || !jobId) {
    logger.warn(`Review ${event.params.reviewId} missing required fields.`);
    return;
  }

  try {
    // 1. Send notification to babysitter
    const notificationId = `review_${event.params.reviewId}`;

    await createIdempotentNotification(notificationId, {
      id: notificationId,
      type: 'review',
      actorId: parentId,
      recipientId: babysitterId,
      entityId: jobId,
      createdAt,
      read: false,
      messageSnippet: `New ${rating}⭐ review received`,
    });

    // 2. Recalculate babysitter's average rating
    const reviewsSnap = await db
      .collection('reviews')
      .where('babysitterId', '==', babysitterId)
      .get();

    if (!reviewsSnap.empty) {
      let total = 0;
      reviewsSnap.docs.forEach((doc) => {
        total += (doc.data().rating as number) || 0;
      });
      const avgRating = total / reviewsSnap.size;

      await db.collection('users').doc(babysitterId).update({
        averageRating: Math.round(avgRating * 10) / 10, // round to 1 decimal
      });

      logger.info(
        `Updated babysitter ${babysitterId} averageRating to ${avgRating.toFixed(1)}`
      );
    }
  } catch (error) {
    logger.error('Error processing onNewReview', error);
  }
});
