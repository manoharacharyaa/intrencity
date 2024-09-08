import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';

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
            cornerRadius: 16,
            cornerSmoothing: 1,
          ),
          child: Container(
            width: double.infinity,
            height: height * 0.07,
            color: primaryBlue,
            child: Center(
              child: isLoading
                  ? const CupertinoActivityIndicator(
                      radius: 13,
                      animating: true,
                      color: Colors.white,
                    )
                  : Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
