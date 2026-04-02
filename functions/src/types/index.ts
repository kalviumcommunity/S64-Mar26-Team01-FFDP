import * as admin from 'firebase-admin';

export interface NotificationPayload {
  id: string;
  type: 'review' | 'job_request' | 'message';
  actorId: string;
  recipientId: string;
  entityId: string;
  createdAt: admin.firestore.Timestamp | Date;
  read: boolean;
  messageSnippet?: string;
}

export interface ReviewDocument {
  parentId?: string;
  babysitterId?: string;
  jobId?: string;
  rating?: number;
  feedback?: string;
  createdAt?: admin.firestore.Timestamp;
}

export interface JobDocument {
  parentId?: string;
  babysitterId?: string;
  status?: string;
  startTime?: admin.firestore.Timestamp;
  endTime?: admin.firestore.Timestamp;
  hourlyRateApplied?: number;
  totalEstimatedCost?: number;
  jobAddress?: string;
  specialInstructions?: string;
  createdAt?: admin.firestore.Timestamp;
  updatedAt?: admin.firestore.Timestamp;
}

export interface MessageDocument {
  senderId?: string;
  userId?: string;
  recipientId?: string;
  targetId?: string;
  text?: string;
  content?: string;
  chatId?: string;
  conversationId?: string;
  createdAt?: admin.firestore.Timestamp;
}
