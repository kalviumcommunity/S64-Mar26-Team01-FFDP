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
exports.onNewLike = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const idempotency_1 = require("../utils/idempotency");
const firebase_1 = require("../config/firebase");
exports.onNewLike = (0, firestore_1.onDocumentCreated)('likes/{likeId}', async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        logger.error('No data associated with the event.');
        return;
    }
    const data = snapshot.data();
    const actorId = (data === null || data === void 0 ? void 0 : data.userId) || (data === null || data === void 0 ? void 0 : data.actorId);
    const postId = data === null || data === void 0 ? void 0 : data.postId;
    // Safe default to server time if unset by client for some reason
    const createdAt = (data === null || data === void 0 ? void 0 : data.createdAt) || new Date();
    if (!actorId || !postId) {
        logger.warn(`Like ${event.params.likeId} missing actorId or postId. Cannot process.`);
        return;
    }
    try {
        // Fetch post to determine owner
        const postSnap = await firebase_1.db.collection('posts').doc(postId).get();
        if (!postSnap.exists) {
            logger.warn(`Post ${postId} does not exist. Cannot notify owner.`);
            return;
        }
        const postData = postSnap.data();
        const ownerId = (postData === null || postData === void 0 ? void 0 : postData.ownerId) || (postData === null || postData === void 0 ? void 0 : postData.userId);
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
        await (0, idempotency_1.createIdempotentNotification)(notificationId, {
            id: notificationId,
            type: 'like',
            actorId,
            recipientId: ownerId,
            entityId: postId,
            createdAt,
            read: false,
        });
    }
    catch (error) {
        logger.error('Error processing onNewLike', error);
    }
});
//# sourceMappingURL=onNewLike.js.map