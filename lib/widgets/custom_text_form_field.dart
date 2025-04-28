import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/providers/validator_provider.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:provider/provider.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.prefix,
    this.maxLines,
    this.onChanged,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.verticalPadding,
    this.horizontalPadding,
    this.fillColor,
  });

  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final double? verticalPadding;
  final double? horizontalPadding;
  final int? maxLines;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthValidationProvider>().error;
    final provider = context.watch<AuthValidationProvider>();

    return GestureDetector(
      onTap: () => error == true ? provider.setError(false) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding ?? 0,
          horizontal: horizontalPadding ?? 0,
        ),
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 12,
            cornerSmoothing: 0.8,
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            cursorColor: Colors.white,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 14,
                ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 17,
              ),
              filled: true,
              fillColor: fillColor ?? textFieldGrey,
              prefix: prefix,
              hintText: hintText,
              hintStyle: TextStyle(
                color: error ? redAccent : Colors.grey,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: error ? redAccent : Colors.white,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 12,
                  cornerSmoothing: 0.8,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 12,
                  cornerSmoothing: 0.8,
                ),
              ),
              errorStyle: const TextStyle(color: redAccent),
              error: null,
            ),
            onChanged: onChanged,
            validator: validator,
          ),
        ),
      ),
    );
  }
}
