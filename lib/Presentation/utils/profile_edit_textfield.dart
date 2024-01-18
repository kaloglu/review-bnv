
import 'package:flutter/material.dart';

import '../constants/text_styles.dart';


class ProfileTextFields extends StatelessWidget {
   ProfileTextFields({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
      this.isEnabled,
     required this.readonly,
     this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final String labelText;
    bool? isEnabled;
   final bool readonly;
   final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      readOnly: readonly,
      keyboardType: keyboardType,
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
