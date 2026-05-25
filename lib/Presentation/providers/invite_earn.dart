import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
int newTicketCount = 0;

StreamSubscription<PendingDynamicLinkData>? streamSubscription;
final StreamController<String> controllerData = StreamController<String>();
User? senderUserId = FirebaseAuth.instance.currentUser;
String? lastGeneratedInviteUrl;

void listenDynamicLinks() async {
  debugPrint('Dinamik bağlantı dinleyicisi başlatılıyor...');
  try {
    // Uygulama açıkken gelen linkler
    streamSubscription = FirebaseDynamicLinks.instance.onLink.listen((data) async {
      final deepLink = data.link;
      controllerData.sink.add(deepLink.toString());
      final referrer = deepLink.queryParameters['senderUserId'];
      final uniqueLinkId = deepLink.queryParameters['uniqueLinkId'];
      if (referrer != null) {
        await updateSenderPoints(referrer, {'uniqueLinkId': uniqueLinkId});
        debugPrint('Dinamik bağlantı yakalandı: senderUserId=$referrer uniqueLinkId=$uniqueLinkId');
      }
    }, onError: (error) {
      debugPrint('DynamicLinks onLink hata: $error');
    });

    // Soğuk başlangıç linki
    final initialData = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialData != null) {
      final deepLink = initialData.link;
      final referrer = deepLink.queryParameters['senderUserId'];
      final uniqueLinkId = deepLink.queryParameters['uniqueLinkId'];
      if (referrer != null) {
        await updateSenderPoints(referrer, {'uniqueLinkId': uniqueLinkId});
        debugPrint('Initial dynamic link işlendi: senderUserId=$referrer uniqueLinkId=$uniqueLinkId');
      }
    }
  } catch (e) {
    debugPrint('DynamicLinks başlatma hatası: $e');
  }
}

Future<void> updateSenderPoints(String userId, Map<dynamic, dynamic> firstParams) async {
  try {
    DocumentSnapshot senderSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (senderSnapshot.exists) {
      int currentPoints = senderSnapshot['points'] ?? 0;

      // Access and use the uniqueLinkId for tracking or validation
      final String? uniqueLinkId = (firstParams['uniqueLinkId'] as String?);
      // Handle cases where uniqueLinkId is missing or invalid

      // ... (rest of the code for updating points and custom logic)

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tickets')
          .doc()
          .set({
        'points': currentPoints + 10,
        'uniqueLinkId': uniqueLinkId,
        'created_at': FieldValue.serverTimestamp(),
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

void initDeepLinkData() {}

Future<void> generateLink(BuildContext context) async {
  initDeepLinkData();
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final String uniqueLinkId = UniqueKey().toString();

  // NOT: uriPrefix (https://bnv.page.link) Firebase Console’da yapılandırılmalıdır.
  final parameters = DynamicLinkParameters(
    link: Uri.parse('https://bnv.page.link/invite?senderUserId=$uid&uniqueLinkId=$uniqueLinkId'),
    uriPrefix: 'https://bnv.page.link',
    androidParameters: const AndroidParameters(packageName: 'com.kaloglu.bedavanevar', minimumVersion: 1),
    iosParameters: const IOSParameters(bundleId: 'com.kaloglu.bedavanevar'),
    socialMetaTagParameters: const SocialMetaTagParameters(title: 'BedavaNevar', description: 'BedavaNevar ile ücretsiz çekilişlere katıl!'),
  );

  try {
    final shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    final url = shortLink.shortUrl.toString();
    lastGeneratedInviteUrl = url;
    if (context.mounted) showGeneratedLink(context, url);
  } catch (e) {
    debugPrint('Dinamik bağlantı oluşturma hatası: $e');
    showSnackBar(message: 'Bağlantı oluşturulamadı');
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
  if (lastGeneratedInviteUrl == null) {
    showSnackBar(message: 'Önce bağlantı oluşturun');
    return;
  }
  try {
    await Share.share(lastGeneratedInviteUrl!);
  } catch (e) {
    debugPrint('Paylaşım hatası: $e');
    showSnackBar(message: 'Paylaşım başarısız');
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
