import 'package:flutter/material.dart';

import '../constants/text_styles.dart';

// ignore: must_be_immutable
class MyTextField extends StatelessWidget {
   MyTextField({
    Key? key,
   
    required this.hintText,
    required this.inputType,
    required this.obsecureText,
    required this.icon,
    required this.onTap,
    required this.onChanged,

    
  }) : super(key: key);
  final String hintText;

  final TextInputType inputType;
  TextEditingController controller = TextEditingController();
  final bool obsecureText;
  final IconData icon;
  final Function onTap;
  final Function onChanged;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 327,
      child: TextField(
        keyboardType: inputType,
        obscureText: obsecureText,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          suffixIconConstraints: const BoxConstraints(
            maxHeight: 40,
            maxWidth: 40,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                onTap();
              },
              child: Image.asset('assets/images/img.png'),
            ),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF7B6F72),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: kSmallTextStyle,
        ),
      ),
    );
  }
}
