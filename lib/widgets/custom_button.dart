import 'package:flutter/material.dart';
import 'package:kuaishou_remote_uploader/widgets/custom_text.dart';

import 'package:sizer/sizer.dart';


class CustomButton extends StatelessWidget {
  final void Function() func;
  final Color color;
  final String title;
  final double fontsize;
  final OutlinedBorder shape;

  const CustomButton({
    super.key,
    required this.func,
    required this.title,
    this.fontsize = 12,
    this.color = Colors.grey,
    this.shape = const StadiumBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: func,
        style: ElevatedButton.styleFrom(
            shape: shape,
            backgroundColor: color,
            elevation: 10,
            minimumSize: Size(
              80.w,
              7.h,
            )
            // padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 4.w),
            ),
        child: CustomText(
          title: title,
          headline: false,
          size: fontsize,
          color: Colors.white,
        ));
  }
}
