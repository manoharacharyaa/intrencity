import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.widget,
    this.height = 60,
    required this.onPressed,
  });

  final Widget widget;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: 55,
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: 15,
          cornerSmoothing: 1,
        ),
        child: MaterialButton(
          // padding: const EdgeInsets.symmetric(vertical: 5),
          onPressed: onPressed,
          height: 50,
          minWidth: double.infinity,
          color: primaryBlue,
          child: widget,
        ),
      ),
    );
  }
}
