import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    required this.onTap,
    required this.title,
    required this.bgColor,
    required this.textColor,
    required this.icon,
  }) : super(key: key);

  final Function onTap;
  final Color bgColor;
  final String title;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 315,
      child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ElevatedButton.styleFrom(
          shadowColor: const Color(0xFF92A3FD),
          backgroundColor: bgColor,
          padding: const EdgeInsets.all(0.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
            ),
            20.pw,
            Text(
              title,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
