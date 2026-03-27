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
exports.onNewMessage = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const idempotency_1 = require("../utils/idempotency");
exports.onNewMessage = (0, firestore_1.onDocumentCreated)('messages/{messageId}', async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        logger.error('No data associated with the message event.');
        return;
    }
    const data = snapshot.data();
    const senderId = (data === null || data === void 0 ? void 0 : data.senderId) || (data === null || data === void 0 ? void 0 : data.userId);
    // Support both recipientId or a targetId depending on schema
    const targetId = (data === null || data === void 0 ? void 0 : data.recipientId) || (data === null || data === void 0 ? void 0 : data.targetId);
    const chatId = (data === null || data === void 0 ? void 0 : data.chatId) || (data === null || data === void 0 ? void 0 : data.conversationId);
    const text = (data === null || data === void 0 ? void 0 : data.text) || (data === null || data === void 0 ? void 0 : data.content) || '';
    const createdAt = (data === null || data === void 0 ? void 0 : data.createdAt) || new Date();
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
        await (0, idempotency_1.createIdempotentNotification)(notificationId, {
            id: notificationId,
            type: 'message',
            actorId: senderId,
            recipientId: targetId,
            entityId: chatId || event.params.messageId,
            createdAt,
            read: false,
            messageSnippet: snippet,
        });
    }
    catch (error) {
        logger.error('Error processing onNewMessage', error);
    }
});
//# sourceMappingURL=onNewMessage.js.map