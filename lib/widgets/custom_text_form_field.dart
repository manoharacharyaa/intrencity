import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/providers/validator_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthValidationProvider>().error;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding ?? 0,
        horizontal: horizontalPadding ?? 0,
      ),
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: 16,
          cornerSmoothing: 1,
        ),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          cursorColor: Colors.white,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
            filled: true,
            fillColor: textFieldGrey,
            prefix: prefix,
            hintText: hintText,
            hintStyle: TextStyle(
              color: error ? redAccent : Colors.grey,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: error ? redAccent : Colors.white,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: SmoothBorderRadius(
                cornerRadius: 16,
                cornerSmoothing: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: SmoothBorderRadius(
                cornerRadius: 18,
                cornerSmoothing: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 16,
                cornerSmoothing: 1,
              ),
            ),
            errorStyle: const TextStyle(color: redAccent),
            error: null,
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}
