import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Reduces stack trace verbosity
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Replaces printTime
  ),
);

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Initialize notification channels and request permissions
  Future<void> init() async {
    // Request permission for iOS devices
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    logger.i('User notification settings: ${settings.authorizationStatus}');
    
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // Define notification channels for Android
    await _setupNotificationChannels();
    
    // Handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Get FCM token for this device
    String? token = await _firebaseMessaging.getToken();
    logger.i('FCM Token: $token');
  }
  
  // Create notification channels for Android
  Future<void> _setupNotificationChannels() async {
    const AndroidNotificationChannel contentChannel = AndroidNotificationChannel(
      'content_channel',
      'New Content',
      description: 'Notifications for new content from followed accounts',
      importance: Importance.high,
    );
    
    const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Usage reminders and focus session notifications',
      importance: Importance.low,
    );
    
    const AndroidNotificationChannel analyticsChannel = AndroidNotificationChannel(
      'analytics_channel',
      'Analytics',
      description: 'Weekly analytics and usage reports',
      importance: Importance.low,
    );
    
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(contentChannel);
    await androidPlugin?.createNotificationChannel(reminderChannel);   // Added to use reminderChannel
    await androidPlugin?.createNotificationChannel(analyticsChannel);  // Added to use analyticsChannel
  }
  
  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) async {
    logger.i('Got a message in the foreground!');
    logger.i('Message data: ${message.data}');
    
    if (message.notification != null) {
      logger.i('Message notification: ${message.notification}');
      
      // Show a local notification
      await _showLocalNotification(
        id: message.hashCode,
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
      );
    }
  }
  
  // Show a local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'content_channel',
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'content_channel' ? 'New Content' : 
      channelId == 'reminder_channel' ? 'Reminders' : 'Analytics',
      importance: channelId == 'content_channel'
          ? Importance.high
          : channelId == 'reminder_channel'
              ? Importance.defaultImportance
              : Importance.low,
      priority: channelId == 'content_channel'
          ? Priority.high
          : channelId == 'reminder_channel'
              ? Priority.defaultPriority
              : Priority.low,
      icon: '@mipmap/launcher_icon',
    );
    
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // For iOS foreground notifications
  void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    logger.i('iOS local notification: $title');
  }
  
  // Handle notification taps
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    logger.i('Notification tapped: ${response.payload}');
    // Handle notification tap here (e.g. navigate to specific screen)
  }
  
    // Schedule a local notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String channelId = 'reminder_channel',
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'content_channel' ? 'New Content' : 
      channelId == 'reminder_channel' ? 'Reminders' : 'Analytics',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );
    
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime as dynamic, // This is a simplification; in practice, use TZDateTime
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Replaced androidAllowWhileIdle
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

 
  
  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
  
  // Subscribe to a topic for push notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }
  
  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}