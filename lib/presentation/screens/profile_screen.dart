import 'dart:async';
import 'dart:io';

import 'package:cihan_app/presentation/screens/edit_profile_screen.dart';
import 'package:cihan_app/presentation/screens/ticket_history_screen.dart';
import 'package:cihan_app/presentation/screens/winner_history_screen.dart';
import 'package:cihan_app/presentation/utils/icon_buttons.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:cihan_app/providers/enroll_provider.dart';
import 'package:cihan_app/providers/profile_provider.dart';
import 'package:cihan_app/services/auth_gate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

import '../../main.dart';
import '../../providers/ticket_provider.dart';
import '../utils/container_counter.dart';
import '../utils/count_with_icon.dart';
import '../utils/reusable_small_btn.dart';
import 'enroll_history_screen.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  UserProfileScreen({super.key});
  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends ConsumerState<UserProfileScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();
  int newTicketCount = 0;

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchUniversalObject? buo;
  BranchLinkProperties lp = BranchLinkProperties();
  BranchEvent? eventStandard;
  BranchEvent? eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  String senderUserId =
      ''; // Define it here to make it accessible in generateLink
  void listenDynamicLinks() async {
    print('Starting dynamic link listener...');

    FlutterBranchSdk.initSession().listen((data) async {
      print('Dynamic link data received: $data');

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        print('Dynamic link clicked!');

        senderUserId = data['+referrer'];
        Map<dynamic, dynamic> firstParams =
        await FlutterBranchSdk.getFirstReferringParams();

        // Add logic to update points in Firestore here
        await updateSenderPoints(senderUserId);
        print('First referring parameters: $firstParams');
      }
    }, onError: (error) {
      print('InitSession error: ${error.toString()}');
    });
  }


  Future<void> updateSenderPoints(String senderUserId) async {
    try {
      DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderUserId)
          .get();

      if (senderSnapshot.exists) {
        int currentPoints = senderSnapshot['points'] ?? 0;
       dynamic firstParams = await FlutterBranchSdk.getFirstReferringParams();
        // Update the sender's points
        await FirebaseFirestore.instance
            .collection('users')
            .doc(senderUserId).collection('tickets').doc()
            .set({
          'points': currentPoints + 10, // Assuming you want to add 10 points
        });

        print('Sender points updated for user ID: $senderUserId');
      } else {
        print('Sender user not found.');
      }
    } catch (e) {
      print('Error updating sender points: $e');
    }
  }

  // void listenDynamicLinks() async {
  //   streamSubscription = FlutterBranchSdk.initSession().listen((data) async {
  //     print('listenDynamicLinks - DeepLink Data: $data');
  //     controllerData.sink.add(data.toString());
  //     debugPrint('wedjiowehfiowehfieuhfwehfowehfiowehfiowehfiowehfwe');
  //     if (data.containsKey('+clicked_branch_link') &&
  //         data['+clicked_branch_link'] == true) {
  //       senderUserId = data['+referrer'];
  //
  //       // Get the first referring parameters
  //       Map<dynamic, dynamic> firstParams =
  //       await FlutterBranchSdk.getFirstReferringParams();
  //
  //       // Get the latest referring parameters
  //       Map<dynamic, dynamic> latestParams =
  //       await FlutterBranchSdk.getLatestReferringParams();
  //
  //       // Check if the sender's user ID is present in the referring parameters
  //       if (firstParams.containsKey('senderUserId') &&
  //           latestParams.containsKey('senderUserId')) {
  //         // Update the sender's points
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(senderUserId)
  //             .collection('tickets')
  //             .where('first', isEqualTo: firstParams['senderUserId'])
  //             .where('last', isEqualTo: latestParams['senderUserId'])
  //             .get()
  //             .then((snapshot) async {
  //           if (snapshot.docs.isNotEmpty) {
  //             // Update the points
  //             snapshot.docs.first.reference.update({
  //               'earn': snapshot.docs.first['earn'] + 10,
  //               'timestamp': FieldValue.serverTimestamp(),
  //             });
  //
  //             print('Sender points updated for user ID: $senderUserId');
  //           } else {
  //             // Create a new ticket
  //             await snapshot.docs.first.reference.set({
  //               'source': 'Invite Friend Ticket ',
  //               'earn': 10,
  //               'timestamp': FieldValue.serverTimestamp(),
  //             });
  //
  //             print('New ticket created for user ID: $senderUserId');
  //           }
  //         });
  //       }
  //     }
  //   }, onError: (error) {
  //     print('InitSession error: ${error.toString()}');
  //   });
  // }

  void initDeepLinkData() {
    metadata = BranchContentMetaData()
      ..addCustomMetadata('custom_string', 'abcd')..addCustomMetadata(
          'custom_number', 12345)..addCustomMetadata(
          'custom_bool', true)..addCustomMetadata(
          'custom_list_number', [1, 2, 3, 4, 5])..addCustomMetadata(
          'custom_list_string', ['a', 'b', 'c'])
    //--optional Custom Metadata
      ..contentSchema = BranchContentSchema.COMMERCE_PRODUCT
      ..price = 50.99
      ..currencyType = BranchCurrencyType.BRL
      ..quantity = 50
      ..sku = 'sku'
      ..productName = 'productName'
      ..productBrand = 'productBrand'
      ..productCategory = BranchProductCategory.ELECTRONICS
      ..productVariant = 'productVariant'
      ..condition = BranchCondition.NEW
      ..rating = 100
      ..ratingAverage = 50
      ..ratingMax = 100
      ..ratingCount = 2
      ..setAddress(
          street: 'street',
          city: 'city',
          region: 'ES',
          country: 'Brazil',
          postalCode: '99999-987')
      ..setLocation(31.4521685, -114.7352207);

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        //parameter canonicalUrl
        //If your content lives both on the web and in the app, make sure you set its canonical URL
        // (i.e. the URL of this piece of content on the web) when building any BUO.
        // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
        // even if the user goes to the app instead of your website! This will help your SEO efforts.
        canonicalUrl: 'https://flutter.dev',
        title: 'Flutter Branch Plugin',
        // imageUrl: imageURL,
        contentDescription: 'Flutter Branch Description',
        /*
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata('custom_string', 'abc')
          ..addCustomMetadata('custom_number', 12345)
          ..addCustomMetadata('custom_bool', true)
          ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
          ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
         */
        contentMetadata: metadata,
        keywords: ['Plugin', 'Branch', 'Flutter'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime
            .now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        //parameter alias
        //Instead of our standard encoded short url, you can specify the vanity alias.
        // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
        // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
        //alias: 'https://branch.io' //define link url,
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')..addControlParam(
          '\$ios_nativelink', true)..addControlParam(
          '\$match_duration', 7200)..addControlParam(
          '\$always_deeplink', true)..addControlParam(
          '\$android_redirect_timeout', 750)..addControlParam(
          'referring_user_id', 'user_id');

    eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
    //--optional Event data
      ..transactionID = '12344555'
      ..currency = BranchCurrencyType.BRL
      ..revenue = 1.5
      ..shipping = 10.2
      ..tax = 12.3
      ..coupon = 'test_coupon'
      ..affiliation = 'test_affiliation'
      ..eventDescription = 'Event_description'
      ..searchQuery = 'item 123'
      ..adType = BranchEventAdType.BANNER
      ..addCustomData(
          'Custom_Event_Property_Key1',
          'Custom_Event_Property_val1')..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');

    eventCustom = BranchEvent.customEvent('Custom_event')
      ..addCustomData(
          'Custom_Event_Property_Key1',
          'Custom_Event_Property_val1')..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
  }

  void generateLink(BuildContext context) async {
    print('sendUser Id $senderUserId');
    BranchResponse response =
    await FlutterBranchSdk.getShortUrl(buo: buo!, linkProperties: lp);
    if (response.success) {
      String referralLink = response.result;

      // Update the referral link with the sender's user ID as a query parameter
      String modifiedReferralLink = '$referralLink?senderUserId=$senderUserId';

      if (context.mounted) {
        showGeneratedLink(context, modifiedReferralLink);
        print(modifiedReferralLink);
      }
    } else {
      showSnackBar(
          message: 'Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

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
                    color: Colors.blue,
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
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      showSnackBar(message: 'showShareSheet Success', duration: 5);
    } else {
      showSnackBar(
          message:
          'showShareSheet Error: ${response.errorCode} - ${response
              .errorMessage}',
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

  bool _adLoading = false;
  Timer? _loadingTimer;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('$ad loaded.');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < 5) {
            _createRewardedAd();
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
  //     if (data.containsKey("+clicked_branch_link") &&
  //         data["+clicked_branch_link"] == true) {
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
  //     print('Referrer points updated successfully.');
  //   } catch (e) {
  //     print('Error updating referrer points: $e');
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
  //     print('Error generating referral link: ${response.errorCode}');
  //   }
  // }
  //
  //

  @override
  void initState() {
    super.initState();


    initDeepLinkData();
    listenDynamicLinks();
    //_createRewardedAd();


    FlutterBranchSdk.setIdentity('branch_user_test');
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _updateFirestoreWithTicket(int newTicketCount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(user.uid);
      final ticketCollectionRef = userDocRef.collection('tickets');

      try {
        // Get the user's existing tickets and sort them by createDate in descending order
        final userTicketsSnapshot = await ticketCollectionRef
            .orderBy('createDate', descending: true)
            .get();

        final userTicketsData = userTicketsSnapshot.docs.isNotEmpty
            ? userTicketsSnapshot.docs.first.data() as Map<String, dynamic>
            : null;

        // Calculate the remaining points based on existing tickets and new earned tickets
        int remainingPoints = userTicketsData != null
            ? (userTicketsData['remain'] as int) + newTicketCount
            : newTicketCount;
// Create a timestamp-based document ID
        final newTicketDocId = DateTime
            .now()
            .millisecondsSinceEpoch
            .toString();

// Create a new document with the timestamp-based ID in the 'tickets' subcollection
        final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
        await newTicketDocRef.set({
          'earn': '1',
          'createDate': FieldValue.serverTimestamp(),
          'source': 'Rewarded Video Ticket',
          'remain': remainingPoints,
        });

        // // Create a new document with a unique ID in the 'tickets' subcollection
        // final newTicketDocRef = ticketCollectionRef.doc();
        // await newTicketDocRef.set({
        //   'earn': newTicketCount.toString(),
        //   'createDate': DateTime.now(),
        //   'source': 'Rewarded Video Ticket',
        //   'remain': remainingPoints,
        // });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You Earned $newTicketCount Ticket(s)")),
        );
      } catch (e) {
        debugPrint('Error updating Firestore: $e');
      }
    }
  }


  void _showRewardedAd() {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      return;
    }

    setState(() {
      _adLoading = true;
    });
    _startLoadingTimer(); // Start the timer before setting _adLoading to true
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
        _stopLoadingTimer();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();

        _createRewardedAd();
        _stopLoadingTimer();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint(
            '$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
        _updateFirestoreWithTicket(5);
      },
    );
    _rewardedAd = null;
  }

  void _startLoadingTimer() {
    _loadingTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        _adLoading = false;
      });
    });
  }

  void _stopLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
    setState(() {
      _adLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profiledata = ref.watch(profileStreamProvider);
    final ticketdata = ref.watch(ticketStreamProvider);
    final enrollData = ref.watch(enrollStreamProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'Profile',
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditProfileScreen(
                            users: FirebaseAuth.instance.currentUser,
                          )));
            },
            icon: const Icon(
              EvaIcons.edit2Outline,
            ),
          )
        ],
      ),
      body: profiledata.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Text(
                ' Please complete your profile to see your\n                             tickets',
                style: kMediumTextStyle.copyWith(fontWeight: FontWeight.w700),
              ),
            );
          } else {
            final profileModel = data.first;
            return ListView(
              children: <Widget>[
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.5, 0.9],
                      colors: [
                        Color(0XFF9fd8ef),
                        Color(0XFFdbf0f9),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CircleAvatar(
                            minRadius: 55,
                            backgroundColor: AppColors.primaryColor,
                            child: CircleAvatar(
                              backgroundImage:
                              NetworkImage(profileModel.profilepic),
                              minRadius: 50,
                            ),
                          ),
                        ],
                      ),
                      12.ph,
                      Text(
                        profileModel.fullname,
                        style: kLargeTextStyle,
                      ),
                      Text(
                        '${profileModel.city}, Turkiye',
                        style: kMediumTextStyle,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    CounterWithContainerIcon(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TicketHistory(),
                          ),
                        );
                      },
                      imagePath: 'assets/images/ticket1.png',
                      count: ticketdata.when(
                          data: (data) {
                            if (data.isEmpty) {
                              return Center(
                                child: Text(
                                  '0',
                                  style: kMediumTextStyle.copyWith(
                                      fontWeight: FontWeight.w700),
                                ),
                              );
                            }
                            final ticket = data.first;
                            return Text(ticket.remain.toString());
                          },
                          error: (error, stackTrace) =>
                              Center(child: Text(error.toString())),
                          loading: () => CircularProgressIndicator()),
                    ),
                    CounterWithContainerIcon(
                      onTap: () {
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (context) => const EnrollHistory(),
                        //   ),
                        // );
                      },
                      imagePath: 'assets/images/person1.png',
                      count: enrollData.when(
                          data: (data) {
                            if (data.isEmpty) {
                              return Center(
                                child: Text(
                                  '0',
                                  style: kMediumTextStyle.copyWith(
                                      fontWeight: FontWeight.w700),
                                ),
                              );
                            }
                            final enrollList =
                                data ?? []; // Handle the case when data is null
                            final enrollCount = enrollList.length;
                            return Text('$enrollCount');
                          },
                          error: (error, stackTrace) =>
                              Center(child: Text(error.toString())),
                          loading: () => const CircularProgressIndicator()),
                    ),
                    CounterWithContainerIcon(
                        onTap: () {
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => const WinnerHistory(),
                          //   ),
                          // );
                        },
                        imagePath: 'assets/images/trophy1.png',
                        count: Text('')),
                  ],
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    "Email",
                    style: kSmallTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(profileModel.email ?? 'N/A'),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    "Phone",
                    style: kSmallTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle:
                  Text(profileModel.phone ?? 'Please Enter Phone Number'),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    "Address",
                    style: kSmallTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle:
                  Text('${profileModel.address}, ${profileModel.city}'),
                ),
                const Divider(),
                10.ph,
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(
                                        appBar: AppBar(
                                          title: Text(
                                            'Account Management',
                                            style: kMediumTextStyle.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          centerTitle: true,
                                          backgroundColor:
                                          AppColors.primaryColor,
                                        ),
                                        actions: [
                                          SignedOutAction((context) {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const AuthGate()),
                                                  (route) => false,
                                            );
                                            Fluttertoast.showToast(
                                              msg:
                                              "You are Successfully Logged Out!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.black,
                                              textColor: Colors.white,
                                              fontSize: 16,
                                            );
                                          }),
                                          AuthStateChangeAction<
                                              CredentialLinked>(
                                                  (context, state) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Account successfully linked!"),
                                                  ),
                                                );
                                              }),
                                        ],
                                      )));
                        },
                        child: Text(
                          'Link Other Social Media Accounts',
                          style: kSmallTextStyle.copyWith(
                              fontWeight: FontWeight.w700),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: 157,
                          height: 35,
                          margin: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                textStyle:
                                MaterialStatePropertyAll(kMediumTextStyle),
                                backgroundColor: const MaterialStatePropertyAll(
                                    Color(0XFF87ceeb))),
                            onPressed: _adLoading ? null : _showRewardedAd,
                            child: _adLoading
                                ? const SizedBox(
                              width: 20, // Adjust this value as needed
                              height: 20, // Adjust this value as needed
                              child: CircularProgressIndicator(
                                strokeWidth:
                                2, // You can adjust the stroke width as needed
                              ),
                            )
                                : const Text(
                              'Watch & Earn',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 150,
                          height: 35,
                          margin: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                textStyle:
                                MaterialStatePropertyAll(kMediumTextStyle),
                                backgroundColor: const MaterialStatePropertyAll(
                                    Color(0XFF87ceeb))),
                            onPressed: () {
                              generateLink(context);
                            },

                            // ReferAndEarnScreen();
                            //},

                            child: const Text(
                              'Invite & Earn',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                )
              ],
            );
          }
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () =>
        const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }



}