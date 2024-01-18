import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<void> handleOnBackgroundMessage(RemoteMessage message) async {}

class FirebaseMessage {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('Fcm Token $fCMToken');
    }
    FirebaseMessaging.onBackgroundMessage(handleOnBackgroundMessage);
  }
}
