import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:lottie/lottie.dart';

class CustomDilogue {
  static void showSuccessDialog(
      BuildContext context, String lottie, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 5,
            cornerSmoothing: 5,
          ),
          child: Dialog(
            backgroundColor: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottie,
                    width: 120,
                    height: 120,
                    repeat: false,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 1,
                    ),
                    child: SizedBox(
                      width: 70,
                      height: 45,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(2),
                        color: primaryBlue,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'OK',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
