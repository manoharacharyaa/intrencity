import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/providers/validator_provider.dart';
import 'package:provider/provider.dart';

class CustomAuthField extends StatelessWidget {
  const CustomAuthField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.prefix,
    this.onChanged,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
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

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthValidationProvider>().error;
    return SizedBox(
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: 18,
          cornerSmoothing: 2,
        ),
        child: TextFormField(
          controller: controller,
          cursorColor: Colors.white,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: textFieldGrey,
            prefix: prefix,
            hintText: hintText,
            hintStyle: TextStyle(
              color: error ? redAccent : Colors.white,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: error ? redAccent : Colors.white,
            ),
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 18,
                cornerSmoothing: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 18,
                cornerSmoothing: 2,
              ),
            ),
            errorStyle: const TextStyle(color: redAccent),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}
