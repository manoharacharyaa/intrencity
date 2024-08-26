import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/providers/booking_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.slotNumber});

  final int slotNumber;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? startDateTime;
  DateTime? endDateTime;

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          final selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStart) {
            startDateTime = selectedDateTime;
          } else {
            endDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Booking Page",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/car_animation.json',
                height: height * 0.4,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _selectDateTime(context, true),
                      child: ClipSmoothRect(
                        radius: SmoothBorderRadius(
                          cornerRadius: 16,
                          cornerSmoothing: 2,
                        ),
                        child: Container(
                          height: 60,
                          color: textFieldGrey,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                startDateTime == null
                                    ? 'Select start date & time'
                                    : '${startDateTime!.toLocal()}'
                                        .split('.')[0],
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectDateTime(context, false),
                      child: ClipSmoothRect(
                        radius: SmoothBorderRadius(
                          cornerRadius: 16,
                          cornerSmoothing: 2,
                        ),
                        child: Container(
                          height: 60,
                          color: textFieldGrey,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                endDateTime == null
                                    ? 'Select end date & time'
                                    : '${endDateTime!.toLocal()}'.split('.')[0],
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 16,
                    cornerSmoothing: 1,
                  ),
                  child: Container(
                    height: 60,
                    color: primaryBlue,
                    child: MaterialButton(
                      onPressed: (startDateTime == null || endDateTime == null)
                          ? null
                          : () {
                              if (endDateTime!.isBefore(startDateTime!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'End time cannot be before start time.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final duration =
                                  endDateTime!.difference(startDateTime!);

                              context.read<BookingProvider>().bookSlot(
                                    widget.slotNumber,
                                    duration,
                                  );
                              Navigator.pop(context);
                            },
                      height: 50,
                      minWidth: double.infinity,
                      child: Text(
                        'Book',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
