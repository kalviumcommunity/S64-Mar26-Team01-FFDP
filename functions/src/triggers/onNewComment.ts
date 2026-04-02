import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as logger from 'firebase-functions/logger';
import { createIdempotentNotification } from '../utils/idempotency';
import { db } from '../config/firebase';

/**
 * Trigger: When a new job booking is created.
 * Action: Notify the babysitter about the incoming job request.
 */
export const onNewJobBooking = onDocumentCreated('jobs/{jobId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.error('No data associated with the job event.');
    return;
  }

  const data = snapshot.data();
  const parentId = data?.parentId;
  const babysitterId = data?.babysitterId;
  const jobAddress = data?.jobAddress || 'Unknown location';
  const createdAt = data?.createdAt || new Date();

  if (!parentId || !babysitterId) {
    logger.warn(`Job ${event.params.jobId} missing parentId or babysitterId.`);
    return;
  }

  try {
    // Fetch parent display name for notification message
    const parentSnap = await db.collection('users').doc(parentId).get();
    const parentName = parentSnap.exists
      ? parentSnap.data()?.displayName || 'A parent'
      : 'A parent';

    const notificationId = `job_${event.params.jobId}`;

    await createIdempotentNotification(notificationId, {
      id: notificationId,
      type: 'job_request',
      actorId: parentId,
      recipientId: babysitterId,
      entityId: event.params.jobId,
      createdAt,
      read: false,
      messageSnippet: `${parentName} requested a booking at ${jobAddress}`,
    });

    logger.info(`Notification sent to babysitter ${babysitterId} for job ${event.params.jobId}`);
  } catch (error) {
    logger.error('Error processing onNewJobBooking', error);
  }
});
