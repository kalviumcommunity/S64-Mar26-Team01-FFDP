import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level background handler — MUST be a top-level function, not a method.
// Firebase requires this to be outside of any class scope.
// ─────────────────────────────────────────────────────────────────────────────

/// Handles FCM messages arriving while the app is in the background or
/// terminated. Because this runs in its own isolate, it cannot access
/// instance state, navigate, or call `setState`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 [FCM] Background message received: ${message.messageId}');
  // Heavy processing (analytics, local DB write) can go here.
  // Do NOT touch UI or navigation from this isolate.
}

// ─────────────────────────────────────────────────────────────────────────────
// Parsed notification payload — strongly typed, null-safe
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a parsed notification payload with safe fallback defaults.
class NotificationPayload {
  final String type;
  final String? postId;
  final String? chatId;
  final String? senderId;
  final String? receiverId;

  const NotificationPayload({
    required this.type,
    this.postId,
    this.chatId,
    this.senderId,
    this.receiverId,
  });

  /// Safely parses a raw FCM data map into a [NotificationPayload].
  /// Returns `null` if no `type` field is present — callers should skip
  /// routing in that case.
  factory NotificationPayload.tryParse(Map<String, dynamic> data) {
    return NotificationPayload(
      type: (data['type'] as String?) ?? 'unknown',
      postId: data['postId'] as String?,
      chatId: data['chatId'] as String?,
      senderId: data['senderId'] as String?,
      receiverId: data['receiverId'] as String?,
    );
  }

  bool get isRoutable => type != 'unknown';
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationService — singleton, clean lifecycle
// ─────────────────────────────────────────────────────────────────────────────

/// Production-grade notification service wrapping Firebase Cloud Messaging
/// with local notification rendering for foreground messages.
///
/// Usage:
/// ```dart
/// // In main.dart, after Firebase.initializeApp():
/// await NotificationService.instance.initialize(onNotificationTap: (payload) {
///   // Route the user based on payload.type, payload.postId, etc.
/// });
/// ```
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Callback invoked when the user taps a notification.
  /// Set during [initialize]. Callers provide routing logic here.
  void Function(NotificationPayload payload)? _onNotificationTap;

  // ── Android notification channel ──────────────────────────────────────

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'connecthub_high_importance', // id
    'ConnectHub Notifications', // name
    description: 'Primary notification channel for ConnectHub alerts.',
    importance: Importance.high,
    playSound: true,
  );

  // ── Public API ────────────────────────────────────────────────────────

  /// Initializes the full notification pipeline. Safe to call multiple
  /// times — subsequent calls are no-ops.
  ///
  /// [onNotificationTap] receives a parsed [NotificationPayload] when the
  /// user taps a notification from any app state (foreground, background,
  /// terminated).
  Future<void> initialize({
    void Function(NotificationPayload payload)? onNotificationTap,
  }) async {
    if (_initialized) return;
    _onNotificationTap = onNotificationTap;

    // 1. Register the top-level background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request permissions (iOS + Android 13+)
    await _requestPermission();

    // 3. Set up local notifications for foreground rendering
    await _initLocalNotifications();

    // 4. Create the high-importance Android channel
    await _createAndroidChannel();

    // 5. Wire up all message listeners
    _configureForegroundListener();
    _configureNotificationTapListeners();

    // 6. Retrieve and log the FCM token
    await _retrieveToken();

    // 7. Listen for token refresh
    _listenForTokenRefresh();

    _initialized = true;
    debugPrint('✅ [FCM] NotificationService initialized successfully.');
  }

  /// Returns the current FCM device token, or `null` if unavailable.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('⚠️ [FCM] Failed to get token: $e');
      return null;
    }
  }

  // ── Permission ────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      final status = settings.authorizationStatus;
      debugPrint('📋 [FCM] Permission status: $status');

      if (status == AuthorizationStatus.denied) {
        debugPrint(
          '🚫 [FCM] Notifications denied by user. '
          'App will continue without push notifications.',
        );
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Permission request failed: $e');
    }
  }

  // ── Local notifications setup ─────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Already handled via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  /// Creates the Android notification channel. Required for Android 8+.
  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  // ── Token management ──────────────────────────────────────────────────

  Future<void> _retrieveToken() async {
    final token = await getToken();
    if (token != null) {
      debugPrint('🔑 [FCM] Device token: ${token.substring(0, 20)}...');
      // TODO(backend-sync): Store token in Firestore under users/{uid}/fcmToken
      // e.g. FirestoreService().updateFcmToken(token);
    }
  }

  void _listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint(
        '🔄 [FCM] Token refreshed: ${newToken.substring(0, 20)}...',
      );
      // TODO(backend-sync): Update token in Firestore
    });
  }

  // ── Foreground messages ───────────────────────────────────────────────

  void _configureForegroundListener() {
    // Show heads-up / banner notification via flutter_local_notifications
    // so the user sees it even while the app is open.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '📬 [FCM] Foreground message: ${message.notification?.title}',
      );
      _showLocalNotification(message);
    });
  }

  /// Renders a local notification from an FCM [RemoteMessage].
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // Encode data payload as the local notification payload string
    // so we can parse it on tap.
    final payloadString = jsonEncode(message.data);

    _localNotifications.show(
      notification.hashCode, // unique ID per notification
      notification.title ?? 'ConnectHub',
      notification.body ?? '',
      details,
      payload: payloadString,
    );
  }

  // ── Notification tap handling ─────────────────────────────────────────

  void _configureNotificationTapListeners() {
    // 1. App was in background and user tapped the notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);

    // 2. App was terminated and opened via notification tap
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('🚀 [FCM] App opened from terminated via notification.');
        _handleRemoteMessageTap(message);
      }
    });
  }

  /// Routes the user based on the data payload of an FCM notification.
  void _handleRemoteMessageTap(RemoteMessage message) {
    final payload = NotificationPayload.tryParse(message.data);
    if (!payload.isRoutable) {
      debugPrint('⚠️ [FCM] Tapped notification has no routable type.');
      return;
    }

    debugPrint('👆 [FCM] Notification tapped — type: ${payload.type}');
    _onNotificationTap?.call(payload);
  }

  /// Handles taps on local notifications shown in the foreground.
  void _onLocalNotificationTap(NotificationResponse response) {
    final payloadString = response.payload;
    if (payloadString == null || payloadString.isEmpty) return;

    try {
      final data = jsonDecode(payloadString) as Map<String, dynamic>;
      final payload = NotificationPayload.tryParse(data);

      if (!payload.isRoutable) return;

      debugPrint(
        '👆 [FCM] Local notification tapped — type: ${payload.type}',
      );
      _onNotificationTap?.call(payload);
    } catch (e) {
      debugPrint('⚠️ [FCM] Failed to parse local notification payload: $e');
    }
  }
}
