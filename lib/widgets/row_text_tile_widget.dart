import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/views/user/my_bookings/booking_details.dart';

class RowTextTile extends StatelessWidget {
  const RowTextTile({
    super.key,
    this.widget,
    required this.label,
    required this.text,
  });

  final BookingDetails? widget;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: primaryBlue),
        ),
        Text(
          text,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}
