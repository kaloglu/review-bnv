import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
final scaffoldKey = GlobalKey<ScaffoldState>();


// int newTicketCount = 0;
//
// BranchContentMetaData metadata = BranchContentMetaData();
// BranchUniversalObject? buo;
// BranchLinkProperties lp = BranchLinkProperties();
// BranchEvent? eventStandard;
// BranchEvent? eventCustom;
//
// StreamSubscription<Map>? streamSubscription;
// StreamController<String> controllerData = StreamController<String>();
// StreamController<String> controllerInitSession = StreamController<String>();
// User? senderUserId = FirebaseAuth.instance.currentUser;
// // Define it here to make it accessible in generateLink
// void listenDynamicLinks() async {
//   debugPrint('Starting dynamic link listener...');
//
//   FlutterBranchSdk.initSession().listen((data) async {
//     debugPrint('Dynamic link data received: $data');
//     controllerData.sink.add((data.toString()));
//
//     if (data.containsKey('+clicked branch link') &&
//         data['+clicked branch link'] == true) {
//       debugPrint('Dynamic link clicked!');
//
//       senderUserId = data['+referrer'];
//       Map<dynamic, dynamic> firstParams =
//       await FlutterBranchSdk.getFirstReferringParams();
//
//       // Add logic to update points in Firestore here
//       await updateSenderPoints(senderUserId.toString());
//       debugPrint('First referring parameters: $firstParams');
//     }
//   }, onError: (error) {
//     debugPrint('InitSession error: ${error.toString()}');
//   });
// }
//
// Future<void> updateSenderPoints(String senderUserId) async {
//   try {
//     DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(senderUserId)
//         .get();
//
//     if (senderSnapshot.exists) {
//       int currentPoints = senderSnapshot['points'] ?? 0;
//       dynamic firstParams = await FlutterBranchSdk.getFirstReferringParams();
//       // Update the sender's points
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(senderUserId)
//           .collection('tickets')
//           .doc()
//           .set({
//         'points': currentPoints + 10, // Assuming you want to add 10 points
//       });
//
//       debugPrint('Sender points updated for user ID: $senderUserId');
//     } else {
//       debugPrint('Sender user not found.');
//     }
//   } catch (e) {
//     debugPrint('Error updating sender points: $e');
//   }
// }
//
// // void listenDynamicLinks() async {
// //   streamSubscription = FlutterBranchSdk.initSession().listen((data) async {
// //     debugPrint('listenDynamicLinks - DeepLink Data: $data');
// //     controllerData.sink.add(data.toString());
// //     debugdebugPrint('wedjiowehfiowehfieuhfwehfowehfiowehfiowehfiowehfwe');
// //     if (data.containsKey('+clicked branch link') &&
// //         data['+clicked branch link'] == true) {
// //       senderUserId = data['+referrer'];
// //
// //       // Get the first referring parameters
// //       Map<dynamic, dynamic> firstParams =
// //       await FlutterBranchSdk.getFirstReferringParams();
// //
// //       // Get the latest referring parameters
// //       Map<dynamic, dynamic> latestParams =
// //       await FlutterBranchSdk.getLatestReferringParams();
// //
// //       // Check if the sender's user ID is present in the referring parameters
// //       if (firstParams.containsKey('senderUserId') &&
// //           latestParams.containsKey('senderUserId')) {
// //         // Update the sender's points
// //         await FirebaseFirestore.instance
// //             .collection('users')
// //             .doc(senderUserId)
// //             .collection('tickets')
// //             .where('first', isEqualTo: firstParams['senderUserId'])
// //             .where('last', isEqualTo: latestParams['senderUserId'])
// //             .get()
// //             .then((snapshot) async {
// //           if (snapshot.docs.isNotEmpty) {
// //             // Update the points
// //             snapshot.docs.first.reference.update({
// //               'earn': snapshot.docs.first['earn'] + 10,
// //               'timestamp': FieldValue.serverTimestamp(),
// //             });
// //
// //             debugPrint('Sender points updated for user ID: $senderUserId');
// //           } else {
// //             // Create a new ticket
// //             await snapshot.docs.first.reference.set({
// //               'source': 'Invite Friend Ticket ',
// //               'earn': 10,
// //               'timestamp': FieldValue.serverTimestamp(),
// //             });
// //
// //             debugPrint('New ticket created for user ID: $senderUserId');
// //           }
// //         });
// //       }
// //     }
// //   }, onError: (error) {
// //     debugPrint('InitSession error: ${error.toString()}');
// //   });
// // }
//
// void initDeepLinkData() {
//   metadata = BranchContentMetaData()
//     ..addCustomMetadata('custom string', 'abcd')
//     ..addCustomMetadata('custom number', 12345)
//     ..addCustomMetadata('custom bool', true)
//     ..addCustomMetadata('custom list number', [1, 2, 3, 4, 5])
//     ..addCustomMetadata('custom list string', ['a', 'b', 'c'])
//   //--optional Custom Metadata
//     ..contentSchema = BranchContentSchema.COMMERCE PRODUCT
//     ..price = 50.99
//     ..currencyType = BranchCurrencyType.BRL
//     ..quantity = 50
//     ..sku = 'sku'
//     ..productName = 'productName'
//     ..productBrand = 'productBrand'
//     ..productCategory = BranchProductCategory.ELECTRONICS
//     ..productVariant = 'productVariant'
//     ..condition = BranchCondition.NEW
//     ..rating = 100
//     ..ratingAverage = 50
//     ..ratingMax = 100
//     ..ratingCount = 2
//     ..setAddress(
//         street: 'street',
//         city: 'city',
//         region: 'ES',
//         country: 'Brazil',
//         postalCode: '99999-987')
//     ..setLocation(31.4521685, -114.7352207);
//
//   buo = BranchUniversalObject(
//       canonicalIdentifier: 'flutter/branch',
//       //parameter canonicalUrl
//       //If your content lives both on the web and in the app, make sure you set its canonical URL
//       // (i.e. the URL of this piece of content on the web) when building any BUO.
//       // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
//       // even if the user goes to the app instead of your website! This will help your SEO efforts.
//       canonicalUrl: 'https://flutter.dev',
//       title: 'Flutter Branch Plugin',
//       // imageUrl: imageURL,
//       contentDescription: 'Flutter Branch Description',
//       /*
//         contentMetadata: BranchContentMetaData()
//           ..addCustomMetadata('custom string', 'abc')
//           ..addCustomMetadata('custom number', 12345)
//           ..addCustomMetadata('custom bool', true)
//           ..addCustomMetadata('custom list number', [1, 2, 3, 4, 5])
//           ..addCustomMetadata('custom list string', ['a', 'b', 'c']),
//          */
//       contentMetadata: metadata,
//       keywords: ['Plugin', 'Branch', 'Flutter'],
//       publiclyIndex: true,
//       locallyIndex: true,
//       expirationDateInMilliSec: DateTime.now()
//           .add(const Duration(days: 365))
//           .millisecondsSinceEpoch);
//
//   lp = BranchLinkProperties(
//       channel: 'android',
//       feature: 'sharing',
//       //parameter alias
//       //Instead of our standard encoded short url, you can specify the vanity alias.
//       // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
//       // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
//       //alias: 'https://branch.io' //define link url,
//       stage: 'new share',
//       campaign: 'campaign',
//       tags: ['one', 'two', 'three'])
//     ..addControlParam('\$uri redirect mode', '1')
//     ..addControlParam('\$ios nativelink', true)
//     ..addControlParam('\$match duration', 7200)
//     ..addControlParam('\$always deeplink', true)
//     ..addControlParam('\$android redirect timeout', 750)
//     ..addControlParam('referring user id', 'user id');
//
//   eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD TO CART)
//   //--optional Event data
//     ..transactionID = '12344555'
//     ..currency = BranchCurrencyType.BRL
//     ..revenue = 1.5
//     ..shipping = 10.2
//     ..tax = 12.3
//     ..coupon = 'test coupon'
//     ..affiliation = 'test affiliation'
//     ..eventDescription = 'Event description'
//     ..searchQuery = 'item 123'
//     ..adType = BranchEventAdType.BANNER
//     ..addCustomData(
//         'Custom Event Property Key1', 'Custom Event Property val1')
//     ..addCustomData(
//         'Custom Event Property Key2', 'Custom Event Property val2');
//
//   eventCustom = BranchEvent.customEvent('Custom event')
//     ..addCustomData(
//         'Custom Event Property Key1', 'Custom Event Property val1')
//     ..addCustomData(
//         'Custom Event Property Key2', 'Custom Event Property val2');
// }
//
// void generateLink(BuildContext context) async {
//   debugPrint('sendUser Id $senderUserId');
//   BranchResponse response =
//   await FlutterBranchSdk.getShortUrl(buo: buo!, linkProperties: lp);
//   if (response.success) {
//     String referralLink = response.result;
//
//     // Update the referral link with the sender's user ID as a query parameter
//     String modifiedReferralLink = '$referralLink?senderUserId=$senderUserId';
//
//     if (context.mounted) {
//       showGeneratedLink(context, modifiedReferralLink);
//       debugPrint(modifiedReferralLink);
//     }
//   } else {
//     showSnackBar(
//         message: 'Error : ${response.errorCode} - ${response.errorMessage}');
//   }
// }
//
// void showGeneratedLink(BuildContext context, String url) async {
//   showModalBottomSheet(
//     isDismissible: true,
//     isScrollControlled: true,
//     context: context,
//     builder: ( ) {
//       return Container(
//         padding: const EdgeInsets.all(12),
//         height: 200,
//         child: Column(
//           children: <Widget>[
//             const Center(
//               child: Text(
//                 'Link created',
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             // Text(url),
//             const SizedBox(height: 10),
//             IntrinsicWidth(
//               stepWidth: 300,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await Clipboard.setData(ClipboardData(text: url));
//                   if (context.mounted) {
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: const Center(child: Text('Copy link')),
//               ),
//             ),
//             const SizedBox(height: 10),
//             IntrinsicWidth(
//               stepWidth: 300,
//               child: ElevatedButton(
//                 onPressed: () {
//                   shareLink();
//                 },
//                 child: const Center(child: Text('Share Link')),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
//
// void shareLink() async {
//   BranchResponse response = await FlutterBranchSdk.showShareSheet(
//       buo: buo!,
//       linkProperties: lp,
//       messageText: 'My Share text',
//       androidMessageTitle: 'My Message Title',
//       androidSharingTitle: 'My Share with');
//   // Use this to enable native sharing
//
//   if (response.success) {
//     showSnackBar(message: 'showShareSheet Success', duration: 5);
//   } else {
//     showSnackBar(
//         message:
//         'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
//         duration: 5);
//   }
// }
//
// void showSnackBar({required String message, int duration = 1}) {
//   scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
//   scaffoldMessengerKey.currentState!.showSnackBar(
//     SnackBar(
//       content: Text(message),
//       duration: Duration(seconds: duration),
//     ),
//   );
// }

bool  adLoading = false;
Timer?  loadingTimer;
RewardedAd?  rewardedAd;
int  numRewardedLoadAttempts = 0;
final adUnitId = Platform.isAndroid
    ? 'ca-app-pub-3598548560105661/7588348382'
    : 'ca-app-pub-3940256099942544/1712485313';
//'ca-app-pub-3940256099942544/5224354917'
void  createRewardedAd() {
  RewardedAd.load(
    adUnitId: adUnitId,
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (RewardedAd ad) {
        debugPrint('$ad loaded.');
         rewardedAd = ad;
         numRewardedLoadAttempts = 0;
      },
      onAdFailedToLoad: (LoadAdError error) {
        debugPrint('RewardedAd failed to load: $error');
         rewardedAd = null;
         numRewardedLoadAttempts += 1;
        if ( numRewardedLoadAttempts < 5) {
           createRewardedAd();
        }
      },
    ),
  );
}

//
// String referralLink = '';
//
//
// void initializeBranch() async {
//   await FlutterBranchSdk.initSession().listen((data) {
//     if (data.containsKey("+clicked branch link") &&
//         data["+clicked branch link"] == true) {
//       // Handle referral installation
//       String referrerUserId = data['referrerUserId'];
//       updateReferrerPoints(referrerUserId);
//     }
//   });
// }
//
// Future<void> updateReferrerPoints(String referrerUserId) async {
//   // Increment points in Firestore
//   try {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(referrerUserId)
//         .update({'points': FieldValue.increment(1)});
//
//     debugPrint('Referrer points updated successfully.');
//   } catch (e) {
//     debugPrint('Error updating referrer points: $e');
//   }
// }
//
// Future<void> generateReferralLink() async {
//   final buo = BranchUniversalObject(
//     canonicalIdentifier: 'referralLink',
//     title: 'Join Our App!',
//     contentDescription: 'Install the app and earn points.',
//   );
//
//   final lp = BranchLinkProperties(
//     channel: 'referral',
//     feature: 'invite',
//   );
//
//   final response = await FlutterBranchSdk.getShortUrl(
//     buo: buo,
//     linkProperties: lp,
//   );
//
//   if (response.success) {
//     setState(() {
//       referralLink = response.result;
//     });
//   } else {
//     debugPrint('Error generating referral link: ${response.errorCode}');
//   }
// }
//
//




Future<void>  updateFirestoreWithTicket(RewardItem reward) async {
  debugPrint('nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn');
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
            'earn':reward.amount ,
            'createDate': FieldValue.serverTimestamp(),
            'source': 'Ad Reward Tickets',
            'remain': reward.amount,

            'expiryDate': DateTime(
                currentDate.year, currentDate.month, currentDate.day + 1),
          });
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(content: Text("You Earned $rewardedAd Tickets")),
          );
        } else {
          // The latest ticket is expired, only add the newly earned ticket
          // Create a timestamp-based document ID
          final newTicketDocId =
          DateTime.now().millisecondsSinceEpoch.toString();

          // Create a new document with the timestamp-based ID in the 'tickets' subcollection
          final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
          await newTicketDocRef.set({
            'earn':reward.amount,
            'createDate': FieldValue.serverTimestamp(),
            'source': 'Ad Reward Tickets',
            'remain': reward.amount,
            'expiryDate': DateTime(
                currentDate.year, currentDate.month, currentDate.day + 1),
          });
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(content: Text("You Earned $rewardedAd Tickets")),
          );
        }
      } else {
        // No existing tickets, only add the newly earned ticket
        // Create a timestamp-based document ID
        final newTicketDocId =
        DateTime.now().millisecondsSinceEpoch.toString();

        // Create a new document with the timestamp-based ID in the 'tickets' subcollection
        final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
        await newTicketDocRef.set({
          'earn': reward.amount,
          'createDate': FieldValue.serverTimestamp(),
          'source': 'Ad Reward Tickets',
          'remain': reward.amount,
          'expiryDate': DateTime(
              currentDate.year, currentDate.month, currentDate.day + 1),
        });
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text("You Earned $rewardedAd rewardAd Tickets")),
        );
      }
    } catch (e) {
      debugPrint('Error updating Firestore: $e');
    }
  }
}

 showRewardedAd() {
  if ( rewardedAd == null) {
    debugPrint('Warning: attempt to show rewarded before loaded.');
    return Fluttertoast.showToast(
        msg: 'Try Again Later',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16);
  }

  // setState(() {
  //    adLoading = true;
  // });
   //startLoadingTimer(); // Start the timer before setting  adLoading to true
   rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (RewardedAd ad) =>
        debugPrint('ad onAdShowedFullScreenContent.'),
    onAdDismissedFullScreenContent: (RewardedAd ad) {
      debugPrint('$ad onAdDismissedFullScreenContent.');
      ad.dispose();
       createRewardedAd();
       //stopLoadingTimer();
    },
    onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
      debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
      ad.dispose();

       createRewardedAd();
      // stopLoadingTimer();
    },
  );

   rewardedAd!.setImmersiveMode(true);
   rewardedAd!.show(
    onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint(
          '$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
       updateFirestoreWithTicket(reward);
    },
  );
   //rewardedAd = null;
}




// void  startLoadingTimer() {
//    loadingTimer = Timer(const Duration(seconds: 5), () {
//     setState(() {
//        adLoading = false;
//     });
//   });
// }
// final loadingStateProvider = StateProvider<bool>((ref) => true);
// void stopLoadingTimer() {
//   loadingTimer?.cancel();
//   loadingTimer = null;
//   ref.read(loadingStateProvider.notifier).update((state) => false);
// }




















//
// import 'dart:async';
// import 'dart:io';
//
// import 'package:cloud firestore/cloud firestore.dart';
// import 'package:firebase auth/firebase auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google mobile ads/google mobile ads.dart';
//
//
//
// bool  adLoading = false;
// Timer?  loadingTimer;
// bool  timerActive = false;
// int newTicketCount = 0;
// bool luckyDrawExecuted = false;
// late StreamSubscription streamSubscription;
// String status = 'Initial Status';
// late final StreamController<bool>  buttonEnabledController;
//
// // DateTime? resultDate;
// late final String remainingTime;
//
//
//
//
//
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
//           // num remainingPoints =
//           //     reward.amount + (latestTicketDoc.data()['remain'] as int);
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
//             'source': reward.type.toString(),
//             'remain': reward.amount,
//             'expiryDate': DateTime(
//                 currentDate.year, currentDate.month, currentDate.day + 1),
//           });
//           Fluttertoast.showToast(msg: "You Earned ${reward.amount} Tickets");
//           // if (!mounted) {
//           //   return;
//           // }
//           //
//           // ScaffoldMessenger.of(context).showSnackBar(
//           //   SnackBar(content: Text("You Earned ${reward.amount} Tickets")),
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
//             'source': reward.type.toString(),
//             'remain': reward.amount,
//             'expiryDate': DateTime(
//                 currentDate.year, currentDate.month, currentDate.day + 1),
//           });
//           Fluttertoast.showToast(msg: "You Earned ${reward.amount} Tickets");
//           // if (!mounted) {
//           //   return;
//           // }
//           // ScaffoldMessenger.of(context).showSnackBar(
//           //   SnackBar(content: Text("You Earned ${reward.amount} Tickets")),
//           // );
//         }
//       } else {
//         // No existing tickets, only add the newly earned ticket
//         // Create a timestamp-based document ID
//         final newTicketDocId =
//         DateTime.now().millisecondsSinceEpoch.toString();
//
//         // Create a new document with the timestamp-based ID in the 'tickets' subcollection
//         final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
//         await newTicketDocRef.set({
//           'earn': reward.amount.toString(),
//           'createDate': FieldValue.serverTimestamp(),
//           'source': reward.type.toString(),
//           'remain': reward.amount,
//           'expiryDate': DateTime(
//               currentDate.year, currentDate.month, currentDate.day + 1),
//         });
//         Fluttertoast.showToast(msg: "You Earned ${reward.amount} Tickets");
//         // if (!mounted) {
//         //   return;
//         // }
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(content: Text("You have earned ${reward.amount} tickets")),
//         // );
//       }
//     } catch (e) {
//       debugPrint('Error updating Firestore: $e');
//     }
//   }
// }
//
// showRewardedAd() {
//   if (rewardedAd == null) {
//     debugPrint('Warning: attempt to show rewarded before loaded.');
//     return Fluttertoast.showToast(
//         msg: 'Try Again Later',
//         toastLength: Toast.LENGTH SHORT,
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
//  //  startLoadingTimer(); // Start the timer before setting  adLoading to true
//   rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
//     onAdShowedFullScreenContent: (RewardedAd ad) =>
//         print('ad onAdShowedFullScreenContent.'),
//     onAdDismissedFullScreenContent: (RewardedAd ad) {
//       debugPrint('$ad onAdDismissedFullScreenContent.');
//       ad.dispose();
//       createRewardedAd();
//       // stopLoadingTimer();
//     },
//     onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//       debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
//       ad.dispose();
//
//       createRewardedAd();
//      //  stopLoadingTimer();
//     },
//   );
//
//   rewardedAd!.setImmersiveMode(true);
//   rewardedAd!.show(
//     onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
//       debugPrint(
//           '$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
//       updateFirestoreWithTicket(reward);
//     },
//   );
//   rewardedAd = null;
// }
//
// // void  startLoadingTimer() {
// //    loadingTimer = Timer(const Duration(seconds: 5), () {
// //     setState(() {
// //        adLoading = false;
// //     });
// //   });
// // }
//
// RewardedAd? rewardedAd;
// int  numRewardedLoadAttempts = 0;
// final adUnitId = Platform.isAndroid
//     ? 'ca-app-pub-3940256099942544/5224354917'
//     : 'ca-app-pub-3940256099942544/1712485313';
//
// void createRewardedAd() {
//   RewardedAd.load(
//     adUnitId: adUnitId,
//     request: const AdRequest(),
//     rewardedAdLoadCallback: RewardedAdLoadCallback(
//       onAdLoaded: (RewardedAd ad) {
//         if (kDebugMode) {
//           print('$ad loaded.');
//         }
//         rewardedAd = ad;
//          numRewardedLoadAttempts = 0;
//       },
//       onAdFailedToLoad: (LoadAdError error) {
//         if (kDebugMode) {
//           print('RewardedAd failed to load: $error');
//         }
//         rewardedAd = null;
//          numRewardedLoadAttempts += 1;
//         if ( numRewardedLoadAttempts < 5) {
//           createRewardedAd();
//         }
//       },
//     ),
//   );
// }
// // void  stopLoadingTimer() {
// //    loadingTimer?.cancel();
// //    loadingTimer = null;
// //   setState(() {
// //      adLoading = false;
// //   });
// // }
