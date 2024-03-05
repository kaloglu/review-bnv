import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cihan_app/presentation/screens/edit_profile_screen.dart';
import 'package:cihan_app/presentation/screens/home_screen.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Presentation/constants/text_styles.dart';
import '../../Presentation/utils/auth_decoration.dart';
import '../../Presentation/utils/shimmer_effect.dart';
import '../../Presentation/utils/lang.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<bool> isProfileCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('profileCompleted') ?? false;
  }

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
              elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
              textButtonTheme: TextButtonThemeData(style: buttonStyle),
              outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
            ),
            routes: {
              '/': (context) {
                return Builder(
                  builder: (context) {
                    if (isConnected) {
                      return SignInScreen(
                        sideBuilder: sideIcon(Icons.account_box_sharp),
                        subtitleBuilder: (context, action) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8, left: 7),
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.heyThere,
                                  style: kMediumTextStyle,
                                ),
                                Text(
                                  AppStrings.welcome,
                                  style: kLargeTextStyle,
                                ),
                              ],
                            ),
                          );
                        },
                        headerBuilder:
                            headerImage('assets/images/splashlogo.png'),
                        footerBuilder: (context, action) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Text(
                                AppStrings
                                    .bySigningInYouAgreeToOurTermsAndConditions,
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
                    } else {
                      return Scaffold(
                        body: Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 350),
                              Text(
                                "No internet connection.",
                                style: kMediumTextStyle,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: buttonStyle,
                                onPressed: () async {
                                  // Check internet connection before navigating
                                  await _checkInternetConnection();
                                  if (isConnected) {
                                    if (!mounted) return;
                                    Navigator.pushNamed(context, '/signin');
                                  }
                                },
                                child: Text(
                                  "Refresh",
                                  style: kSmallTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
              '/home': (context) {
                return Builder(
                  builder: (context) {
                    if (isConnected) {
                      return const HomeScreen();
                    } else {
                      return Scaffold(
                        body: Center(
                          child: Column(
                            children: [
                              const Text(
                                "No internet connection.",
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: buttonStyle,
                                onPressed: () async {
                                  // Check internet connection before navigating
                                  await _checkInternetConnection();
                                  if (isConnected) {
                                    if (!mounted) return;
                                    Navigator.pushNamed(context, '/signin');
                                  }
                                },
                                child: const Text("Check Internet"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
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
                    }),
                  ],
                  flowKey: arguments?['flowKey'],
                  action: arguments?['action'],
                );
              },
            },
            debugShowCheckedModeBanner: false,
          );
        } else {
          final uid = snapshot.data!.uid;
          final usersCollection =
              FirebaseFirestore.instance.collection('users');

          return FutureBuilder<DocumentSnapshot>(
            future: usersCollection.doc(uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.done) {
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  // User document found, navigate to HomeScreen
                  return const HomeScreen();
                } else {
                  // User document not found, navigate to EditProfileScreen
                  return EditProfileScreen(users: snapshot.data);
                }
              } else {
                // Handle loading state, e.g., show a loading spinner
                return const ShimmerLoader();
              }
            },
          );
        }
      },
    );
  }
}
