import * as admin from 'firebase-admin';

export interface NotificationPayload {
  id: string;
  type: 'like' | 'comment' | 'message';
  actorId: string;
  recipientId: string;
  entityId: string; // ID of the triggering document (like, comment, or message ID)
  createdAt: admin.firestore.Timestamp | Date;
  read: boolean;
  messageSnippet?: string; // Optional context, e.g. snippet of comment or message
}

export interface LikeDocument {
  userId?: string;
  actorId?: string;
  ownerId?: string; // To whom the like belongs
  postId?: string;
  createdAt?: admin.firestore.Timestamp;
}

export interface CommentDocument {
  userId?: string;
  actorId?: string;
  ownerId?: string;
  postId?: string;
  text?: string;
  content?: string;
  createdAt?: admin.firestore.Timestamp;
}

export interface MessageDocument {
  senderId?: string;
  recipientId?: string;
  text?: string;
  content?: string;
  chatId?: string;
  createdAt?: admin.firestore.Timestamp;
}
