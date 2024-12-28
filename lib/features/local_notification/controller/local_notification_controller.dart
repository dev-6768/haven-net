import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:haven_net/features/first_screen/view/first_screen.dart';
import 'package:haven_net/main.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Title : ${message.notification?.title}");
  print("Body : ${message.notification?.body}");
}

void handleMessage(RemoteMessage? message) async {
  if(message == null) {
    return;
  }

  else {
    if(FirebaseAuth.instance.currentUser != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => const FirstScreen()),
      );
    }
    
  }

}

final _localNotifications = FlutterLocalNotificationsPlugin();
final _androidChannel = const AndroidNotificationChannel(
  'high_inportance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.defaultImportance,
);

Future initPushNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );


  FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  FirebaseMessaging.onMessage.listen((event) { 
    final notification = event.notification;
    if(notification == null) {
      return;
    }

    else {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/launch_background'
          ),
        ),
        payload: jsonEncode(event.toMap()),
      );
    }
  });
}
 

Future initLocalNotifications() async {
  const android = AndroidInitializationSettings('@drawable/launch_background');
  const settings = InitializationSettings(android: android);
  await _localNotifications.initialize(
    settings,
    onDidReceiveNotificationResponse: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
      handleMessage(message);
    }
  );

  final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await platform?.createNotificationChannel(_androidChannel);
}


class FirebaseApiInterface {
  final _firebaseMessaging = FirebaseMessaging.instance;  

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print("Token : $fcmToken");

    initPushNotifications();
    initLocalNotifications();
  }
}