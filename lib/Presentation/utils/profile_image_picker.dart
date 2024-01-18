import 'package:flutter/material.dart';

class ProfileImagePicker extends StatelessWidget {
  final VoidCallback onTap;
  const ProfileImagePicker({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage(
            'assets/images/m1.jpeg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: const Image(
          height: 25,
          width: 25,
          image: AssetImage(
            'assets/images/edit_3.png',
          ),
        ),
      ),
    );
  }
}
