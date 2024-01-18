import 'package:flutter/material.dart';

import '../constants/text_styles.dart';

class MyRichText extends StatelessWidget {
  const MyRichText({
    Key? key,
    required this.text1,
    required this.text2,
  }) : super(key: key);

  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text1,
          style: kSmallTextStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: ' $text2',
              style: kSmallTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}


// GoogleFonts.poppins(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//                 color: const Color(0XFFC58BF2),
//               ),
//             )
