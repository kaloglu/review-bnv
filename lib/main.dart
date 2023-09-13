import 'dart:async';

import 'package:cihan_app/services/auth_gate.dart';
import 'package:cihan_app/services/firebase_message.dart';
import 'package:cihan_app/services/secrete_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_twitter/firebase_ui_oauth_twitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  checkAndGrantDailyTicket(11);


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
   // PhoneAuthProvider(),
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
      title: 'Cihan App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
    );
  }
}
Future<void> checkAndGrantDailyTicket(int newTicketCount) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(user.uid);
    final ticketsCollectionRef = userDocRef.collection('tickets');

    // Get the current date (without the time component)
    final currentDate = DateTime.now();
    final currentDateWithoutTime = DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Check if the user has already received a ticket for the current day
    final existingTicketQuery = await ticketsCollectionRef
        .where('createDate', isGreaterThanOrEqualTo: currentDateWithoutTime)
        .get();
    // Get the user's existing tickets and sort them by createDate in descending order
    final userTicketsSnapshot = await ticketsCollectionRef
        .orderBy('createDate', descending: true)
        .get();

    final userTicketsData = userTicketsSnapshot.docs.isNotEmpty
        ? userTicketsSnapshot.docs.first.data()
        : null;

    // Calculate the remaining points based on existing tickets and new earned tickets
    int remainingPoints = userTicketsData != null
        ? (userTicketsData['remain'] as int) + newTicketCount
        : newTicketCount;
    int remainingPoint = userTicketsData != null
        ? (userTicketsData['earn'] as int) + newTicketCount
        : newTicketCount;

    if (existingTicketQuery.docs.isEmpty) {
      // User hasn't received a ticket for the current day, so create a new ticket
      final newTicketData = {
        'source': 'Daily Bonus', // Replace with your source information
        'earn': remainingPoint, // Replace with the appropriate value for earnings
        'remain': remainingPoints, // Initial remain value (adjust as needed)
        'createDate': FieldValue.serverTimestamp(),
        'expirationDate': DateTime(currentDate.year, currentDate.month, currentDate.day + 1), // Expiration at 00:00 of the next day
      };

      await ticketsCollectionRef.add(newTicketData);
       Fluttertoast.showToast(msg: "You Earned Daily Bonus 1 ticket",gravity: ToastGravity.CENTER);
    }

    // Check for and handle ticket expiration
    final expiredTicketQuery = await ticketsCollectionRef
        .where('expirationDate', isLessThan: currentDateWithoutTime)
        .get();

    for (final ticketDoc in expiredTicketQuery.docs) {

      // Mark the expired ticket as "ticket expired"
      await ticketDoc.reference.update({});
    }
  }
}