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
    List<String> images = [
      'https://miro.medium.com/v2/resize:fit:1400/0*yNQrasZXZxq-KALC.jpg',
      'https://d27p8o2qkwv41j.cloudfront.net/wp-content/uploads/2018/01/shutterstock_521216080-e1515000863176.jpg',
      'https://www.bdcnetwork.com/sites/default/files/parking.jpg'
    ];

    List<int> list = [1, 2, 3, 4, 5];
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Details',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.015),
          CarouselSlider(
            options: CarouselOptions(
              // autoPlay: true,
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
          Text(
            widget.spaceDetails.spaceName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipSmoothRect(
              radius: SmoothBorderRadius(
                cornerRadius: 15,
                cornerSmoothing: 1,
              ),
              child: Container(
                color: textFieldGrey,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.bodyMedium,
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
          const Spacer(),
          CustomButton(
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
    );
  }
}
