import 'package:flutter/material.dart';
import 'package:intrencity/providers/verification_provider.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.documentId,
    required this.state,
    this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.scale,
  });

  final String documentId;
  final DocumentState state;
  final String? label;
  final void Function()? onPressed;
  final IconData? icon;
  final Color? color;
  final double? scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale ?? 0.85,
      child: Center(
        child: TextButton.icon(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(color),
          ),
          onPressed: onPressed,
          label: Text(
            label ?? '',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          icon: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
