import 'package:cihan_app/constants/app_colors.dart';
import 'package:cihan_app/constants/text_styles.dart';

import 'package:cihan_app/presentation/screens/home_screen.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/my_button.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'edit_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Check if a user is already signed in with Google
      if (FirebaseAuth.instance.currentUser != null) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // If the user is already signed in, proceed to the HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
          return;
        }
      }

      // If the user is not signed in with Google, sign them in
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        User user = userCredential.user!;
        if (!user.isAnonymous) {
          // Check if an existing user with the same email (linked to Facebook) exists
          final List<String> providers =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(user.email!);

          if (providers.contains("facebook.com")) {
            // Prompt the user to link accounts
            showLinkAccountsDialog(context, user);
            return; // Return to prevent account linking
          }
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error while signing in with Google: $e");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Hey there,',
                  style: kMediumTextStyle,
                ),
                Text(
                  'Welcome Back',
                  style: kLargeTextStyle,
                ),
                50.ph,

                SignInButton(
                    Buttons.Google,
                    onPressed: (){
                  _signInWithGoogle(context);
                    }),


                // MyButton(
                //   onTap: () {
                //     _signInWithGoogle(context);
                //   },
                //   title: 'Google',
                //   bgColor: AppColors.primaryColor,
                //   textColor: Colors.white,
                //   icon: EvaIcons.google,
                // ),
                12.ph,
                SignInButton(
                    Buttons.Facebook,
                    onPressed: (){
                      signInWithFacebook(context);
                      (context);
                    }),
                // MyButton(
                //   onTap: () {
                //     // Navigator.of(context).push(
                //     //   MaterialPageRoute(
                //     //     builder: (context) => const HomeScreen(),
                //     //   ),
                //     // );
                //   },
                //   title: 'Twitter',
                //   bgColor: AppColors.primaryColor,
                //   textColor: Colors.white,
                //   icon: EvaIcons.twitter,
                // ),
                12.ph,
                MyButton(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => const HomeScreen(),
                    //   ),
                    // );
                  },
                  title: 'Facebook',
                  bgColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  icon: EvaIcons.facebook,
                ),
                12.ph,
                MyButton(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  title: 'Phone Auth',
                  bgColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  icon: EvaIcons.phone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Check if a user is already signed in with Facebook
      if (FirebaseAuth.instance.currentUser != null) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // If the user is already signed in, proceed to the HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
          return;
        }
      }

      // If the user is not signed in with Facebook, sign them in
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      if (userCredential.user != null) {
        User user = userCredential.user!;
        if (!user.isAnonymous) {
          // Check if an existing user with the same email (linked to Google) exists
          final List<String> providers =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(user.email!);

          if (providers.contains("google.com")) {
            // Prompt the user to link accounts
            showLinkAccountsDialog(context, user);
            return; // Return to prevent account linking
          }
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } catch (e) {
      print("Error while signing in with Facebook: $e");
    }
  }

  Future<void> showLinkAccountsDialog(BuildContext context, User user) async {
    try {
      // Show a dialog to inform the user about the account linking process
      AlertDialog alert = AlertDialog(
        title: Text("Account Exists"),
        content: Text(
          "An account with the same email exists but was signed in using a different provider. Would you like to link the accounts?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Link the accounts
              linkAccounts(user);
              Navigator.of(context).pop();
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("No"),
          ),
        ],
      );

      // Show the dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } catch (e) {
      print("Error showing account linking dialog: $e");
    }
  }

  Future<void> linkAccounts(User user) async {
    try {
      // Initialize the existingCredential variable to null
      AuthCredential? existingCredential;

      // Get the current user's provider data
      List<UserInfo> providers = user.providerData;

      // Loop through the provider data to find the existing credential
      for (UserInfo userInfo in providers) {
        if (userInfo.providerId == "google.com") {
          // User has previously signed in with Google
          // Fetch the Google ID token and access token
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
          existingCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );
          break;
        } else if (userInfo.providerId == "facebook.com") {
          // User has previously signed in with Facebook
          // Fetch the Facebook access token
          final LoginResult loginResult =
          await FacebookAuth.instance.login(permissions: ["email"]);
          existingCredential = FacebookAuthProvider.credential(
            loginResult.accessToken!.token,
          );
          break;
        }
        // Add more conditions for other providers if necessary
      }

      // Check if the existingCredential is not null
      if (existingCredential != null) {
        // Link the accounts
        await user.linkWithCredential(existingCredential);

        // Navigate to the HomeScreen after successful linking
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        // Handle the case when the existingCredential is null
        print("Error: No existing credential found.");
      }
    } catch (e) {
      print("Error linking accounts: $e");
    }
  }




}
