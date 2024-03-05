import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
int newTicketCount = 0;

//BranchContentMetaData metadata = BranchContentMetaData();
late BranchUniversalObject buo;
BranchLinkProperties lp = BranchLinkProperties();
//BranchEvent? eventStandard;
//BranchEvent? eventCustom;

StreamSubscription<Map>? streamSubscription;
StreamController<String> controllerData = StreamController<String>();
//StreamController<String> controllerInitSession = StreamController<String>();
User? senderUserId = FirebaseAuth.instance.currentUser;
// Define it here to make it accessible in generateLink

void listenDynamicLinks() async {
  debugPrint('Starting dynamic link listener...');

 streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
    debugPrint('Dynamic link data received: $data');
    controllerData.sink.add((data.toString()));

    if (data.containsKey('+clicked_branch_link') &&
        data['+clicked_branch_link'] == true) {
      debugPrint('Dynamic link clicked!');

      senderUserId = data['+referrer'];
      Map<dynamic, dynamic> firstParams =
          await FlutterBranchSdk.getFirstReferringParams();

      // Add logic to update points in Firestore using firstParams
      await updateSenderPoints(senderUserId.toString(), firstParams);
      debugPrint('First referring parameters: $firstParams');
    }
  }, onError: (error) {
    debugPrint('InitSession error: ${error.toString()}');
  });
}

Future<void> updateSenderPoints(
    String userId, Map<dynamic, dynamic> firstParams) async {
  try {
    DocumentSnapshot senderSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (senderSnapshot.exists) {
      int currentPoints = senderSnapshot['points'] ?? 0;

      // Access and use the uniqueLinkId for tracking or validation
      String uniqueLinkId = firstParams['uniqueLinkId'];
      // Handle cases where uniqueLinkId is missing or invalid

      // ... (rest of the code for updating points and custom logic)

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tickets')
          .doc()
          .set({
        'points': currentPoints + 10, // Assuming you want to add 10 points
        'customParamValue': firstParams['customParam'],
        'uniqueLinkId': uniqueLinkId,
      });

      debugPrint(
          'Sender points updated for user ID: $userId, uniqueLinkId: $uniqueLinkId');
    } else {
      debugPrint('Sender user not found.');
    }
  } catch (e) {
    debugPrint('Error updating sender points: $e');
  }
}

// Future<void> updateSenderPoints(String userId, Map<dynamic, dynamic> firstParams) async {
//
//   try {
//     DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .get();
//
//     if (senderSnapshot.exists) {
//       int currentPoints = senderSnapshot['points'] ?? 0;
//
//       // Use firstParams to customize the update logic, for example:
//       String customParamValue = firstParams['customParam'];
//
//       // Update the sender's points
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('tickets')
//           .doc()
//           .set({
//         'points': currentPoints + 10, // Assuming you want to add 10 points
//         'customParamValue': customParamValue,
//       });
//
//       debugPrint('Sender points updated for user ID: $userId');
//     } else {
//       debugPrint('Sender user not found.');
//     }
//   } catch (e) {
//     debugPrint('Error updating sender points: $e');
//   }
// }

void initDeepLinkData() {
  buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      //parameter canonicalUrl
      //If your content lives both on the web and in the app, make sure you set its canonical URL
      // (i.e. the URL of this piece of content on the web) when building any BUO.
      // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
      // even if the user goes to the app instead of your website! This will help your SEO efforts.
      // canonicalUrl: 'https://flutter.dev',
      title: 'BedavaNevar',
      //imageUrl: '',
      contentDescription: 'You can win many rewards in this BedavaNevar app',

      // contentMetadata: metadata,
      keywords: ['Plugin', 'Branch', 'Flutter'],
      publiclyIndex: true,
      locallyIndex: true,
      expirationDateInMilliSec:
          DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch);

  lp = BranchLinkProperties(channel: 'android', feature: 'sharing');
  //parameter alias
  //Instead of our standard encoded short url, you can specify the vanity alias.
  // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
  // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
  // alias: 'https://branch.io', //define link url,
  //stage: 'new share',
  //campaign: 'campaign',
  // tags: ['one', 'two', 'three'])
  // ..addControlParam('\$uri_redirect_mode', '1')
  // ..addControlParam('\$ios_nativelink', true)
  // ..addControlParam('\$match_duration', 7200)
  // ..addControlParam('\$always_deeplink', true)
  // ..addControlParam('\$android_redirect_timeout', 750)
  // ..addControlParam('referring_user_id', 'user_id');

  // eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
  // //--optional Event data
  //   ..transactionID = '12344555'
  //   ..currency = BranchCurrencyType.BRL
  //   ..revenue = 1.5
  //   ..shipping = 10.2
  //   ..tax = 12.3
  //   ..coupon = 'test_coupon'
  //   ..affiliation = 'test_affiliation'
  //   ..eventDescription = 'Event_description'
  //   ..searchQuery = 'item 123'
  //   ..adType = BranchEventAdType.BANNER
  //   ..addCustomData(
  //       'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
  //   ..addCustomData(
  //       'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');

  // eventCustom = BranchEvent.customEvent('Custom_event')
  //   ..addCustomData(
  //       'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
  //   ..addCustomData(
  //       'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
}

void generateLink(BuildContext context) async {
  initDeepLinkData();
  // Check if senderUserId is available
  String? senderUserId = FirebaseAuth.instance.currentUser?.uid;
  if (senderUserId == null) {
    // Handle error: Unable to get senderUserId
    return;
  }

  // Generate unique link identifier
  String uniqueLinkId = UniqueKey().toString();

  // Assuming 'lp' is your BranchLinkProperties instance
  // Directly add custom parameters using addControlParam
  lp.addControlParam('senderUserId', senderUserId);
  lp.addControlParam('uniqueLinkId', uniqueLinkId);

  // Assuming 'buo' is your BranchUniversalObject instance
  // Now 'lp' already includes your custom parameters

  // Get short URL
  BranchResponse response =
      await FlutterBranchSdk.getShortUrl(buo: buo!, linkProperties: lp);

  if (response.success) {
    showGeneratedLink(context, response.result);
    // String referralLink = response.result;

    // Update referral link with query parameters
    // String modifiedReferralLink =
    //     '$referralLink?senderUserId=$senderUserId&uniqueLinkId=$uniqueLinkId';

    // Validate link format (optional)
    //  Uri linkUri = Uri.parse(modifiedReferralLink);
    //   if (linkUri.queryParameters.containsKey('senderUserId') ||
    //       linkUri.queryParameters.containsKey('uniqueLinkId')) {
    //     // Handle error: senderUserId or uniqueLinkId missing
    //     return;
    //   }

    // ... (rest of your existing code for showing or sharing the link)
  } else {
    // Handle error: Branch response failed
    showSnackBar(
      message: 'Error: ${response.errorCode} - ${response.errorMessage}',
    );
  }
}
// void generateLink(BuildContext context) async {
//   initDeepLinkData();
//   BranchResponse response =
//   await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
//   if (response.success) {
//     if (context.mounted) {
//       showGeneratedLink(context, response.result);
//     }
//   } else {
//     showSnackBar(
//         message: 'Error : ${response.errorCode} - ${response.errorMessage}');
//   }
// }
// void generateLink(BuildContext context) async {
//  // debugPrint('senderUserId: $senderUserId');
//
//   // Check if senderUserId is available
//   String? senderUserId = FirebaseAuth.instance.currentUser?.uid;
//   if (senderUserId == null) {
//     // Handle error: Unable to get senderUserId
//     return;
//   }
//
//   // Generate unique link identifier
//   String uniqueLinkId = UniqueKey().toString();
//
//   // Assuming 'lp' is your BranchLinkProperties instance
//   // Directly add custom parameters using addControlParam
//   lp.addControlParam('senderUserId', senderUserId);
//   lp.addControlParam('uniqueLinkId', uniqueLinkId);
//
//   // Assuming 'buo' is your BranchUniversalObject instance
//   // Now 'lp' already includes your custom parameters
//
//   // Get short URL
//   BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo!, linkProperties: lp);
//
//   if (response.success) {
//     String referralLink = response.result;
//
//     // Further code remains unchanged...
//   } else {
//     // Handle error: Branch response failed
//     showSnackBar(
//          message: 'Error : ${response.errorCode} - ${response.errorMessage}');
//   }
// }

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

void showGeneratedLink(BuildContext context, String url) async {
  showModalBottomSheet(
    isDismissible: true,
    isScrollControlled: true,
    context: context,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.all(12),
        height: 200,
        child: Column(
          children: <Widget>[
            const Center(
              child: Text(
                'Link created',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Text(url),
            const SizedBox(height: 10),
            IntrinsicWidth(
              stepWidth: 300,
              child: ElevatedButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Center(child: Text('Copy link')),
              ),
            ),
            const SizedBox(height: 10),
            IntrinsicWidth(
              stepWidth: 300,
              child: ElevatedButton(
                onPressed: () {
                  shareLink();
                },
                child: const Center(child: Text('Share Link')),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void shareLink() async {
  BranchResponse response = await FlutterBranchSdk.showShareSheet(
      buo: buo!,
      linkProperties: lp,
      messageText: 'Click this Link and Earn Rewards',
      androidMessageTitle: 'My Message Title',
      androidSharingTitle: 'My Share with');
  // Use this to enable native sharing

  if (response.success) {
    showSnackBar(message: 'showShareSheet Success', duration: 5);
  } else {
    showSnackBar(
        message:
            'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
        duration: 5);
  }
}

void showSnackBar({required String message, int duration = 1}) {
  scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
  scaffoldMessengerKey.currentState!.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: duration),
    ),
  );
}
