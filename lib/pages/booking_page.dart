import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/providers/booking_provider.dart';
import 'package:intrencity_provider/widgets/booking_page_form_field.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.slotNumber});

  final int slotNumber;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final daysController = TextEditingController();
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();
  final secondsController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    daysController.dispose();
    hoursController.dispose();
    minutesController.dispose();
    secondsController.dispose();
    super.dispose();
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
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          BookingPageFormField(
                            controller: daysController,
                            hintText: 'Enter Days',
                          ),
                          BookingPageFormField(
                            controller: hoursController,
                            hintText: 'Enter Hours',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          BookingPageFormField(
                            controller: minutesController,
                            hintText: 'Enter Minutes',
                          ),
                          BookingPageFormField(
                            controller: secondsController,
                            hintText: 'Enter Seconds',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 15,
                    cornerSmoothing: 2,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      final days = int.tryParse(daysController.text) ?? 0;
                      final hours = int.tryParse(hoursController.text) ?? 0;
                      final minutes = int.tryParse(minutesController.text) ?? 0;
                      final seconds = int.tryParse(secondsController.text) ?? 0;
                      final duration = Duration(
                        days: days,
                        hours: hours,
                        minutes: minutes,
                        seconds: seconds,
                      );

                      context
                          .read<BookingProvider>()
                          .bookSlot(widget.slotNumber, duration);
                      Navigator.pop(context);
                    },
                    height: 50,
                    minWidth: double.infinity,
                    color: primaryBlue,
                    child: Text(
                      'Book',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w800,
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
