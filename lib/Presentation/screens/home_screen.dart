import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/presentation/screens/profile_screen.dart';
import 'package:cihan_app/presentation/utils/shimmer_effect.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../Domain/models/product_model.dart';
import '../../lang.dart';
import '../constants/enum_for_date.dart';
import '../constants/text_styles.dart';
import '../providers/attendees_provider.dart';
import '../providers/home_screen_providers.dart';
import '../providers/product_data_fetch_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/search_provider.dart';
import '../providers/tags.dart';

import '../utils/count_with_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' as hooks;

class HomeScreen extends ConsumerStatefulWidget {
  //final StreamController<String> statusController = StreamController<String>();

  static const id = 'HomeScreen';

  const HomeScreen({super.key});

  // HomeScreen({super.key });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  List<String> selectedTags = [];
  late bool isConnected = true;

  Future<void> checkAndGrantDailyTicket(int newTicketCount) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(user.uid);
      final ticketsCollectionRef = userDocRef.collection('tickets');

      // Get the current date (without the time component)
      final currentDate = DateTime.now();
      final currentDateWithoutTime =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      // Check if the user has already received a ticket for the current day
      final existingTicketQuery = await ticketsCollectionRef
          .where('createDate', isGreaterThanOrEqualTo: currentDateWithoutTime)
          .get();
      // Get the user's existing tickets and sort them by createDate in descending order
      final userTicketsSnapshot = await ticketsCollectionRef
          .orderBy('createDate', descending: true)
          .get();

      final userTicketsData = userTicketsSnapshot.docs.isNotEmpty
          ? userTicketsSnapshot.docs.first.data()
          : null;

      //Calculate the remaining points based on existing tickets and new earned tickets
      int remainingPoints = userTicketsData != null
          ? (userTicketsData['remain'] as int)
          : newTicketCount;

      if (existingTicketQuery.docs.isEmpty) {
        // User hasn't received a ticket for the current day, so create a new ticket
        final newTicketData = {
          'source': 'Daily Bonus', // Replace with your source information
          'earn': '11', // Replace with the appropriate value for earnings
          'remain': remainingPoints, // Initial remain value (adjust as needed)
          'createDate': FieldValue.serverTimestamp(),
          'expiryDate': DateTime(currentDate.year, currentDate.month,
              currentDate.day + 1), // Expiration at 00:00 of the next day
        };

        await ticketsCollectionRef.add(newTicketData);
        Fluttertoast.showToast(
            msg: "You Earned Daily Bonus 1 ticket",
            gravity: ToastGravity.CENTER);
      }

      // Check for and handle ticket expiration
      final expiredTicketQuery = await ticketsCollectionRef
          .where('expirationDate', isLessThan: currentDateWithoutTime)
          .get();

      for (final ticketDoc in expiredTicketQuery.docs) {
        // Mark the expired ticket as "ticket expired"
        await ticketDoc.reference.update({});
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAndGrantDailyTicket(11);
    //Listen to connectivity changes

    //fetchAvailableTags();
  }

  List<String> availableTags = [];
  late List<ProductModel> allProducts;

  @override
  Widget build(BuildContext context) {
    debugPrint('HIIIIIIIIIIIIIIIIIIIIIIIII');
    final productData = ref.watch(productsStreamProvider);
    final attendeesData = ref.watch(attendeesStreamProvider);

    final profiledata = ref.watch(profileStreamProvider);
    final raffles = ref.watch(rafflesCollectionProvider);

    if (raffles.value == null) {
      return Container(
        color: Colors.white,
        child: const ShimmerLoader(),
      );
    }

    List<String> tags = [];
    for (ProductModel product in raffles.value!) {
      tags.addAll(product.tags);
    }

// Use a Set to ensure only unique tags are included
    tags = tags.toSet().toList();

    //final tags = raffles.value!.first.tags!;
    //debugInvertOversizedImages = true;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: TextFormField(
          onChanged: (value) {
            ref.read(searchTextProvider.notifier).setSearchText(value);
          },
          obscureText: false,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            suffixIconConstraints: const BoxConstraints(
              maxHeight: 40,
              maxWidth: 40,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 30),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            hintText: AppStrings.search,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UserProfileScreen(),
                    ),
                  );
                },
                child: profiledata.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return Center(
                        child: Text(
                          AppStrings.noDataFound,
                          style: kMediumTextStyle.copyWith(
                              fontWeight: FontWeight.w700),
                        ),
                      );
                    } else {
                      final profileModel = data.first;
                      return CircleAvatar(
                        backgroundImage: NetworkImage(profileModel.profilepic),
                        minRadius: 50,
                      );
                    }
                  },
                  error: (error, stackTrace) =>
                      Center(child: Text(error.toString())),
                  loading: () => const Center(
                      child: SizedBox(
                    width: 20, // Adjust this value as needed
                    height: 20, // Adjust this value as needed
                    child: CircularProgressIndicator(
                      strokeWidth:
                          1, // You can adjust the stroke width as needed
                    ),
                  )),
                ),
              ),
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: productData.when(
        data: (data) {
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Wrap(
                    spacing: 10,
                    children: tags
                        .map((tag) => ChoiceChip(
                              label: Text(tag),
                              selected: ref
                                  .watch(selectedTagsProvider)
                                  .selectedTags
                                  .contains(tag),
                              onSelected: (selected) {
                                ref.read(selectedTagsProvider).toggleTag(tag);
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final searchText = ref.watch(searchTextProvider);
                  final selectedTags =
                      ref.watch(selectedTagsProvider).selectedTags;
                  final filteredRaffles = raffles.value!
                      .where((product) =>
                          product.title
                              .toLowerCase()
                              .contains(searchText.toLowerCase()) &&
                          (selectedTags.isEmpty ||
                              product.tags
                                  .any((tag) => selectedTags.contains(tag))))
                      .toList();
                  filteredRaffles.sort((a, b) {
                    DateTime now = DateTime.now();
                    DateTime aStartDate = a.startDate.toDate();
                    DateTime aEndDate = a.endDate.toDate();
                    DateTime bStartDate = b.startDate.toDate();
                    DateTime bEndDate = b.endDate.toDate();

                    // Determine if the campaigns are upcoming, ongoing, just ended, or other
                    bool aIsUpcomingOrOngoing = aStartDate.isAfter(now) || (aStartDate.isBefore(now) && aEndDate.isAfter(now));
                    bool bIsUpcomingOrOngoing = bStartDate.isAfter(now) || (bStartDate.isBefore(now) && bEndDate.isAfter(now));
                    bool aJustEnded = aEndDate.isAtSameMomentAs(now) || (aEndDate.isBefore(now) && now.difference(aEndDate).inDays == 0);
                    bool bJustEnded = bEndDate.isAtSameMomentAs(now) || (bEndDate.isBefore(now) && now.difference(bEndDate).inDays == 0);

                    if (aIsUpcomingOrOngoing && !bIsUpcomingOrOngoing) {
                      // 'a' is upcoming/ongoing, 'b' is not
                      return -1;
                    } else if (!aIsUpcomingOrOngoing && bIsUpcomingOrOngoing) {
                      // 'b' is upcoming/ongoing, 'a' is not
                      return 1;
                    } else if (aJustEnded && !bJustEnded) {
                      // 'a' just ended, 'b' did not just end and is not upcoming/ongoing
                      // 'a' should come after all upcoming/ongoing but before 'b'
                      return -1;
                    } else if (!aJustEnded && bJustEnded) {
                      // 'b' just ended, 'a' did not just end and is not upcoming/ongoing
                      return 1;
                    }

                    // For other cases or equal priority, sort by startDate to keep chronological order
                    return aStartDate.compareTo(bStartDate);
                  });






                  // filteredRaffles.sort((a, b) {
                  //   DateTime now = DateTime.now();
                  //   DateTime aStartDate = a.startDate.toDate();
                  //   DateTime aEndDate = a.endDate.toDate();
                  //   DateTime bStartDate = b.startDate.toDate();
                  //   DateTime bEndDate = b.endDate.toDate();
                  //
                  //   // Check if raffles are upcoming or currently running
                  //   bool aIsUpcomingOrCurrent = aStartDate.isAfter(now) || (aStartDate.isBefore(now) && aEndDate.isAfter(now));
                  //   bool bIsUpcomingOrCurrent = bStartDate.isAfter(now) || (bStartDate.isBefore(now) && bEndDate.isAfter(now));
                  //
                  //   // Upcoming raffles (future start dates) take highest priority
                  //   if (aStartDate.isAfter(now) && bStartDate.isAfter(now) || aIsUpcomingOrCurrent && bIsUpcomingOrCurrent) {
                  //     if (aStartDate.isBefore(bStartDate)) {
                  //       // 'a' starts sooner in the future than 'b' or is closer to now than 'b'
                  //       return -1;
                  //     } else if (bStartDate.isBefore(aStartDate)) {
                  //       return 1;
                  //     }
                  //   }
                  //
                  //   if (aIsUpcomingOrCurrent && !bIsUpcomingOrCurrent) {
                  //     // 'a' is upcoming/current but 'b' is not
                  //     return -1;
                  //   } else if (!aIsUpcomingOrCurrent && bIsUpcomingOrCurrent) {
                  //     // 'b' is upcoming/current but 'a' is not
                  //     return 1;
                  //   }
                  //
                  //   // If both are past or not yet started, sort them by the soonest start date
                  //   return aStartDate.compareTo(bStartDate);
                  // });



                  return Expanded(
                      child: filteredRaffles.isEmpty
                          ? Center(
                              child: Text(
                                AppStrings.noRaffleFound,
                                style: kSmallTextStyle.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          : StreamBuilder<ConnectivityResult>(
                              stream: Connectivity().onConnectivityChanged,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // While waiting for the connectivity result, show a loading indicator
                                  return const HomeShimmer();
                                }

                                var connectivityResult = snapshot.data;
                                if (connectivityResult ==
                                    ConnectivityResult.none) {
                                  // No internet connection
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'No internet connection.',
                                          style: kMediumTextStyle,
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Check internet connection before navigating
                                            await _checkInternetConnection();
                                            connectivityResult =
                                                await Connectivity()
                                                    .checkConnectivity();

                                            if (connectivityResult !=
                                                ConnectivityResult.none) {
                                              if (!mounted) return;
                                              Navigator.pushNamed(
                                                  context, '/home');
                                            }
                                          },
                                          child: Text("Refresh",
                                              style: kSmallTextStyle),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  addAutomaticKeepAlives: false,
                                  addRepaintBoundaries: false,
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  itemCount: filteredRaffles.length,
                                  itemBuilder: (context, index) {
                                    final product = filteredRaffles[index];
                                    final currentState = getProductState(
                                        product!.startDate, product!.endDate);

                                    dynamic statusText;

                                    Color statusColor;

                                    if (currentState ==
                                        ProductState.resultDate) {
                                      statusText = 'InProgress';
                                      statusColor = Colors.green;
                                    } else if (currentState ==
                                        ProductState.done) {
                                      statusText = AppStrings.done;
                                      statusColor = Colors.orange;
                                    } else if (currentState ==
                                        ProductState.startDate) {
                                      final remainingTime = ref.watch(
                                        remainingTimeProvider(
                                            Timestamp.fromDate(
                                                product.startDate.toDate())),
                                      );
                                      statusText = remainingTime.when(
                                        data: (value) => value,
                                        loading: () => AppStrings.loading,
                                        error: (error, stackTrace) => 'Error',
                                      );

                                      statusColor = Colors.blue;
                                    } else {
                                      final remainingTime = ref.watch(
                                        remainingTimeProvider(
                                            Timestamp.fromDate(
                                                product.endDate.toDate())),
                                      );
                                      statusText = remainingTime.when(
                                        data: (value) => value,
                                        loading: () => AppStrings.loading,
                                        error: (error, stackTrace) => 'Error',
                                      );
                                      statusColor = Colors.red;
                                    }

                                    // Check if the selected tags match/ the product's tags
                                    if (ref
                                            .watch(selectedTagsProvider)
                                            .selectedTags
                                            .isEmpty ||
                                        product.tags.any((tag) => ref
                                            .watch(selectedTagsProvider)
                                            .selectedTags
                                            .contains(tag))) {
                                      return InkWell(
                                        onTap: () async {
                                          final firestore =
                                              FirebaseFirestore.instance;
                                          final productDocRef = firestore
                                              .collection('raffles')
                                              .doc(product.id);

                                          final attendeeCountsSnapshot =
                                              await productDocRef
                                                  .collection('attendees')
                                                  .get();
                                          final totalAttendeesCount =
                                              attendeeCountsSnapshot
                                                  .docs.length;
                                          if (!mounted) {
                                            return;
                                          }
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetails(
                                                name: product.productInfo.name,
                                                count:
                                                    product.productInfo.count,
                                                unit: product.productInfo.unit,
                                                unitPrice: product
                                                    .productInfo.unitPrice,
                                                attendeeCount:
                                                    totalAttendeesCount,
                                                requiredTickets: product
                                                    .requiredTickets
                                                    .toString(),
                                                documentId: product.id,
                                                images:
                                                    product.productInfo.images,
                                                statusColor: statusColor,
                                                description:
                                                    product.description,
                                                title: product.title,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.grey,
                                                offset: Offset(0.0, 1.0),
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  bottomLeft:
                                                      Radius.circular(16),
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: product.productInfo
                                                      .images[0].path,
                                                  fit: BoxFit.fill,
                                                  width: 100,
                                                  height: 105,
                                                ),
                                              ),
                                              8.pw,
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            product.title
                                                                .toString(),
                                                            style:
                                                                kMediumTextStyle
                                                                    .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            statusText,
                                                            style: TextStyle(
                                                              color:
                                                                  statusColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Html(
                                                          data: product
                                                              .description,
                                                          style: {
                                                            'body': Style(
                                                              fontSize:
                                                                  FontSize(
                                                                      14.0),
                                                              lineHeight:
                                                                  const LineHeight(
                                                                      1.4),
                                                              maxLines: 1,
                                                            ),
                                                          }),
                                                      8.ph,
                                                      Row(
                                                        children: [
                                                          CountWithIcon(
                                                            iconPath:
                                                                'assets/images/ticket1.png',
                                                            count: Text(
                                                              product
                                                                  .requiredTickets
                                                                  .toString(),
                                                              style:
                                                                  kMediumTextStyle
                                                                      .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ),
                                                          60.pw,
                                                          CountWithIcon(
                                                            iconPath:
                                                                'assets/images/person1.png',
                                                            count: attendeesData
                                                                .when(
                                                              data: (data) {
                                                                if (data
                                                                    .isEmpty) {
                                                                  return Text(
                                                                    '0',
                                                                    style: kMediumTextStyle
                                                                        .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  );
                                                                }

                                                                final productAttendeesCounts =
                                                                    data.where(
                                                                        (attendee) {
                                                                  return attendee
                                                                          .raffleId ==
                                                                      product
                                                                          .id; // Compare with product ID
                                                                }).toList();

                                                                final totalAttendeesCount =
                                                                    productAttendeesCounts
                                                                        .length;

                                                                return Text(
                                                                  '$totalAttendeesCount',
                                                                  style: kMediumTextStyle
                                                                      .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                );
                                                              },
                                                              error: (error,
                                                                      stackTrace) =>
                                                                  Text(
                                                                error
                                                                    .toString(),
                                                                style:
                                                                    kMediumTextStyle
                                                                        .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                              loading: () =>
                                                                  const SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      1,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                );
                              }));
                },
              ),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) {
          error.toString();
        },
        loading: () {
          const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });
  }
}
