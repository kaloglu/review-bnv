import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import '../constants/enum_for_date.dart';
import '../constants/text_styles.dart';
import '../providers/enroll_user_provider.dart';
import '../providers/home_screen_providers.dart';
import '../providers/product_data_fetch_provider.dart';
import '../providers/reward_Ad.dart';
import '../providers/scheduleEndDateCallBack.dart';
import '../providers/total_attendees_provider.dart';
import '../providers/user_name_provider.dart';
import '../utils/Text.dart';

import '../utils/count_with_icon.dart';

class ProductDetails extends ConsumerStatefulWidget {
  const ProductDetails({
    Key? key,
    this.title,
    this.description,
    this.requiredTickets,
    this.attendeeCount,
    this.statusColor,
    this.images,
    this.documentId,
    this.name,
    this.count,
    this.unit,
    this.unitPrice,
  }) : super(key: key);
  final String? title;
  final String? description;
  final String? requiredTickets;
  final int? attendeeCount;
  final Color? statusColor;
  final String? documentId;
  final String? name;
  final List<dynamic>? images;
  final int? count;
  final String? unit;
  final double? unitPrice;

  @override
  ProductDetailsState createState() => ProductDetailsState();
}

class ProductDetailsState extends ConsumerState<ProductDetails> {
  bool isButtonEnabled = false;
  Future<void> _checkEndDateStatus() async {
    try {
      // Replace 'raffles' with your Firestore collection name
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('raffles')
          .doc(widget.documentId)
          .get();

      if (snapshot.exists) {
        Timestamp? startDate = snapshot.get('startDate');
        Timestamp? endDate = snapshot.get('endDate');

        if (startDate != null && endDate != null) {
          DateTime now = DateTime.now();

          // Calculate time difference in hours
          int hoursDifference = endDate.toDate().difference(now).inHours;

          if (now.isBefore(startDate.toDate())) {
            // Disable the button if the current time is before the startDate
            setState(() {
              isButtonEnabled = false;
            });
          } else if (now.isAfter(startDate.toDate()) &&
              now.isBefore(endDate.toDate())) {
            // Enable the button if the current time is after the startDate and before the endDate
            setState(() {
              isButtonEnabled = true;
            });
          } else {
            // Disable the button if the current time is after the endDate
            setState(() {
              isButtonEnabled = false;
            });
          }
        }
      }
    } catch (error) {
      debugPrint('Error checking endDate status: $error');
    }
  }

  final bool _adLoading = false;
  Timer? _loadingTimer;
  int newTicketCount = 0;
  bool luckyDrawExecuted = false;
  late StreamSubscription streamSubscription;
  String status = 'Initial Status';
  //late final StreamController<bool> _buttonEnabledController;

  // DateTime? resultDate;
  late final String remainingTime;
  bool isEnrollmentInProgress = false;

  @override
  void initState() {
    super.initState();
    _checkEndDateStatus();
    buttonEnabledController = StreamController<bool>.broadcast();
    updateTimerStatus();
    createRewardedAd();
    fetchStartAndEndDates(widget.documentId!); // Fetch start and end dates
  }

  @override
  void dispose() {
    buttonEnabledController.close(); // Close the stream controller
    _loadingTimer?.cancel(); // Cancel the timer when disposing
    rewardedAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('NOOOOOOOOOOOOOOOO99999');
    final enrollmentState = ref.watch(enrollmentProvider);
    final enrollUser = ref
        .read(enrollmentProvider.notifier)
        .enrollUser; // Access the notifier of that specific provider instance
    final productInfoImages = ref.watch(productInfoImagesStreamProvider);

    final productStream = ref.watch(productsStreamProvider);
    final product = productStream.when(
      data: (data) =>
          data.firstWhere((product) => product.id == widget.documentId),
      loading: () => null,
      error: (error, stackTrace) => null,
    );
    //debugInvertOversizedImages = true;
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Consumer(
                builder: (context, watch, child) {
                  final usernamesAsyncValue =
                      ref.watch(usernamesProvider(widget.documentId!));

                  if (!isEndDateReached()) {
                    // If the endDate has not been reached, display buttons
                    return StreamBuilder<bool>(
                      stream: buttonEnabledController.stream,
                      initialData: false,
                      builder: (context, snapshot) {
                        final isEnabled = !isEndDateReached();
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
                                      const TextStyle(fontSize: 16)),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.grey;
                                      }
                                      return const Color(0XFF87ceeb);
                                    },
                                  ),
                                ),
                                onPressed: isButtonEnabled &&
                                        !enrollmentState.isEnrollmentInProgress
                                    ? () async {
                                        await enrollUser(widget
                                            .documentId); // Call enrollUser directly
                                      }
                                    : null,
                                child: enrollmentState.isEnrollmentInProgress
                                    ? const SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        AppStrings.enroll,
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
                                  textStyle: MaterialStateProperty.all(
                                      const TextStyle(fontSize: 16.5)),
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color(0XFF87ceeb)),
                                ),
                                onPressed: () {
                                  _adLoading ? null : showRewardedAd();
                                },
                                child: _adLoading
                                    ? const SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        AppStrings.earn,
                                        style: TextStyle(color: Colors.black),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // If the endDate has been reached, check for winners
                    if (usernamesAsyncValue.value?.isEmpty ?? true) {
                      return Text(
                        "No Winners in this raffle",
                        style: kLargeTextStyle,
                        textAlign: TextAlign.center,
                      );
                    } else {
                      String winnersText =
                          usernamesAsyncValue.value?.join(', ') ?? '';
                      return Column(
                        children: [
                          Text(AppStrings.congratulationsWinners,
                              style: kLargeTextStyle),
                          Text(
                            winnersText,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }
                  }
                },
              )


            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: MediaQuery.sizeOf(context).width,
              child: productInfoImages.when(
                data: (imagesData) {
                  final images = imagesData.firstWhere(
                    (data) => data['id'] == widget.documentId,
                  )['images'];

                  return Swiper(
                    autoplay: true,
                    itemBuilder: (BuildContext context, int index) {
                      final imagePath = images[index]['path'] as String;

                      return CachedNetworkImage(
                        imageUrl: imagePath,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.fill,
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
                          Row(
                            children: [
                              Text(
                                widget.title!,
                                style: kLargeTextStyle,
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Consumer(builder: (context, ref, child) {
                        final currentState = getProductState(product!);
                        Color statusColor;

                        if (currentState == ProductState.startDate) {
                          final formattedDate = ref.watch(remainingTimeProvider(
                              product.startDate.toDate()));
                          return Text(
                            formattedDate.when(
                              data: (value) => value,
                              loading: () => AppStrings.loading,
                              error: (error, stackTrace) => 'Error',
                            ),
                            style: TextStyle(
                              color: statusColor = Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (currentState == ProductState.endDate) {
                          final formattedDate = ref.watch(
                              remainingTimeProvider(product.endDate.toDate()));
                          return Text(
                            formattedDate.when(
                              data: (value) => value,
                              loading: () => AppStrings.loading,
                              error: (error, stackTrace) => 'Error',
                            ),
                            style: TextStyle(
                              color: statusColor = Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (currentState == ProductState.resultDate) {
                          return Text(
                            'In Progress',
                            style: TextStyle(
                              color: statusColor = Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (currentState == ProductState.done) {
                          return Text(
                            AppStrings.done,
                            style: TextStyle(
                              color: statusColor = Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return Text(
                            '',
                            style: TextStyle(
                              color: widget.statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                  Row(
                    children: [
                      CountWithIcon(
                        iconPath: 'assets/images/ticket1.png',
                        count: Text(
                          widget.requiredTickets.toString(),
                          style: kMediumTextStyle,
                        ),
                      ),
                      const SizedBox(width: 30),
                      CountWithIcon(
                        iconPath: 'assets/images/person1.png',
                        count: Consumer(
                          builder: (context, watch, child) {
                            final attendeesAsyncValue = ref.watch(
                                totalAttendeesStreamProvider(
                                    widget.documentId!));

                            return attendeesAsyncValue.when(
                              data: (attendeesSnapshot) {
                                if (attendeesSnapshot.docs.isEmpty) {
                                  return Text(
                                    '0',
                                    style: kMediumTextStyle.copyWith(
                                        fontWeight: FontWeight.w700),
                                  );
                                }
                                // Use a set to keep track of unique user IDs
                                final uniqueUserIds = <String>{};

                                // Iterate through the documents and add unique user IDs to the set
                                for (final doc in attendeesSnapshot.docs) {
                                  final userId = doc[
                                      'userId']; // Adjust field name based on your data structure
                                  uniqueUserIds.add(userId);
                                }

                                // Get the count of unique user IDs
                                final count = uniqueUserIds.length;
                                //   final count = attendeesSnapshot.docs.length;

                                return Text(
                                  '$count',
                                  style: kMediumTextStyle.copyWith(
                                      fontWeight: FontWeight.normal),
                                );
                              },
                              loading: () {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              error: (error, stackTrace) {
                                return Text(
                                  'Error: $error',
                                  style: kMediumTextStyle.copyWith(
                                      fontWeight: FontWeight.w700),
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: '${widget.name}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: '    ${widget.unit}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                              text: AppStrings.marketPrice,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: '    ${widget.unitPrice.toString()}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.description,
                    style: kLargeTextStyle,
                  ),
                  Html(
                    data: widget.description,
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

}
