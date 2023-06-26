import 'package:cihan_app/presentation/screens/home_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart';
import 'package:firebase_ui_oauth_twitter/firebase_ui_oauth_twitter.dart';

import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        // User is not signed in
        if (!snapshot.hasData) {
          return SignInScreen(showAuthActionSwitch: false, providers: [
            //EmailProviderConfiguration(),
            GoogleProvider(
              clientId:
                  '414030755976-onqmorfkjqpv5rh3e1tcvjt7c2r291st.apps.googleusercontent.com',
            ),
            FacebookProvider(
                clientId: '1319317821552127',
                redirectUri:
                    'https://bedavanevar-2019.firebaseapp.com/__/auth/handler'),
            TwitterProvider(
                apiKey: 'AOYbJ7ofco7iYRbKZULljwGw2',
                apiSecretKey:
                    '6VhRKhLqzg95IITPaOfoy3zIlSzd3l93EchLzFdqv268cQFuKA',
                redirectUri: 'cihan-app://'),
          ]);
        }

        return const HomeScreen();
      },
    );
  }
}
