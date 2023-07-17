import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';
import '../utils/icon_buttons.dart';
import '../utils/profile_edit_textfield.dart';
import '../utils/profile_image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
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
                ProfileImagePicker(
                  onTap: () {},
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ProfileTextFields(
                  controller: nameController,
                  hintText: 'XYZ ABC',
                  labelText: 'Name',
                ),
                ProfileTextFields(
                  controller: emailController,
                  hintText: 'asdf@gmail.com',
                  labelText: 'Email',
                ),
                ProfileTextFields(
                  controller: emailController,
                  hintText: '+64231313456',
                  labelText: 'Phone',
                ),
                ProfileTextFields(
                  controller: emailController,
                  hintText: "Street 3 house no 2 Istanbul",
                  labelText: 'Address',
                ),
              ],
            ),
          ),
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
              MyIconButtons(
                icon: EvaIcons.logOut,
              ),
            ],
          )
        ],
      ),
    );
  }
}
