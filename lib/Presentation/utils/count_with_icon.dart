import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:flutter/material.dart';


class CountWithIcon extends StatelessWidget {
  final String iconPath;
  final Widget count;
  const CountWithIcon({
    super.key,
    required this.iconPath,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          height: 20,
          width: 20,
          color: const Color(0xFF0f1d41),
        ),
        8.pw,

          count,

      ],
    );
  }
}
