import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';

class NetworkImageDisplayContainer extends StatelessWidget {
  const NetworkImageDisplayContainer({
    super.key,
    required this.imgUrl,
    required this.onTap,
    required this.height,
  });

  final String? imgUrl;
  final void Function()? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        height: height * 0.27,
        width: double.infinity,
        child: DashedContainer(
          dashColor: primaryBlue,
          strokeWidth: imgUrl != null ? 4 : 2,
          borderRadius: 20,
          child: imgUrl == null
              ? const Center(
                  child: Icon(
                    Icons.photo,
                    size: 50,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imgUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}
