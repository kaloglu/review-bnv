import 'package:cihan_app/presentation/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import '../constants/text_styles.dart';
import '../presentation/utils/auth_decoration.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        initialData: FirebaseAuth.instance.currentUser,
        builder: (context, snapshot) {
          // User is not signed in
          if (!snapshot.hasData) {
            return MaterialApp(
              theme: ThemeData(
                brightness: Brightness.light,
                visualDensity: VisualDensity.comfortable,
                useMaterial3: true,
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(),
                ),
                elevatedButtonTheme:
                ElevatedButtonThemeData(style: buttonStyle),
                textButtonTheme: TextButtonThemeData(style: buttonStyle),
                outlinedButtonTheme:
                OutlinedButtonThemeData(style: buttonStyle),
              ),
              routes: {
                '/': (context) {
                  return SignInScreen(
                    sideBuilder: sideIcon(Icons.account_box_sharp),
                    subtitleBuilder: (context, action) {
                      return Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 7),
                          child: Column(
                            children: [
                              Text(
                                'Hey there,',
                                style: kMediumTextStyle,
                              ),
                              Text(
                                'Welcome ',
                                style: kLargeTextStyle,
                              ),
                            ],
                          ));
                    },
                    footerBuilder: (context, action) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Text(
                            'By signing in, you agree to our terms and conditions.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                    showAuthActionSwitch: false,
                    actions: [
                      VerifyPhoneAction((context, _) {
                        Navigator.pushNamed(context, '/phone');
                      }),
                    ],
                  );
                },
                '/profile':(context){
                  return ProfileScreen(
                    appBar: AppBar(),
                  );
                },
                '/home': (context) {
                  return const HomeScreen();
                },
                '/phone': (context) {
                  return PhoneInputScreen(
                    actions: [
                      SMSCodeRequestedAction((context, action, flowKey, phone) {
                        Navigator.of(context).pushReplacementNamed(
                          '/sms',
                          arguments: {
                            'action': action,
                            'flowKey': flowKey,
                            'phone': phone,
                          },
                        );
                      }),
                    ],
                    headerBuilder: headerIcon(Icons.phone),
                    sideBuilder: sideIcon(Icons.phone),
                  );
                },
                '/sms': (context) {
                  final arguments = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;

                  return SMSCodeInputScreen(
                    actions: [
                      AuthStateChangeAction<SignedIn>((context, state) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      })
                    ],
                    flowKey: arguments?['flowKey'],
                    action: arguments?['action'],
                  );
                },
              },
              debugShowCheckedModeBanner: false,
            );
          }
          return const HomeScreen();
        });
  }
}