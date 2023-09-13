import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleOnBackgroundMessage(RemoteMessage message) async {}

class FirebaseMessage {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Fcm Token $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleOnBackgroundMessage);
  }
}
