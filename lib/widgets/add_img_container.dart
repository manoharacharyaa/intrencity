import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';

class AddImageContainer extends StatelessWidget {
  const AddImageContainer({
    super.key,
    required this.onTap,
    this.height = 0,
    this.child,
  });

  final void Function()? onTap;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DashedContainer(
          dashColor: primaryBlue,
          strokeWidth: 2,
          borderRadius: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: child ??
                const Center(
                  child: Icon(
                    Icons.add_photo_alternate,
                    size: 50,
                    color: primaryBlue,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
