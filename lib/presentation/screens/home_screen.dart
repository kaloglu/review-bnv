import 'package:cihan_app/constants/text_styles.dart';
import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/presentation/screens/profile_screen.dart';
import 'package:cihan_app/presentation/utils/my_textfield.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../services/ProductStreamProvider.dart';
import '../utils/count_with_icon.dart';

class HomeScreen extends ConsumerWidget {
  static const id = 'HomeScreen';

  String formattedate(timestamp) {
    var dateFromTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('dd-MM-yy').format(dateFromTimeStamp);
  }

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productData = ref.watch(productsStreamProvider);
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          centerTitle: true,
          title: Material(
            elevation: 5.0,
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            child: MyTextField(
              hintText: 'Search',
              inputType: TextInputType.text,
              obsecureText: false,
              icon: Icons.search,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: productData.when(
            data: (data) {
             return Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        8.pw,
                        Chip(
                          label: const Text('Working'),
                          avatar: const Icon(
                            Icons.work,
                            color: Colors.red,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                        ),
                        8.pw,
                        Chip(
                          label: const Text('Music'),
                          avatar: const Icon(Icons.headphones),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                        ),
                        8.pw,
                        Chip(
                          label: const Text('Gaming'),
                          avatar: const Icon(
                            Icons.gamepad,
                            color: Colors.black,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                        ),
                        8.pw,
                        Chip(
                          label: const Text('Cooking & Eating'),
                          avatar: const Icon(
                            Icons.restaurant,
                            color: Colors.pink,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (ctx, index) {
                        final product = data[index];
                        //  Map ProductModel = data[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => ProductDetails(
                            //       imagePath: product.image,
                            //       description: product.description,
                            //       title: product.title,
                            //       //ticketCount: allDataList['ticket_count'],
                            //       //attendeeCount: allDataList['attendee_count'],
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
                                  // child: Image.asset(
                                  //   //product.image,
                                  //  // fit: BoxFit.fill,
                                  //   //width: 125,
                                  //   //height: 105,
                                  // ),
                                ),
                                8.pw,
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                              formattedate(product.startDate),
                                      
                                              style: kSmallTextStyle,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          product.description,
                                          style: kSmallTextStyle,
                                          maxLines: 10,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        8.ph,
                                        // Row(
                                        //   children: [
                                        //     CountWithIcon(
                                        //       iconPath: 'assets/images/ticket1.png',
                                        //       count: allDataList['ticket_count'],
                                        //     ),
                                        //     60.pw,
                                        //     CountWithIcon(
                                        //       iconPath: 'assets/images/person1.png',
                                        //       count: allDataList['attendee_count'],
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
              
            },
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                )));
  }
}
