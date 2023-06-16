import 'package:cihan_app/constants/app_colors.dart';
import 'package:cihan_app/constants/text_styles.dart';
import 'package:cihan_app/presentation/screens/home_screen.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import '../utils/my_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Hey there,',
                  style: kMediumTextStyle,
                ),
                Text(
                  'Welcome Back',
                  style: kLargeTextStyle,
                ),
                50.ph,
                MyButton(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  title: 'Google',
                  bgColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  icon: EvaIcons.google,
                ),
                12.ph,
                MyButton(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  title: 'Twitter',
                  bgColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  icon: EvaIcons.twitter,
                ),
                12.ph,
                MyButton(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  title: 'Facebook',
                  bgColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  icon: EvaIcons.facebook,
                ),
                12.ph,
                MyButton(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  title: 'Phone Auth',
                  bgColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  icon: EvaIcons.phone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
