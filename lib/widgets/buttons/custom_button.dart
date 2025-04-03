import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onTap,
    this.isLoading = false,
    this.verticalPadding = 0,
    this.horizontalPadding = 0,
    required this.title,
  });

  final void Function()? onTap;
  final bool isLoading;
  final double verticalPadding;
  final double horizontalPadding;
  final String title;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: InkWell(
        highlightColor: Colors.white,
        onTap: onTap,
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 12,
            cornerSmoothing: 0.8,
          ),
          child: Container(
            width: double.infinity,
            height: 50,
            color: primaryBlue,
            child: Center(
              child: isLoading
                  ? const CupertinoActivityIndicator(
                      radius: 12,
                      animating: true,
                      color: Colors.white,
                    )
                  : Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
