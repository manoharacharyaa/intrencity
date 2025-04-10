import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';

class SmallButton extends StatelessWidget {
  const SmallButton({
    super.key,
    this.onTap,
    this.color,
    this.label,
  });

  final void Function()? onTap;
  final Color? color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SmoothContainer(
      onTap: onTap,
      cornerRadius: 10,
      height: 35,
      width: 90,
      color: color ?? primaryBlue,
      child: Center(
        child: Text(
          label ?? '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
