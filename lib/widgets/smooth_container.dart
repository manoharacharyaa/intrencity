import 'package:flutter/material.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';

class SmoothContainer extends StatelessWidget {
  const SmoothContainer({
    super.key,
    this.cornerRadius = 0,
    this.height,
    this.width,
    this.child,
    this.decoration,
    this.color,
    this.padding,
  });

  final double? cornerRadius;
  final double? height;
  final double? width;
  final Widget? child;
  final Color? color;
  final Decoration? decoration;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: cornerRadius!,
        cornerSmoothing: 1,
      ),
      child: Container(
        padding: padding,
        height: height,
        width: width,
        color: color,
        decoration: decoration,
        child: child,
      ),
    );
  }
}
