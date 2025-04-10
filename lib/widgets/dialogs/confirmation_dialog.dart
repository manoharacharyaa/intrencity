import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/widgets/buttons/small_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    this.title,
    this.onConfirm,
    this.onReject,
    this.onTap,
    this.actions,
    this.buttonColor,
    this.buttonLabel,
    this.singleButtom = false,
  });

  final String? title;
  final void Function()? onConfirm;
  final void Function()? onReject;
  final void Function()? onTap;
  final List<Widget>? actions;
  final bool? singleButtom;
  final Color? buttonColor;
  final String? buttonLabel;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: textFieldGrey,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 20,
            cornerSmoothing: 0.8,
          ),
        ),
        content: SizedBox(
          height: 100,
          width: 50,
          child: Center(
            child: Text(
              title ?? '',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: singleButtom == true
            ? [
                SmallButton(
                  color: buttonColor,
                  label: buttonLabel,
                  onTap: onTap,
                ),
              ]
            : [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SmallButton(
                      onTap: onConfirm,
                      color: greenAccent,
                      label: 'Confirm',
                    ),
                    SmallButton(
                      onTap: onReject,
                      color: redAccent,
                      label: 'Reject',
                    ),
                  ],
                ),
              ],
      ),
    );
  }
}
