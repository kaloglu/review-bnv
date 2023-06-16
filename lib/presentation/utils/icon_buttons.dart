import 'package:flutter/material.dart';

class MyIconButtons extends StatelessWidget {
  const MyIconButtons({
    Key? key,
    required this.icon,
  }) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFDDDADA),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(
              icon,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
