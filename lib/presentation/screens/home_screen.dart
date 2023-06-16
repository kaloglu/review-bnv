import 'package:cihan_app/constants/text_styles.dart';
import 'package:cihan_app/presentation/screens/product_details.dart';
import 'package:cihan_app/presentation/screens/profile_screen.dart';
import 'package:cihan_app/presentation/utils/my_textfield.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:flutter/material.dart';

import '../utils/count_with_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Column(
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (ctx, index) {
                Map allDataList = dataList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductDetails(
                          imagePath: allDataList['image'],
                          description: allDataList['subtitle'],
                          title: allDataList['title'],
                          ticketCount: allDataList['ticket_count'],
                          attendeeCount: allDataList['attendee_count'],
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
                          child: Image.asset(
                            allDataList['image'],
                            fit: BoxFit.fill,
                            width: 125,
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
                                      allDataList['title'],
                                      style: kMediumTextStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      allDataList['date'],
                                      style: kSmallTextStyle,
                                    ),
                                  ],
                                ),
                                Text(
                                  allDataList['subtitle'],
                                  style: kSmallTextStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                8.ph,
                                Row(
                                  children: [
                                    CountWithIcon(
                                      iconPath: 'assets/images/ticket1.png',
                                      count: allDataList['ticket_count'],
                                    ),
                                    60.pw,
                                    CountWithIcon(
                                      iconPath: 'assets/images/person1.png',
                                      count: allDataList['attendee_count'],
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
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map> dataList = [
  {
    'title': 'Item 1',
    'subtitle': 'At vero eos et accusamus et iusto odio '
        'dignissimo ducimus qui blanditiis '
        'praesentium voluptatum at a deleniti atque'
        'corrupti quos dolores et quas moles '
        'excepturi sint occaecati ',
    'image': 'assets/images/book1.jpg',
    'date': '18.4.2023',
    'ticket_count': '4',
    'attendee_count': '5',
  },
  {
    'title': 'Item 2',
    'subtitle': 'At vero eos et accusamus et iusto odio '
        'dignissimo ducimus qui blanditiis '
        'praesentium voluptatum at a deleniti atque'
        'corrupti quos dolores et quas moles '
        'excepturi sint occaecati ',
    'image': 'assets/images/book2.jpg',
    'date': '18.4.2023',
    'ticket_count': '4',
    'attendee_count': '5',
  },
  {
    'title': 'Item 3',
    'subtitle': 'At vero eos et accusamus et iusto odio '
        'dignissimo ducimus qui blanditiis '
        'praesentium voluptatum at a deleniti atque'
        'corrupti quos dolores et quas moles '
        'excepturi sint occaecati ',
    'image': 'assets/images/book3.jpg',
    'date': '18.4.2023',
    'ticket_count': '4',
    'attendee_count': '5',
  },
  {
    'title': 'Item 1',
    'subtitle': 'At vero eos et accusamus et iusto odio '
        'dignissimo ducimus qui blanditiis '
        'praesentium voluptatum at a deleniti atque'
        'corrupti quos dolores et quas moles '
        'excepturi sint occaecati ',
    'image': 'assets/images/book1.jpg',
    'date': '18.4.2023',
    'ticket_count': '4',
    'attendee_count': '5',
  },
  {
    'title': 'Item 2',
    'subtitle': 'At vero eos et accusamus et iusto odio '
        'dignissimo ducimus qui blanditiis '
        'praesentium voluptatum at a deleniti atque'
        'corrupti quos dolores et quas moles '
        'excepturi sint occaecati ',
    'image': 'assets/images/book2.jpg',
    'date': '18.4.2023',
    'ticket_count': '4',
    'attendee_count': '5',
  },
  {
    'title': 'Item 3',
    'subtitle': 'At vero eos et accusamus et iusto odio '
        'dignissimo ducimus qui blanditiis '
        'praesentium voluptatum at a deleniti atque'
        'corrupti quos dolores et quas moles '
        'excepturi sint occaecati ',
    'image': 'assets/images/book3.jpg',
    'date': '18.4.2023',
    'ticket_count': '4',
    'attendee_count': '5',
  },
];
