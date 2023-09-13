import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/services/firebase_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/product_data_fetch_provider.dart';
import '../../providers/ticket_provider.dart';
import '../utils/count_with_icon.dart';
import '../utils/reusable_small_btn.dart';
import 'home_screen.dart';
class ProductDetails extends ConsumerStatefulWidget {
  ProductDetails({
    Key? key,
    required this.title,
    required this.description,
    required this.requiredTickets,
    required this.attendeeCount,
    required this.statusColor,
    required this.images,
    required this.documentId,
    required this.status,
    required this.name,
    required this.count,
    required this.unit,
    required this.unitPrice,
  }) : super(key: key);

  final String title;
  final String description;
  final String requiredTickets;
  final int attendeeCount;
  final Color statusColor;
  final String documentId;
  final String name;
  final List<dynamic> images;
  final String status;
  final String count;
  final String unit;
  final double unitPrice;

  @override
  ConsumerState<ProductDetails> createState() => ProductDetailsState(
    title: title,
    description: description,
    requiredTickets: requiredTickets,
    attendeeCount: attendeeCount.toString(),
    statusColor: statusColor,
    images: images,
    documentId: documentId,
    status: status,
    name: name,
    count: count,
    unit: unit,
    unitPrice: unitPrice,
  );
}

class ProductDetailsState extends ConsumerState<ProductDetails> {
  bool _adLoading = false;
  Timer? _loadingTimer;
  bool _timerActive = false;
  int newTicketCount = 0;

  ProductDetailsState({
    required this.title,
    required this.description,
    required this.requiredTickets,
    required this.attendeeCount,
    required this.statusColor,
    required this.images,
    required this.documentId,
    required this.status,
    required this.name,
    required this.count,
    required this.unit,
    required this.unitPrice,
  });

  final String title;
  final String description;
  final String requiredTickets;
  final String attendeeCount;
  final Color statusColor;
  final String documentId;
  final List<dynamic> images;
  final String status;
  final String name;
  final String count;
  final String unit;
  final double unitPrice;




  late final StreamController<bool> _buttonEnabledController;
  DateTime? startDate;
  DateTime? endDate;

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
//  StreamSubscription<String> statusSubscription;

  @override
  void initState() {
    super.initState();

    _buttonEnabledController = StreamController<bool>.broadcast();
    _updateTimerStatus();
    _createRewardedAd();
    _fetchStartAndEndDates(); // Fetch start and end dates
  }

  @override
  void dispose() {
    _buttonEnabledController.close(); // Close the stream controller

    _loadingTimer?.cancel(); // Cancel the timer when disposing
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _fetchStartAndEndDates() async {
    final productDocRef =
    FirebaseFirestore.instance.collection('raffles').doc(documentId);
    final productSnapshot = await productDocRef.get();
    final productData = productSnapshot.data() as Map<String, dynamic>?;
    startDate = productData?['startDate']?.toDate() as DateTime?;
    endDate = productData?['endDate']?.toDate() as DateTime?;
    _updateTimerStatus();
  }

  void _updateTimerStatus() {
    if (startDate != null && endDate != null) {
      final now = DateTime.now();
      if (now.isBefore(startDate!)) {
        _startTimer();
      } else if (now.isAfter(endDate!)) {
        _stopTimer();
      }
    }
    _buttonEnabledController
        .add(!_timerActive && !_adLoading && !isEndDateReached());
  }

  void _startTimer() {
    if (!_timerActive) {
      _timerActive = true;
      _loadingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        if (now.isAfter(startDate!)) {
          _stopTimer();
          _updateTimerStatus();
        }
      });
    }
  }

  void _stopTimer() {
    _timerActive = false;
    _loadingTimer?.cancel();
    _loadingTimer = null;
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
            ? userTicketsSnapshot.docs.first.data()
            : null;

        // Calculate the remaining points based on existing tickets and new earned tickets
        int remainingPoints = userTicketsData != null
            ? (userTicketsData['remain'] as int) + newTicketCount
            : newTicketCount;
        int remainingPoint = userTicketsData != null
            ? (userTicketsData['earn'] as int) + newTicketCount
            : newTicketCount;
// Create a timestamp-based document ID
        final newTicketDocId = DateTime
            .now()
            .millisecondsSinceEpoch
            .toString();

// Create a new document with the timestamp-based ID in the 'tickets' subcollection
        final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
        await newTicketDocRef.set({
          'earn': remainingPoint,
          'createDate': FieldValue.serverTimestamp(),
          'source': 'Ad Reward Ticket',
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
          print('ad onAdShowedFullScreenContent.'),
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
        _updateFirestoreWithTicket(10);
      },
    );
    _rewardedAd = null;
  }

  void _startLoadingTimer() {
    _loadingTimer = Timer(const Duration(seconds: 5), () {
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

  bool isEndDateReached() {
    final now = DateTime.now();
    return endDate != null && now.isAfter(endDate!);
  }


  @override
  Widget build(BuildContext context) {
    final productInfoImages = ref.watch(productInfoImagesStreamProvider);
    final ticketdata = ref.watch(ticketStreamProvider);
    bool isLoading = false; // Track whether the action is ongoing

    // final buttonEnabled = !_timerActive && !_adLoading; // Update button status

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10),
        height: 120,
        width: MediaQuery
            .of(context)
            .size
            .width,
        color: const Color(0XFFFFFFFF),
        child: Column(
          children: [
            StreamBuilder<bool>(
                stream: _buttonEnabledController.stream,
                initialData: false,
                builder: (context, snapshot) {
                  final buttonEnabled = snapshot.data ?? false;
                  final isEnabled = buttonEnabled && !isEndDateReached();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 150,
                        height: 40,
                        margin: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(
                                    fontSize:
                                    16)), // Use your kMediumTextStyle
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors
                                      .grey; // Set the background color when button is disabled
                                }
                                return const Color(
                                    0XFF87ceeb); // Set the background color when button is enabled
                              },
                            ),
                          ),
                          onPressed:  isEnabled ? _enrollUser : null,

                          child: const Text(
                            'Enroll',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 150,
                        height: 40,
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
                          onPressed:(){
                            _adLoading ? null : _showRewardedAd();
                          } ,
                          child: _adLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                            'Earn',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  );
                }),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: productInfoImages.when(
                data: (imagesData) {
                  final images = imagesData.firstWhere(
                        (data) => data['id'] == documentId,
                  )['images'];
                  return Swiper(
                    autoplay: true,
                    itemBuilder: (BuildContext context, int index) {
                      final imagePath = images[index]['path'] as String;

                      return Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(imagePath),
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    },
                    itemCount: images.length,
                    pagination: const SwiperPagination(
                      builder: DotSwiperPaginationBuilder(
                        activeColor: Colors.blue,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                error: (error, stackTrace) =>
                    Center(
                      child: Text(error.toString()),
                    ),
                loading: () =>
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: kLargeTextStyle,
                          ),
                        ],
                      ),
                      Text(
                       widget.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      CountWithIcon(
                        iconPath: 'assets/images/ticket1.png',
                        count: Text(requiredTickets.toString()),
                      ),
                      const SizedBox(width: 30),
                      CountWithIcon(
                        iconPath: 'assets/images/person1.png',
                        count: Text(widget.attendeeCount.toString()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(name),
                      Text(count),
                      Text(unit),
                      Text(unitPrice.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: kMediumTextStyle,
                  ),
                  Html(
                    data: description,
                    style: {
                      'body': Style(
                        fontSize: FontSize(14.0),
                        lineHeight: const LineHeight(1.4),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _enrollUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestore = FirebaseFirestore.instance;
      final productDocRef = firestore.collection('raffles').doc(documentId);
      final attendeeCollectionRef = productDocRef.collection('attendees');
      final userTicketsCollectionRef =
      firestore.collection('users').doc(user.uid).collection('tickets');

      try {
        final userEnrollmentQuerySnapshot = await attendeeCollectionRef
            .where('userId', isEqualTo: user.uid)
            .get();
        final userEnrollmentCount = userEnrollmentQuerySnapshot.docs.length;

        final productSnapshot = await productDocRef.get();
        final productData = productSnapshot.data();
        final requiredTickets = productData?['requiredTickets'] as int;
        final maxAttendedByUser =
        productData?['rules']?['maxAttendByUser'] as int;
        final maxAttendee = productData?['rules']?['maxAttendee'] as int;

        final userTicketsSnapshot = await userTicketsCollectionRef
            .orderBy('createDate', descending: true)
            .get();
        final userTicketsData = userTicketsSnapshot.docs.isNotEmpty
            ? userTicketsSnapshot.docs.first.data()
            : null;

        if (userTicketsData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You have Zero tickets")),
          );
          return;
        }

        if (userEnrollmentCount >= maxAttendedByUser ||
            userEnrollmentCount >= maxAttendee) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Exceeded enrollment limit")),
          );
          return;
        }

        // Filter valid tickets
        final validTickets = userTicketsSnapshot.docs.where((ticketDoc) {
          final ticketData = ticketDoc.data();
          final expirationDate = ticketData['expirationDate'] as Timestamp?;
          final remain = ticketData['remain'] as int;
          return (expirationDate == null || expirationDate.toDate().isAfter(DateTime.now())) &&
              remain >= requiredTickets;
        }).toList();

        // Calculate the total number of valid tickets
        final totalValidTickets = validTickets.fold<int>(0, (sum, ticketDoc) {
          final remain = ticketDoc['remain'] as int;
          return sum + remain;
        });

        // Check if there are enough valid tickets to meet the required amount
        if (totalValidTickets >= requiredTickets) {
          // Proceed with enrollment
          final remainTickets = userTicketsData['remain'] as int;

          // Deduct requiredTickets from user's remaining tickets
          final newRemainingTickets = remainTickets - requiredTickets;

          // Check if remaining tickets after deduction are non-negative
          if (newRemainingTickets < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Not enough remaining tickets")),
            );
            return;
          }

          // Query for the current attendee count to assign sequential numbers
          final attendeeCountSnapshot = await attendeeCollectionRef.get();
          final attendeeCount = attendeeCountSnapshot.docs.length;
          final attendeeData = {
            'userId': user.uid,
            'createDate': FieldValue.serverTimestamp(),
            'productId': documentId,
            'number': attendeeCount,
          };

          // Create a new document in the "attendee" collection
          await attendeeCollectionRef.add(attendeeData);

          // Get the document ID of the ticket and use it as ticketid
          final ticketId = validTickets.first.id;

          // Create a new subcollection "enroll" in the user's document
          final userEnrollCollectionRef =
          firestore.collection('users').doc(user.uid).collection('enroll');
          final enrollData = {
            'ticketid': ticketId,
            'raffleid': documentId,
            'enrollDate': FieldValue.serverTimestamp(),
          };

          // Use the document ID as the timestamp for the new enrollment document
          final newEnrollDocRef = userEnrollCollectionRef.doc(ticketId);
          await newEnrollDocRef.set(enrollData);
          final productTitle =
              productData?['title'] ?? ''; // Fetch the title of the product
          int remainingPoint = validTickets
              .map((ticket) => ticket['earn'] as int)
              .reduce((a, b) => a + b);

          // Create a timestamp-based document ID
          final newTicketDocId =
          DateTime.now().millisecondsSinceEpoch.toString();

          // Create a new document in the user's "tickets" collection with the enrollment data
          final newUserTicketDocRef =
          userTicketsCollectionRef.doc(newTicketDocId);
          await newUserTicketDocRef.set({
            'earn': remainingPoint,
            'createDate': FieldValue.serverTimestamp(),
            'source': 'You enroll for  $productTitle',
            'remain': newRemainingTickets,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enrolled successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Not enough valid tickets to enroll")),
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

























// void _enrollUser() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final firestore = FirebaseFirestore.instance;
  //     final productDocRef = firestore.collection('raffles').doc(documentId);
  //     final attendeeCollectionRef = productDocRef.collection('attendees');
  //     final userTicketsCollectionRef =
  //     firestore.collection('users').doc(user.uid).collection('tickets');
  //
  //     try {
  //       final userEnrollmentQuerySnapshot = await attendeeCollectionRef
  //           .where('userId', isEqualTo: user.uid)
  //           .get();
  //       final userEnrollmentCount = userEnrollmentQuerySnapshot.docs.length;
  //
  //       final productSnapshot = await productDocRef.get();
  //       final productData = productSnapshot.data();
  //       final requiredTickets = productData?['requiredTickets'] as int;
  //       final maxAttendedByUser =
  //       productData?['rules']?['maxAttendByUser'] as int;
  //       final maxAttendee = productData?['rules']?['maxAttendee'] as int;
  //
  //       final userTicketsSnapshot = await userTicketsCollectionRef
  //           .orderBy('createDate', descending: true)
  //           .get();
  //       final userTicketsData = userTicketsSnapshot.docs.isNotEmpty
  //           ? userTicketsSnapshot.docs.first.data()
  //           : null;
  //
  //       if (userTicketsData == null || userTicketsData['remain'] < requiredTickets) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Not enough tickets")),
  //         );
  //         return;
  //       }
  //
  //       if (userEnrollmentCount >= maxAttendedByUser || userEnrollmentCount >= maxAttendee) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Exceeded enrollment limit")),
  //         );
  //         return;
  //       }
  //
  //       // Check for a valid daily bonus ticket
  //       final userTicketsQuerySnapshot = await userTicketsCollectionRef
  //           .where('source', isEqualTo: 'Daily Bonus')
  //           .where('expirationDate', isGreaterThanOrEqualTo: Timestamp.now())
  //           .get();
  //
  //
  //       if (userTicketsQuerySnapshot.docs.isEmpty) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("No valid daily bonus ticket")),
  //         );
  //         return;
  //       }
  //
  //       // Proceed with enrollment
  //       final remainTickets = userTicketsData['remain'] as int;
  //
  //       // Query for the current attendee count to assign sequential numbers
  //       final attendeeCountSnapshot = await attendeeCollectionRef.get();
  //       final attendeeCount = attendeeCountSnapshot.docs.length;
  //       final attendeeData = {
  //         'userId': user.uid,
  //         'createDate': FieldValue.serverTimestamp(),
  //         'productId': documentId,
  //         'number': attendeeCount,
  //       };
  //
  //       // Create a new document in the "attendee" collection
  //       final newAttendeeDocRef = await attendeeCollectionRef.add(attendeeData);
  //
  //       // Deduct requiredTickets from user's remaining tickets
  //       // await userTicketsCollectionRef
  //       //     .doc(userTicketsSnapshot.docs.first.id)
  //       //     .update({'remain': remainTickets - requiredTickets});
  //
  //       // Get the document ID of the ticket and use it as ticketid
  //       final ticketDocRef = await firestore
  //           .collection('users')
  //           .doc(user.uid)
  //           .collection('tickets')
  //           .doc(userTicketsSnapshot.docs.first.id);
  //       final ticketDoc = await ticketDocRef.get();
  //       final ticketId = ticketDoc.id;
  //
  //       // Create a new subcollection "enroll" in the user's document
  //       final userEnrollCollectionRef =
  //       firestore.collection('users').doc(user.uid).collection('enroll');
  //       final enrollData = {
  //         'ticketid': ticketId,
  //         'raffleid': documentId,
  //         'enrollDate': FieldValue.serverTimestamp(),
  //       };
  //
  //       // Use the document ID as the timestamp for the new enrollment document
  //       final newEnrollDocRef = userEnrollCollectionRef.doc(ticketId);
  //       await newEnrollDocRef.set(enrollData);
  //       final productTitle =
  //           productData?['title'] ?? ''; // Fetch the title of the product
  //       int remainingPoint = userTicketsData != null
  //           ? (userTicketsData['earn'] as int) + newTicketCount
  //           : newTicketCount;
  //
  //       // Create a timestamp-based document ID
  //       final newTicketDocId =
  //       DateTime.now().millisecondsSinceEpoch.toString();
  //
  //       // Create a new document in the user's "tickets" collection with the enrollment data
  //       final newUserTicketDocRef =
  //       userTicketsCollectionRef.doc(newTicketDocId);
  //       await newUserTicketDocRef.set({
  //         'earn': remainingPoint,
  //         'createDate': FieldValue.serverTimestamp(),
  //         'source': 'You enroll for  $productTitle',
  //         'remain': remainTickets - requiredTickets,
  //       });
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Enrolled successfully")),
  //       );
  //     } catch (e) {
  //       print('Error: $e');
  //     }
  //   }
  // }

























}





















class RaffleService {
// Initialize FirebaseMessaging

  Future<void> performLuckyDraw(String raffleId) async {
    try {
      // Reference to the raffle document and its attendees subcollection.
      final raffleDocument =
      FirebaseFirestore.instance.collection('raffles').doc(raffleId);
      final attendeesCollection = raffleDocument.collection('attendees');

      // Get all the documents in the attendees collection.
      final QuerySnapshot attendeesSnapshot = await attendeesCollection.get();

      // Get the attendees' documents and shuffle them.
      final List<QueryDocumentSnapshot> attendeesDocs = attendeesSnapshot.docs;
      attendeesDocs.shuffle();

      // Check which document is at position 3 after shuffling.
      if (attendeesDocs.length >= 3) {
        final luckyWinner = attendeesDocs[2];
        final luckyWinnerData = luckyWinner.data() as Map<String, dynamic>;
        print('Lucky winner details: $luckyWinnerData');

        // Create a subcollection "winners" and add a document for the winner.
        final winnersCollection = raffleDocument.collection('winners');

        // Check if luckyWinnerData is not null before accessing fields.
        if (luckyWinnerData != null) {
          final userId = luckyWinnerData['userId'];
          final productId = luckyWinnerData['productId'];
          await winnersCollection.add({
            'userId': userId,
            'productId': raffleId,
          });
          // Send a push notification to the lucky winner using Firebase Cloud Messaging (FCM).
          try {
            await FirebaseMessaging.instance.sendMessage(
             to: userId,
              messageId: 'You won this product',
            );
          } catch (error) {
            print('Notification Error: $error');
          }
        } else {
          print('Not enough attendees to determine a lucky winner.');
        }
      }
    }catch(error){
      print('Erro in creating documents: $error ');
    }

    // Function to send a push notification using FCM

  }


}
