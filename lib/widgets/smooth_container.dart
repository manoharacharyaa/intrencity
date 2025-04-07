import 'package:flutter/material.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';

class SmoothContainer extends StatelessWidget {
  const SmoothContainer({
    super.key,
    this.cornerRadius,
    this.height,
    this.width,
    this.child,
    this.decoration,
    this.color,
    this.padding,
    this.contentPadding,
    this.horizontalPadding,
    this.verticalPadding,
    this.onTap,
  });

  final double? cornerRadius;
  final double? height;
  final double? width;
  final Widget? child;
  final Color? color;
  final Decoration? decoration;
  final EdgeInsets? padding;
  final EdgeInsets? contentPadding;
  final double? horizontalPadding;
  final double? verticalPadding;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: horizontalPadding ?? 0,
            vertical: verticalPadding ?? 0,
          ),
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: cornerRadius ?? 18,
          cornerSmoothing: 0.8,
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: contentPadding ?? EdgeInsets.zero,
            height: height,
            width: width,
            color: color,
            decoration: decoration,
            child: child,
          ),
        ),
      ),
    );
  }
}
