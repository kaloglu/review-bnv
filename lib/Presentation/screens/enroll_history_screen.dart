import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Data/services/connectivity.dart';
import '../../lang.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';
import '../providers/enroll_provider.dart';

import '../utils/count_with_icon.dart';

class EnrollHistory extends ConsumerStatefulWidget {
  const EnrollHistory({super.key});

  @override
  EnrollHistoryState createState() => EnrollHistoryState();
}

class EnrollHistoryState extends ConsumerState<EnrollHistory> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final connectivity = ConnectivityService();
    connectivity.connectivityStream.listen((isConnected) {
      if (!isConnected) {
        const CircularProgressIndicator();
        // Show ShimmerLoader for a few seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (!isConnected) {

            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: const Text(
                    'No internet connection. Please check your network settings.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {

                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ));
          }
        });
      }});
  }
  @override
  Widget build(BuildContext context) {
    final enrollData = ref.watch(enrollStreamProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          AppStrings.enrollHistory,
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // Change your back button color here
        ),
      ),
      body: enrollData.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noDataFound,
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
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => ProductDetails(
                    //       attendeeCount: totalAttendeesCount,
                    //     ),
                    //   ),
                    // );
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
                                      count: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('raffles')
                                            .doc(product.raffleid)
                                            .collection('attendees')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SizedBox(
                                              width: 20, // Adjust this value as needed
                                              height: 20, // Adjust this value as needed
                                              child: CircularProgressIndicator(
                                                strokeWidth:
                                                2, // You can adjust the stroke width as needed
                                              ),
                                            );
                                          }

                                          if (snapshot.hasError) {
                                            return Text(
                                              'Error: ${snapshot.error}',
                                              style: kMediumTextStyle.copyWith(
                                                  fontWeight: FontWeight.w700),
                                            );
                                          }

                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return Text(
                                              '0',
                                              style: kMediumTextStyle.copyWith(
                                                  fontWeight: FontWeight.w700),
                                            );
                                          }

                                          final count = snapshot.data!.docs.length;

                                          return Text(
                                            '$count',
                                            style: kMediumTextStyle.copyWith(
                                                fontWeight: FontWeight.w100),
                                          );
                                        },
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
