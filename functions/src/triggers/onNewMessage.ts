import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as logger from 'firebase-functions/logger';
import { createIdempotentNotification } from '../utils/idempotency';
import { MessageDocument } from '../types';

/**
 * Trigger: When a new message is created in a chat.
 * Path: chats/{chatId}/messages/{messageId}
 * Action: Notify the recipient.
 */
export const onNewMessage = onDocumentCreated(
  'chats/{chatId}/messages/{messageId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.error('No data associated with the message event.');
      return;
    }

    const data = snapshot.data() as MessageDocument;
    const senderId = data?.senderId || data?.userId;
    const targetId = data?.recipientId || data?.targetId;
    const chatId = event.params.chatId;
    const text = data?.text || data?.content || '';
    const createdAt = data?.createdAt || new Date();

    if (!senderId || !targetId) {
      logger.warn(
        `Message ${event.params.messageId} missing senderId or recipientId.`
      );
      return;
    }

    // Self-chat edge case safeguard
    if (senderId === targetId) {
      return;
    }

    try {
      const snippet =
        text.length > 50 ? text.substring(0, 47) + '...' : text;

      const notificationId = `message_${event.params.messageId}`;

      await createIdempotentNotification(notificationId, {
        id: notificationId,
        type: 'message',
        actorId: senderId,
        recipientId: targetId,
        entityId: chatId,
        createdAt,
        read: false,
        messageSnippet: snippet,
      });
    } catch (error) {
      logger.error('Error processing onNewMessage', error);
    }
  }
);
