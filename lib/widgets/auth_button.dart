import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.widget,
    required this.onPressed,
  });

  final Widget widget;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: 15,
        cornerSmoothing: 1,
      ),
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 17),
        onPressed: onPressed,
        height: 50,
        minWidth: double.infinity,
        color: primaryBlue,
        child: widget,
      ),
    );
  }
}
