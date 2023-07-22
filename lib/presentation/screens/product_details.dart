import 'dart:async';

import 'package:cihan_app/constants/text_styles.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../../providers/product_data_fetch_provider.dart';
import '../utils/count_with_icon.dart';
import '../utils/reusable_small_btn.dart';

class ProductDetails extends ConsumerWidget {
  const ProductDetails({
    Key? key,
    required this.title,
    required this.description,
    required this.requiredTickets,
    required this.attendeeCount,
    required this.statusColor,
    required this.images,
    required this.documentId,
    required this.status,
  }) : super(key: key);
  final String title;
  final String description;
  final String requiredTickets;
  final String attendeeCount;
  final Color statusColor;
  final String documentId;
  final List<dynamic> images;
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN');
    final productInfoImages = ref.watch(productInfoImagesStreamProvider);

    return SafeArea(
      child: Scaffold(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ReusableSmallButton(
                    title: 'Enroll',
                    onTap: () {},
                  ),
                  12.pw,
                  ReusableSmallButton(
                    title: 'Earn',
                    onTap: () {},
                  ),
                ],
              ),
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
                            (data) => data['id'] == documentId)['images'];
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
                      error: (error, stackTrace) =>
                          Center(child: Text(error.toString())),
                      loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ))),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
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
                          status,
                          style: TextStyle(
                              color: statusColor, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        CountWithIcon(
                          iconPath: 'assets/images/ticket1.png',
                          count: requiredTickets.toString(),
                        ),
                        30.pw,
                        CountWithIcon(
                          iconPath: 'assets/images/person1.png',
                          count: attendeeCount,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
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
      ),
    );
  }

}
