"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.onNewComment = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const idempotency_1 = require("../utils/idempotency");
const firebase_1 = require("../config/firebase");
exports.onNewComment = (0, firestore_1.onDocumentCreated)('comments/{commentId}', async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        logger.error('No data associated with the comment event.');
        return;
    }
    const data = snapshot.data();
    const actorId = (data === null || data === void 0 ? void 0 : data.userId) || (data === null || data === void 0 ? void 0 : data.actorId);
    const postId = data === null || data === void 0 ? void 0 : data.postId;
    const text = (data === null || data === void 0 ? void 0 : data.text) || (data === null || data === void 0 ? void 0 : data.content) || '';
    const createdAt = (data === null || data === void 0 ? void 0 : data.createdAt) || new Date();
    if (!actorId || !postId) {
        logger.warn(`Comment ${event.params.commentId} missing actorId or postId.`);
        return;
    }
    try {
        const postSnap = await firebase_1.db.collection('posts').doc(postId).get();
        if (!postSnap.exists) {
            logger.warn(`Post ${postId} does not exist.`);
            return;
        }
        const postData = postSnap.data();
        const ownerId = (postData === null || postData === void 0 ? void 0 : postData.ownerId) || (postData === null || postData === void 0 ? void 0 : postData.userId);
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
        await (0, idempotency_1.createIdempotentNotification)(notificationId, {
            id: notificationId,
            type: 'comment',
            actorId,
            recipientId: ownerId,
            entityId: postId,
            createdAt,
            read: false,
            messageSnippet: snippet,
        });
    }
    catch (error) {
        logger.error('Error processing onNewComment', error);
    }
});
//# sourceMappingURL=onNewComment.js.map