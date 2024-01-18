import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:flutter/material.dart';


class CounterWithContainerIcon extends StatelessWidget {
  final Widget count;
  final String imagePath;
  final VoidCallback onTap;
  const CounterWithContainerIcon({
    super.key,
    required this.count,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: const Color(0XFFdbf0f9),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 28,
                width: 28,
                color: const Color(0xFF0f1d41),
              ),
              8.pw,

                count,
                //textAlign: TextAlign.center,
               // style: kLargeTextStyle,

            ],
          ),
        ),
      ),
    );
  }
}