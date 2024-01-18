import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/text_styles.dart';



class ReusableSmallButton extends StatelessWidget {
  final String title;
  final Function onTap;
  const ReusableSmallButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTap;
        },
        child: Container(
          width: 168,
          height: 40,
          margin: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              title,
              style: kMediumTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}
