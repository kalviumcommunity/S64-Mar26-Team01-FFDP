import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as logger from 'firebase-functions/logger';
import { createIdempotentNotification } from '../utils/idempotency';
import { MessageDocument } from '../types';

export const onNewMessage = onDocumentCreated('messages/{messageId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.error('No data associated with the message event.');
    return;
  }

  const data = snapshot.data() as MessageDocument;
  const senderId = data?.senderId || data?.userId;
  // Support both recipientId or a targetId depending on schema
  const targetId = data?.recipientId || data?.targetId;
  const chatId = data?.chatId || data?.conversationId;
  const text = data?.text || data?.content || '';
  const createdAt = data?.createdAt || new Date();

  if (!senderId || !targetId) {
    logger.warn(`Message ${event.params.messageId} missing senderId or recipientId.`);
    return;
  }

  // Self-chat edge case safeguard
  if (senderId === targetId) {
    return;
  }

  try {
    const snippet = text.length > 50 ? text.substring(0, 47) + '...' : text;
    
    // Using messageId as notification ID prevents duplicate notifications 
    // from recursive function executions or event retries.
    const notificationId = `message_${event.params.messageId}`;
    
    await createIdempotentNotification(notificationId, {
      id: notificationId,
      type: 'message',
      actorId: senderId,
      recipientId: targetId,
      entityId: chatId || event.params.messageId, // Route UI to chat thread
      createdAt,
      read: false,
      messageSnippet: snippet,
    });
  } catch (error) {
    logger.error('Error processing onNewMessage', error);
  }
});
