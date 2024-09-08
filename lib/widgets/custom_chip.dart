import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity_provider/constants/colors.dart';

class CustomChip extends StatelessWidget {
  const CustomChip({
    super.key,
    this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String? label;
  final bool isSelected;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 1,
          ),
          child: Container(
            height: 45,
            color: isSelected ? primaryBlue : textFieldGrey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  label!,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
