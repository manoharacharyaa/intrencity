import 'package:carousel_slider/carousel_slider.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/model/parking_space_post_model.dart';
import 'package:intrencity_provider/pages/user/parking_slot_page.dart';
import 'package:intrencity_provider/widgets/buttons/custom_button.dart';

class ParkingSpaceDetailsPage extends StatefulWidget {
  const ParkingSpaceDetailsPage({
    super.key,
    required this.spaceDetails,
  });

  final ParkingSpacePost spaceDetails;

  @override
  State<ParkingSpaceDetailsPage> createState() =>
      _ParkingSpaceDetailsPageState();
}

class _ParkingSpaceDetailsPageState extends State<ParkingSpaceDetailsPage> {
  @override
  Widget build(BuildContext context) {
    List<String> images = widget.spaceDetails.spaceThumbnail;

    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Details',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.015),
            CarouselSlider(
              options: CarouselOptions(
                height: height * 0.3,
                autoPlay: true,
                enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 2),
              ),
              items: images
                  .map((image) => ClipSmoothRect(
                        radius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 1,
                        ),
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                Text(
                  widget.spaceDetails.spaceName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 15),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 15,
                      cornerSmoothing: 1,
                    ),
                    child: Container(
                      color: textFieldGrey,
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: secondaryBlue),
                          ),
                          Text(
                            widget.spaceDetails.spacePrice,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const CustomDivider(),
                          Text(
                            'Location',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: secondaryBlue),
                          ),
                          Text(
                            widget.spaceDetails.spaceLocation,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.18,
            ),
            CustomButton(
              horizontalPadding: 10,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParkingSlotPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Container(
        height: 0.2,
        color: Colors.white,
      ),
    );
  }
}
