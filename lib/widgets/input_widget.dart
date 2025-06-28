import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/constants.dart';

class InputWidget extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final double height;
  final String topLabel;
  final bool obscureText;

  InputWidget({
    required this.hintText,
    this.prefixIcon,
    this.height = 48.0,
    this.topLabel = "",
    this.obscureText = false,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topLabel, style: const TextStyle( fontSize: 15.0,),),
        const SizedBox(height: 10.0),
        Container(
          height: ScreenUtil().setHeight(height),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            obscureText: obscureText,
            cursorColor: RedColor,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: BlueColor,
                ),
              ),

              hintText: this.hintText,
              hintStyle: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ),
        )
      ],
    );
  }
}
