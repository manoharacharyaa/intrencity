import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:lottie/lottie.dart';

class CustomDilogue {
  static Future<void> showSuccessDialog(
    BuildContext context,
    String lottie,
    String message, {
    bool autoDismiss = false,
    Duration dismissDuration = const Duration(seconds: 1),
    bool popNavigator = false,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (autoDismiss) {
          Future.delayed(dismissDuration, () {
            Navigator.of(context).pop();
            if (popNavigator && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }

        return Dialog(
          insetPadding: EdgeInsets.zero,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20,
              cornerSmoothing: 0.8,
            ),
          ),
          backgroundColor: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottie,
                  width: 100,
                  height: 100,
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
                if (!autoDismiss)
                  SizedBox(
                    width: 70,
                    height: 45,
                    child: MaterialButton(
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 1,
                        ),
                      ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
