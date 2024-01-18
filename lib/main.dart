import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_twitter/firebase_ui_oauth_twitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'Data/services/auth_gate.dart';
import 'Data/services/firebase_message.dart';
import 'Data/services/secrete_keys.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // FlutterError.demangleStackTrace = (StackTrace stack) {
  //   if (stack is stack_trace.Trace) return stack.vmTrace;
  //   if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
  //   return stack;
  // };

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize other services after Firebase
  MobileAds.instance.initialize();

  await FirebaseMessage().initNotifications();

  FirebaseUIAuth.configureProviders([
    GoogleProvider(clientId: Keys().googleClientId),
    FacebookProvider(clientId: Keys().facebookId),
    TwitterProvider(
      apiKey: Keys().twitterApiKey,
      apiSecretKey: Keys().twitterApiSecreteKey,
      redirectUri: Keys().twitterRedirectUri,
    ),
    PhoneAuthProvider(),
  ]);
  //checkAndGrantDailyTicket(1);

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
      title: 'BedavaNevar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
    );
  }
}
