import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../constants/enum_for_date.dart';
import '../../constants/text_styles.dart';
import '../../providers/attendees_provider.dart';
import '../../providers/enroll_provider.dart';
import '../../providers/home_screen_providers.dart';
import '../../providers/product_data_fetch_provider.dart';
import '../utils/count_with_icon.dart';
import 'home_screen.dart';

class EnrollHistory extends ConsumerStatefulWidget {
  const EnrollHistory({super.key});

  @override
  _EnrollHistoryState createState() => _EnrollHistoryState();
}

class _EnrollHistoryState extends ConsumerState<EnrollHistory> {
  @override
  Widget build(BuildContext context) {
    final productData = ref.watch(productsStreamProvider);
    final attendeesData = ref.watch(attendeesStreamProvider);
    final enrollData = ref.watch(enrollStreamProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'Enroll History',
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: enrollData.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Text(
                'No Data Found',
                style: kMediumTextStyle.copyWith(fontWeight: FontWeight.w700),
              ),
            );
          } else {
            return ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: data.length,
              itemBuilder: (ctx, index) {
                final product = data[index];

                return GestureDetector(
                  onTap: () async {
                    final firestore = FirebaseFirestore
                        .instance; // Get the Firestore instance

                    final productDocRef =
                        firestore.collection('raffles').doc(product.uid);

                    final attendeeCountsSnapshot =
                        await productDocRef.collection('attendees').get();
                    final totalAttendeesCount =
                        attendeeCountsSnapshot.docs.length;
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
                            product.image,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      iconPath: 'assets/images/ticket1.png',
                                      count: enrollData.when(
                                          data: (enrollData) {
                                            if (enrollData.isEmpty) {
                                              return Center(
                                                child: Text(
                                                  '0',
                                                  style:
                                                      kMediumTextStyle.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                ),
                                              );
                                            }
                                            // final productEnrolledsCounts =
                                            //     enrollData.where((enrolled) {
                                            //   return enrolled.raffleid ==
                                            //       product
                                            //           .raffleid; // Compare with product ID
                                            // }).toList();
                                            //
                                            // final totalEnrolledCount =
                                            //     productEnrolledsCounts.length;

                                            return Text(
                                              product.enrollmentCount
                                                  .toString(),
                                              style: kMediumTextStyle.copyWith(
                                                  fontWeight: FontWeight.w700),
                                            );
                                          },
                                          error: (error, stackTrace) => Center(
                                              child: Text(error.toString())),
                                          loading: () =>
                                              const CircularProgressIndicator()),
                                    ),
                                    60.pw,
                                    CountWithIcon(
                                      iconPath: 'assets/images/person1.png',
                                      count: attendeesData.when(
                                        data: (attendeesData) {
                                          if (attendeesData.isEmpty) {
                                            return Text(
                                              '0',
                                              style: kMediumTextStyle.copyWith(
                                                  fontWeight: FontWeight.w700),
                                            );
                                          }

                                          final productAttendeesCounts =
                                              attendeesData.where((attendee) {
                                            return attendee.productId ==
                                                product
                                                    .raffleid; // Compare with product ID
                                          }).toList();

                                          final totalAttendeesCount =
                                              productAttendeesCounts.length;

                                          return Text(
                                            '$totalAttendeesCount',
                                            style: kMediumTextStyle.copyWith(
                                                fontWeight: FontWeight.w700),
                                          );
                                        },
                                        error: (error, stackTrace) => Text(
                                          error.toString(),
                                          style: kMediumTextStyle.copyWith(
                                              fontWeight: FontWeight.w700),
                                        ),
                                        loading: () =>
                                            const CircularProgressIndicator(),
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
          }
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
