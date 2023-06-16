import 'package:cihan_app/presentation/utils/icon_buttons.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';
import '../utils/container_counter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'Profile',
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              EvaIcons.edit2Outline,
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.5, 0.9],
                colors: [
                  Color(0XFF9fd8ef),
                  Color(0XFFdbf0f9),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CircleAvatar(
                      minRadius: 55,
                      backgroundColor: AppColors.primaryColor,
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/m2.jpg'),
                        minRadius: 50,
                      ),
                    ),
                  ],
                ),
                12.ph,
                Text(
                  "Cihan Kaloglu",
                  style: kLargeTextStyle,
                ),
                Text(
                  "Istanbul, Turkey",
                  style: kMediumTextStyle,
                )
              ],
            ),
          ),
          const Row(
            children: <Widget>[
              CounterWithContainerIcon(
                imagePath: 'assets/images/ticket1.png',
                count: '12',
              ),
              CounterWithContainerIcon(
                imagePath: 'assets/images/person1.png',
                count: '18',
              ),
              CounterWithContainerIcon(
                imagePath: 'assets/images/trophy1.png',
                count: '18',
              ),
            ],
          ),
          ListTile(
            title: Text(
              "Email",
              style: kSmallTextStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Cihan@Kaloglu.com",
              style: kSmallTextStyle,
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              "Phone",
              style: kSmallTextStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "+977 9818225533",
              style: kSmallTextStyle,
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              "Address",
              style: kSmallTextStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Street 3 house no 2 Istanbul",
              style: kSmallTextStyle,
            ),
          ),
          const Divider(),
          10.ph,
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MyIconButtons(
                icon: EvaIcons.google,
              ),
              MyIconButtons(
                icon: EvaIcons.twitter,
              ),
              MyIconButtons(
                icon: EvaIcons.facebook,
              ),
              MyIconButtons(
                icon: EvaIcons.phone,
              ),
            ],
          )
        ],
      ),
    );
  }
}
