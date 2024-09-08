import 'dart:io';
import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';

class ImagePickerContainer extends StatelessWidget {
  const ImagePickerContainer({
    super.key,
    required this.height,
    required File? imgFile,
    required this.onTap,
  }) : _imgFile = imgFile;

  final double height;
  final File? _imgFile;
  final void Function()? onTap;

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
          strokeWidth: _imgFile != null ? 4 : 2,
          borderRadius: 20,
          child: _imgFile == null
              ? const Center(
                  child: Icon(
                    Icons.photo,
                    size: 50,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    _imgFile,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}
