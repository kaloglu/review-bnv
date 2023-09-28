import 'dart:async';

import 'package:cihan_app/constants/text_styles.dart';
import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/presentation/screens/profile_screen.dart';
import 'package:cihan_app/presentation/utils/container_counter.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:cihan_app/providers/attendees_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/chips_data.dart';
import '../../constants/enum_for_date.dart';
import '../../main.dart';
import '../../providers/enroll_provider.dart';
import '../../providers/product_data_fetch_provider.dart';
import '../../providers/home_screen_providers.dart';
import '../../providers/search_provider.dart';
import '../utils/count_with_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' as hooks;

final selectedCategoryProvider =
    StateNotifierProvider<SelectedCategoryNotifier, String?>(
  (ref) => SelectedCategoryNotifier(),
);

// Create a StreamController for the status

class HomeScreen extends ConsumerStatefulWidget {
  static const id = 'HomeScreen';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HIIIIIIIIIIIIIIIIIIIIIIIII');
    final productData = ref.watch(productsStreamProvider);
    final attendeesData = ref.watch(attendeesStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    String? selectedChipLabel = ref.watch(selectedCategoryProvider);

    // Filter products based on the selected category and search query

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
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
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(),
                      ),
                    );
                  },
                  child: Image.asset('assets/images/img.png'),
                ),
              )),
        ),
        automaticallyImplyLeading: false,
      ),
      body: productData.when(
        data: (data) {
          final searchQuery = ref.watch(searchTextProvider);
          // Filter products based on the selected category and search query
          final filteredProducts = productData.when(
            data: (data) => data.where((product) {
              final hasSearchQuery = product.title
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
              final hasSelectedCategory = selectedCategory == null ||
                  product.category == selectedCategory;
              return hasSearchQuery && hasSelectedCategory;
            }).toList(),
            // Handle loading and error states if needed
            loading: () => [],
            error: (error, stackTrace) => [],
          );

          // final filteredProducts = data
          //     .where(
          //       (product) => product.title
          //           .toLowerCase()
          //           .contains(searchQuery.toLowerCase()),
          //     )
          //     .toList();

          final availableChips = getAvailableChips(data);
          return Column(
            children: [
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: availableChips.map((chipLabel) {
                    final chipIcon = categoryIconMap[chipLabel];
                    final chipColor = categoryColorMap[chipLabel];
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ChoiceChip(
                          label: Text(
                            chipLabel,
                          ),
                          avatar: selectedChipLabel == chipLabel
                              ? Icon(
                                  chipIcon,
                                  color: Colors
                                      .white, // Change the color of the icon when selected
                                  size:
                                      20, // Change the size of the icon when selected
                                )
                              : null, // Hide the icon when unselected

                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          // ignore: unrelated_type_equality_checks
                          selected: selectedCategory == chipLabel,
                          onSelected: (isSelected) {
                            ref
                                .read(selectedCategoryProvider.notifier)
                                .setCategory(isSelected
                                    ? chipLabel
                                    : null); // Update selected category
                          },
                        ));
                  }).toList(),
                ),
              ),
              Expanded(
                child: Consumer(builder: (context, ref, child) {
                  return ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: filteredProducts.length,
                    itemBuilder: (ctx, index) {
                      final product = filteredProducts[index];
                      final currentState = getProductState(product);
                      String statusText;
                      Color statusColor;

                      if (currentState == ProductState.resultDate) {
                        statusText = 'InProgress';
                        statusColor = Colors.green;
                      } else if (currentState == ProductState.done) {
                        statusText = 'Done';
                        statusColor = Colors.orange;
                      } else if (currentState == ProductState.startDate) {
                        final remainingTime = ref.watch(
                            remainingTimeProvider(product.startDate.toDate()));
                        statusText = remainingTime.when(
                          data: (value) => value ?? '',
                          loading: () => 'Loading',
                          error: (error, stackTrace) => 'Error',
                        );

                        statusColor = Colors.blue;
                      } else {
                        final remainingTime = ref.watch(
                            remainingTimeProvider(product.endDate.toDate()));
                        statusText = remainingTime.when(
                          data: (value) => value ?? '',
                          loading: () => 'Loading',
                          error: (error, stackTrace) => 'Error',
                        );
                        statusColor = Colors.red;
                      }

                      return GestureDetector(
                        onTap: () async {
                          final firestore = FirebaseFirestore
                              .instance; // Get the Firestore instance

                          final productDocRef =
                              firestore.collection('raffles').doc(product.id);

                          final attendeeCountsSnapshot =
                              await productDocRef.collection('attendees').get();
                          final totalAttendeesCount =
                              attendeeCountsSnapshot.docs.length;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductDetails(
                                name: product.productInfo.name,
                                count: product.productInfo.count,
                                unit: product.productInfo.unit,
                                unitPrice: product.productInfo.unitPrice,
                                attendeeCount: totalAttendeesCount,
                                requiredTickets:
                                    product.requiredTickets.toString(),
                                documentId: product.id,
                                images: product.productInfo.images,
                                statusColor: statusColor,
                                description: product.description,
                                title: product.title,
                                status: statusText,
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
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                child: Image.network(
                                  product.productInfo.images[0].path,
                                  fit: BoxFit.fill,
                                  width: 100,
                                  height: 105,
                                ),
                              ),
                              8.pw,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              product.title,
                                              style: kMediumTextStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              statusText,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ]),
                                      Html(data: product.description, style: {
                                        'body': Style(
                                            fontSize: FontSize(14.0),
                                            lineHeight: const LineHeight(1.4),
                                            maxLines: 1),
                                      }),
                                      8.ph,
                                      Row(
                                        children: [
                                          CountWithIcon(
                                            iconPath:
                                                'assets/images/ticket1.png',
                                            count: Text(
                                                product.requiredTickets
                                                    .toString(),
                                                style:
                                                    kMediumTextStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700)),
                                          ),
                                          60.pw,
                                          CountWithIcon(
                                            iconPath:
                                                'assets/images/person1.png',
                                            count: attendeesData.when(
                                              data: (data) {
                                                if (data.isEmpty) {
                                                  return Text(
                                                    '0',
                                                    style: kMediumTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                  );
                                                }

                                                final productAttendeesCounts =
                                                    data.where((attendee) {
                                                  return attendee.productId ==
                                                      product
                                                          .id; // Compare with product ID
                                                }).toList();

                                                final totalAttendeesCount =
                                                    productAttendeesCounts
                                                        .length;

                                                return Text(
                                                  '$totalAttendeesCount',
                                                  style:
                                                      kMediumTextStyle.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                );
                                              },
                                              error: (error, stackTrace) =>
                                                  Text(
                                                error.toString(),
                                                style:
                                                    kMediumTextStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700),
                                              ),
                                              loading: () =>
                                                  CircularProgressIndicator(),
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
                    },
                  );
                }),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class SelectedCategoryNotifier extends StateNotifier<String?> {
  SelectedCategoryNotifier() : super(null);

  void setCategory(String? category) {
    state = category;
  }
}
