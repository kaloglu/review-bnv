import 'package:flutter/material.dart';

import '../../constants/text_styles.dart';

class ProfileTextFields extends StatelessWidget {
  const ProfileTextFields({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
  });

  final TextEditingController controller;
  final String hintText;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: kSmallTextStyle,
        labelText: labelText,
        labelStyle: kSmallTextStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
