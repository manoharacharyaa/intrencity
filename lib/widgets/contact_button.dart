import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';

class ContactButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;

  const ContactButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        style: const ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(0, 50),
          ),
          backgroundColor: WidgetStatePropertyAll(primaryBlue),
          iconColor: WidgetStatePropertyAll(Colors.white),
        ),
        label: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Colors.white),
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  }
}
