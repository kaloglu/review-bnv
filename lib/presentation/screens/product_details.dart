import 'package:cihan_app/constants/text_styles.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../utils/count_with_icon.dart';
import '../utils/reusable_small_btn.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.ticketCount,
    required this.attendeeCount,
  }) : super(key: key);

  final String title;
  final String imagePath;
  final String description;
  final String ticketCount;
  final String attendeeCount;

  @override
  Widget build(BuildContext context) {
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
              child: Swiper(
                autoplay: true,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: AssetImage(
                          swiperImages[index],
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                },
                itemCount: 3,
                pagination: const SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                    activeColor: Colors.blue,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
                        'Time/Progress',
                        style: kMediumTextStyle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CountWithIcon(
                        iconPath: 'assets/images/ticket1.png',
                        count: ticketCount,
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
                  Text(
                    description,
                    style: kSmallTextStyle,
                    textAlign: TextAlign.justify,
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

final List<String> swiperImages = [
  "assets/images/book1.jpg",
  "assets/images/book2.jpg",
  "assets/images/book3.jpg",
];
