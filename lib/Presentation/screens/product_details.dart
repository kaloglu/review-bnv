import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/services/firebase_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
          if (kDebugMode) {
            print('$ad loaded.');
          }
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('RewardedAd failed to load: $error');
          }
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

  void scheduleEndDateCallback(DateTime endDate, String documentId) {
    final currentTime = DateTime.now();
    final timeDifference = endDate.difference(currentTime);

    if (timeDifference.isNegative) {
      // End date has already passed
      return;
    }

    Future.delayed(timeDifference, () {
      // Call the performLuckyDraw function when the end date is reached
      LuckyDraw().performLuckyDraw(documentId);
    });
  }

  void _fetchStartAndEndDates() async {
    final productDocRef =
        FirebaseFirestore.instance.collection('raffles').doc(documentId);
    final productSnapshot = await productDocRef.get();
    final productData = productSnapshot.data();
    startDate = productData?['startDate']?.toDate() as DateTime?;
    endDate = productData?['endDate']?.toDate() as DateTime?;
    if (endDate != null) {
      // Schedule the callback for this product's endDate
      scheduleEndDateCallback(endDate!, documentId);
    }
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
        // int remainingPoint = userTicketsData != null
        //     ? (userTicketsData['earn'] as int) + newTicketCount
        //     : newTicketCount;
// Create a timestamp-based document ID
        final newTicketDocId = DateTime.now().millisecondsSinceEpoch.toString();
        // Get the current date (without the time component)
        final currentDate = DateTime.now();
        // final currentDateWithoutTime = DateTime(currentDate.year, currentDate.month, currentDate.day);
// Create a new document with the timestamp-based ID in the 'tickets' subcollection
        final newTicketDocRef = ticketCollectionRef.doc(newTicketDocId);
        await newTicketDocRef.set({
          'earn': '10',
          'createDate': FieldValue.serverTimestamp(),
          'source': 'Ad Reward Ticket',
          'remain': remainingPoints,
          'expiryDate': DateTime(
              currentDate.year, currentDate.month, currentDate.day + 1),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You Earned $newTicketCount Tickets")),
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
        width: MediaQuery.of(context).size.width,
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
                                    fontSize: 16)), // Use your kMediumTextStyle
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
                          onPressed: isEnabled ? _enrollUser : null,
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
                          onPressed: () {
                            _adLoading ? null : _showRewardedAd();
                          },
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
              width: MediaQuery.of(context).size.width,
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
                        width: MediaQuery.of(context).size.width,
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
                error: (error, stackTrace) => Center(
                  child: Text(error.toString()),
                ),
                loading: () => const Center(
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

        // Filter valid tickets based on expiryDate
        final validExpiryTicketsQuery = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tickets')
            .where('expiryDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()));

        final validExpiryTicketsSnapshot = await validExpiryTicketsQuery.get();

        // Filter valid tickets based on remain
        final validRemainTicketsQuery = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tickets')
            .where('remain', isGreaterThanOrEqualTo: 1);

        final validRemainTicketsSnapshot = await validRemainTicketsQuery.get();

        // Combine the results of both queries
        final validExpiryTickets = validExpiryTicketsSnapshot.docs.toList();
        final validRemainTickets = validRemainTicketsSnapshot.docs.toList();

        // Find the intersection of validExpiryTickets and validRemainTickets
        final validTickets = validExpiryTickets.where((expiryTicket) {
          final expiryTicketId = expiryTicket.id;
          return validRemainTickets
              .any((remainTicket) => remainTicket.id == expiryTicketId);
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
          String? deviceToken = await FirebaseMessaging.instance.getToken();

          // Create a new document in the "attendee" collection
          final attendeeData = {
            'userId': user.uid,
            'createDate': FieldValue.serverTimestamp(),
            'productId': documentId,
            'number': attendeeCount,
            'deviceToken': deviceToken,
          };

          final attendeeRef = await attendeeCollectionRef.add(attendeeData);

          // Get the document ID of the ticket and use it as ticketid
          final ticketId = validTickets.first.id;

          final productTitle = productData?['title'] ?? '';
          final productDescription = productData?['description'] ?? '';
          final productImage = productData?['image'] ?? '';

          // Query for an existing enrollment document for the user in this product
          final existingEnrollmentQuerySnapshot = await firestore
              .collection('users')
              .doc(user.uid)
              .collection('enroll')
              .where('raffleid', isEqualTo: documentId)
              .get();

          if (existingEnrollmentQuerySnapshot.docs.isNotEmpty) {
            // User already enrolled in this product, update the existing document
            final existingEnrollmentDoc =
                existingEnrollmentQuerySnapshot.docs.first;
            final existingEnrollmentData =
                existingEnrollmentDoc.data();

            // Increment the enrollment count
            final int currentEnrollmentCount =
                existingEnrollmentData['enrollmentCount'] ?? 0;
            final int newEnrollmentCount = currentEnrollmentCount + 1;

            // Update the existing document with the new enrollment count
            await existingEnrollmentDoc.reference.update({
              'enrollmentCount': newEnrollmentCount,
            });
          } else {
            // User is enrolling for the first time in this product
            final enrollData = {
              'ticketid': ticketId,
              'raffleid': documentId,
              'enrollDate': FieldValue.serverTimestamp(),
              'title': productTitle,
              'description': productDescription,
              'image': productImage,
              'enrollmentCount': 0, // Initial enrollment count is 1
            };

            // Create a new document in the "enroll" collection
            await firestore
                .collection('users')
                .doc(user.uid)
                .collection('enroll')
                .add(enrollData);
          }

          // Create a timestamp-based document ID
          final newTicketDocId =
              DateTime.now().millisecondsSinceEpoch.toString();

          // Get the current date (without the time component)
          final currentDate = DateTime.now();

          // Create a new document in the user's "tickets" collection with the enrollment data
          final newUserTicketDocRef =
              userTicketsCollectionRef.doc(newTicketDocId);

          await newUserTicketDocRef.set({
            'createDate': FieldValue.serverTimestamp(),
            'earn': '0',
            'source': 'You enrolled',
            'remain': newRemainingTickets,
            'expiryDate': DateTime(
                currentDate.year, currentDate.month, currentDate.day + 1),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enrolled successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Not enough tickets to enroll")),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    }
  }
}

class LuckyDraw {
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

      // Check if there are attendees.
      if (attendeesDocs.isNotEmpty) {
        // Check which document is at position 3 after shuffling.
        if (attendeesDocs.length >= 3) {
          final luckyWinner = attendeesDocs[2];
          final luckyWinnerData = luckyWinner.data();

          // Ensure luckyWinnerData is not null before sending notifications.
          if (luckyWinnerData != null) {
            // Check the type of luckyWinnerData before accessing the userId and productId properties.
            if (luckyWinnerData is Map<String, dynamic>) {
              final deviceToken = luckyWinnerData['deviceToken'];
              final productId = luckyWinnerData['productId'];
              if (kDebugMode) {
                print('Lucky winner details: $luckyWinnerData');
              }

              // Create a subcollection "winners" and add a document for the winner.
              final winnersCollection = raffleDocument.collection('winners');

              // Check if userId is not null before sending notifications.
              if (deviceToken != null) {
                await winnersCollection.add({
                  'deviceToken': deviceToken,
                  'productId': raffleId,
                });

                // Send a push notification to the lucky winner using Firebase Cloud Messaging (FCM).
                try {
                  await FirebaseMessaging.instance.sendMessage(
                    to: deviceToken,
                    messageId: 'You won this product',
                  );
                } catch (error) {
                  if (kDebugMode) {
                    print('Notification Error: $error');
                  }
                }
              } else {
                if (kDebugMode) {
                  print('Lucky winner userId is null.');
                }
              }
            } else {
              if (kDebugMode) {
                print('Lucky winner data is not in the expected format.');
              }
            }
          } else {
            if (kDebugMode) {
              print('Lucky winner data is null.');
            }
          }
        } else {
          if (kDebugMode) {
            print('Not enough attendees to determine a lucky winner.');
          }
        }
      } else {
        if (kDebugMode) {
          print('No attendees found.');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in creating documents: $error ');
      }
    }
  }
}
