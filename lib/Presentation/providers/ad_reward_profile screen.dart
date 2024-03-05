import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/lang.dart';
import '../constants/text_styles.dart';
import 'enroll_user_provider.dart';




RewardedInterstitialAd? rewardedInterstitialAd;
int _numRewardedInterstitialLoadAttempts = 0;
const int maxFailedLoadAttempts = 5;
void createRewardedInterstitialAd() {
  RewardedInterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3598548560105661/1004823819'
     : 'ca-app-pub-0165663276066705/3101585683',
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          debugPrint('$ad loaded.');
          rewardedInterstitialAd = ad;
          _numRewardedInterstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedInterstitialAd failed to load: $error');
          rewardedInterstitialAd = null;
          _numRewardedInterstitialLoadAttempts += 1;
          if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
            createRewardedInterstitialAd();
          }
        },
      ));
}

 showRewardedInterstitialAd() {
  if (rewardedInterstitialAd == null) {
    debugPrint('Warning: attempt to show rewarded interstitial before loaded.');

    return Fluttertoast.showToast(msg: "Please Try in a Few seconds",gravity: ToastGravity.CENTER,backgroundColor: Colors.red,textColor: Colors.white);
  }
  rewardedInterstitialAd!.fullScreenContentCallback =
      FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
            debugPrint('$ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
          debugPrint('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          createRewardedInterstitialAd();
        },
        onAdFailedToShowFullScreenContent:
            (RewardedInterstitialAd ad, AdError error) {
          debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          createRewardedInterstitialAd();
        },
      );

  rewardedInterstitialAd!.setImmersiveMode(true);
  rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        updateFirestoreWithTickets(reward);
        debugPrint('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      });
  rewardedInterstitialAd = null;
}

Future<void> updateFirestoreWithTickets(RewardItem reward) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(user.uid);
    final ticketCollectionRef = userDocRef.collection('tickets');

    try {
      // Get the user's existing tickets and sort them by createDate in descending order
      final userTicketsQuery =
      ticketCollectionRef.orderBy('createDate', descending: true);

      final userTicketsSnapshot = await userTicketsQuery.get();

      final currentDate = DateTime.now();

      // Check if there's a latest non-expired ticket
      if (userTicketsSnapshot.docs.isNotEmpty) {
        final latestTicketDoc = userTicketsSnapshot.docs[0];
        final expiryDate =
        (latestTicketDoc['expiryDate'] as Timestamp).toDate();

        if (currentDate.isBefore(expiryDate)) {
          // The latest ticket is not expired, add its tickets to remaining points
          // int remainingPoints =
          //     newTicketCot + (latestTicketDoc.data()['remain'] as int);

          // Create a timestamp-based document ID
          final newTicketDocId =
          DateTime.now().millisecondsSinceEpoch.toString();

          // Create a new document with the timestamp-based ID in the 'tickets' subcollection
          final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
          await newTicketDocRef.set({
            'earn': reward.amount.toString(),
            'createDate': FieldValue.serverTimestamp(),
            'source': 'Ad Reward Tickets',
            'remain': reward.amount,
            'expiryDate': DateTime(
                currentDate.year, currentDate.month, currentDate.day + 1),
          });
          Fluttertoast.showToast(
              msg: "You Earned ${reward.amount} rewarded Tickets");
          // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          //   SnackBar(content: Text("You Earned $rewardedAd Tickets")),
          // );
        } else {
          // The latest ticket is expired, only add the newly earned ticket
          // Create a timestamp-based document ID
          final newTicketDocId =
          DateTime.now().millisecondsSinceEpoch.toString();

          // Create a new document with the timestamp-based ID in the 'tickets' subcollection
          final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
          await newTicketDocRef.set({
            'earn': reward.amount.toString(),
            'createDate': FieldValue.serverTimestamp(),
            'source': 'Ad Reward Tickets',
            'remain': reward.amount,
            'expiryDate': DateTime(
                currentDate.year, currentDate.month, currentDate.day + 1),
          });
          showDialogWithoutContext(
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                // This makes the dialog square
                borderRadius: BorderRadius.circular(0),
              ),

              backgroundColor:
              Colors.white, // Make AlertDialog background transparent
              content: Column(
                mainAxisSize: MainAxisSize.min, // Use min size
                children: <Widget>[
                  Container(
                    width: 100, // Diameter of the circle
                    height:
                    100, // Diameter of the circle, make sure width and height are equal to get a perfect circle
                    decoration: const BoxDecoration(
                      color: Colors.blue, // Your desired background color
                      shape: BoxShape.circle, // This makes the container a circle
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          8.0), // Adjust padding to avoid the image touching the edges
                      child: ClipOval(
                        // Clip the image to Oval shape to fit the circle container
                        child: Image.asset(
                          'assets/dialogueTicket.png',
                          color: Colors.black,
                          // fit: BoxFit.cover, // This ensures the image covers the container space, adjust as needed
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Bilgi',
                      style: kMediumTextStyle.copyWith(
                        fontWeight: FontWeight.w900,
                      )),
                  const SizedBox(height: 10), // Space between icon and text
                  Text("You Earned ${reward.amount} rewarded Tickets"), // Your message
                ],
              ),

              actions: <Widget>[
                Center(
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                            const TextStyle(fontSize: 16.5)),
                        backgroundColor:
                        MaterialStateProperty.all(const Color(0XFF87ceeb)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        AppStrings.okay,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          // Fluttertoast.showToast(
          //     msg: "You Earned ${reward.amount} rewarded Tickets");
          // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          //   SnackBar(content: Text("You Earned $rewardedAd Tickets")),
          // );
        }
      } else {
        // No existing tickets, only add the newly earned ticket
        // Create a timestamp-based document ID
        final newTicketDocId = DateTime.now().millisecondsSinceEpoch.toString();

        // Create a new document with the timestamp-based ID in the 'tickets' subcollection
        final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
        await newTicketDocRef.set({
          'earn': reward.amount.toString(),
          'createDate': FieldValue.serverTimestamp(),
          'source': 'Ad Reward Tickets',
          'remain': reward.amount,
          'expiryDate': DateTime(
              currentDate.year, currentDate.month, currentDate.day + 1),
        });
        showDialogWithoutContext(
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              // This makes the dialog square
              borderRadius: BorderRadius.circular(0),
            ),

            backgroundColor:
            Colors.white, // Make AlertDialog background transparent
            content: Column(
              mainAxisSize: MainAxisSize.min, // Use min size
              children: <Widget>[
                Container(
                  width: 100, // Diameter of the circle
                  height:
                  100, // Diameter of the circle, make sure width and height are equal to get a perfect circle
                  decoration: const BoxDecoration(
                    color: Colors.blue, // Your desired background color
                    shape: BoxShape.circle, // This makes the container a circle
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        8.0), // Adjust padding to avoid the image touching the edges
                    child: ClipOval(
                      // Clip the image to Oval shape to fit the circle container
                      child: Image.asset(
                        'assets/dialogueTicket.png',
                        color: Colors.black,
                        // fit: BoxFit.cover, // This ensures the image covers the container space, adjust as needed
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Bilgi',
                    style: kMediumTextStyle.copyWith(
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 10), // Space between icon and text
                Text("You Earned ${reward.amount} rewarded Tickets"), // Your message
              ],
            ),

            actions: <Widget>[
              Center(
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 16.5)),
                      backgroundColor:
                      MaterialStateProperty.all(const Color(0XFF87ceeb)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      AppStrings.okay,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        // Fluttertoast.showToast(msg: "You Earned ${reward.amount} rewarded Tickets");
        // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        //   SnackBar(content: Text("You Earned $rewardedAd rewardAd Tickets")),
        // );
      }
    } catch (e) {
      debugPrint('Error updating Firestore: $e');
    }
  }
}





// RewardedInterstitialAd? rewardedAdProfile;
// int numRewardedLoadAttempts = 0;
// final adUnitId = Platform.isAndroid
//     ? 'ca-app-pub-0165663276066705/2714987853'
//     : 'ca-app-pub-0165663276066705/3101585683';
// //test//'ca-app-pub-3940256099942544/5224354917'
// void createRewardedAdProfile() {
//   RewardedAd.load(
//     adUnitId: adUnitId,
//     request: const AdRequest(),
//     rewardedAdLoadCallback: RewardedAdLoadCallback(
//       onAdLoaded: (RewardedInterstitialAd ad) {
//         debugdebugPrint('$ad loaded.');
//         rewardedAdProfile = ad;
//         numRewardedLoadAttempts = 0;
//       },
//       onAdFailedToLoad: (LoadAdError error) {
//         debugdebugPrint('RewardedAd failed to load: $error');
//         rewardedAdProfile = null;
//         numRewardedLoadAttempts += 1;
//         if (numRewardedLoadAttempts < 5) {
//           createRewardedAdProfile();
//         }
//       },
//     ),
//   );
// }
//
// Future<void> updateFirestoreWithTicket(RewardItem reward) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     final firestore = FirebaseFirestore.instance;
//     final userDocRef = firestore.collection('users').doc(user.uid);
//     final ticketCollectionRef = userDocRef.collection('tickets');
//
//     try {
//       // Get the user's existing tickets and sort them by createDate in descending order
//       final userTicketsQuery =
//       ticketCollectionRef.orderBy('createDate', descending: true);
//
//       final userTicketsSnapshot = await userTicketsQuery.get();
//
//       final currentDate = DateTime.now();
//
//       // Check if there's a latest non-expired ticket
//       if (userTicketsSnapshot.docs.isNotEmpty) {
//         final latestTicketDoc = userTicketsSnapshot.docs[0];
//         final expiryDate =
//         (latestTicketDoc['expiryDate'] as Timestamp).toDate();
//
//         if (currentDate.isBefore(expiryDate)) {
//           // The latest ticket is not expired, add its tickets to remaining points
//           // int remainingPoints =
//           //     newTicketCot + (latestTicketDoc.data()['remain'] as int);
//
//           // Create a timestamp-based document ID
//           final newTicketDocId =
//           DateTime.now().millisecondsSinceEpoch.toString();
//
//           // Create a new document with the timestamp-based ID in the 'tickets' subcollection
//           final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
//           await newTicketDocRef.set({
//             'earn': reward.amount.toString(),
//             'createDate': FieldValue.serverTimestamp(),
//             'source': 'Ad Reward Tickets',
//             'remain': reward.amount,
//             'expiryDate': DateTime(
//                 currentDate.year, currentDate.month, currentDate.day + 1),
//           });
//           Fluttertoast.showToast(
//               msg: "You Earned ${reward.amount} rewarded Tickets");
//           // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
//           //   SnackBar(content: Text("You Earned $rewardedAd Tickets")),
//           // );
//         } else {
//           // The latest ticket is expired, only add the newly earned ticket
//           // Create a timestamp-based document ID
//           final newTicketDocId =
//           DateTime.now().millisecondsSinceEpoch.toString();
//
//           // Create a new document with the timestamp-based ID in the 'tickets' subcollection
//           final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
//           await newTicketDocRef.set({
//             'earn': reward.amount.toString(),
//             'createDate': FieldValue.serverTimestamp(),
//             'source': 'Ad Reward Tickets',
//             'remain': reward.amount,
//             'expiryDate': DateTime(
//                 currentDate.year, currentDate.month, currentDate.day + 1),
//           });
//           Fluttertoast.showToast(
//               msg: "You Earned ${reward.amount} rewarded Tickets");
//           // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
//           //   SnackBar(content: Text("You Earned $rewardedAd Tickets")),
//           // );
//         }
//       } else {
//         // No existing tickets, only add the newly earned ticket
//         // Create a timestamp-based document ID
//         final newTicketDocId = DateTime.now().millisecondsSinceEpoch.toString();
//
//         // Create a new document with the timestamp-based ID in the 'tickets' subcollection
//         final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
//         await newTicketDocRef.set({
//           'earn': reward.amount.toString(),
//           'createDate': FieldValue.serverTimestamp(),
//           'source': 'Ad Reward Tickets',
//           'remain': reward.amount,
//           'expiryDate': DateTime(
//               currentDate.year, currentDate.month, currentDate.day + 1),
//         });
//         Fluttertoast.showToast(msg: "You Earned ${reward.amount} rewarded Tickets");
//         // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
//         //   SnackBar(content: Text("You Earned $rewardedAd rewardAd Tickets")),
//         // );
//       }
//     } catch (e) {
//       debugdebugPrint('Error updating Firestore: $e');
//     }
//   }
// }
//
// showRewardedAdProfile() {
//   if (rewardedAdProfile == null) {
//     debugdebugPrint('Warning: attempt to show rewarded before loaded.');
//     return Fluttertoast.showToast(
//         msg: 'Try Again in a few seconds',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.CENTER,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16);
//   }
//
//   // setState(() {
//   //    adLoading = true;
//   // });
//   //startLoadingTimer(); // Start the timer before setting  adLoading to true
//   rewardedAdProfile!.fullScreenContentCallback = FullScreenContentCallback(
//     onAdShowedFullScreenContent: (RewardedAd ad) =>
//         debugdebugPrint('ad onAdShowedFullScreenContent.'),
//     onAdDismissedFullScreenContent: (RewardedAd ad) {
//       debugdebugPrint('$ad onAdDismissedFullScreenContent.');
//       ad.dispose();
//       createRewardedAdProfile();
//       //stopLoadingTimer();
//     },
//     onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//       debugdebugPrint('$ad onAdFailedToShowFullScreenContent: $error');
//       ad.dispose();
//
//       createRewardedAdProfile();
//       // stopLoadingTimer();
//     },
//   );
//
//   rewardedAdProfile!.setImmersiveMode(true);
//   rewardedAdProfile!.show(
//     onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
//       debugdebugPrint(
//           '$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
//       updateFirestoreWithTicket(reward);
//     },
//   );
//   //rewardedAd = null;
// }

