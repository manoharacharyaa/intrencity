import 'package:carousel_slider/carousel_slider.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
    final startDate = DateTime.parse(widget.spaceDetails.startDate.toString());
    final endDate = DateTime.parse(widget.spaceDetails.endDate.toString());
    final formatedStartDate = DateFormat('dd-MM-yy').format(startDate);
    final formatedEndDate = DateFormat('dd-MM-yy').format(endDate);

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
                          cornerRadius: 20,
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
                      color: Colors.grey[900],
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SpaceDetailInfo(
                            label: 'Name',
                            info: widget.spaceDetails.spaceName,
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Location',
                            info: widget.spaceDetails.spaceLocation,
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Vehicle Tpes',
                            info: widget.spaceDetails.vehicleType.join(', '),
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Slots & Price',
                            info:
                                'No of slots (${widget.spaceDetails.spaceSlots}) & ${widget.spaceDetails.spacePrice}',
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Aminities',
                            info: widget.spaceDetails.aminitiesType.join(', '),
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Available From',
                            info: '$formatedStartDate  To  $formatedEndDate',
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Space Description',
                            info: widget.spaceDetails.description!,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CustomButton(
              horizontalPadding: 10,
              verticalPadding: 20,
              onTap: () {
                print(int.parse(widget.spaceDetails.spaceSlots));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParkingSlotPage(
                      noOfSlots: int.parse(widget.spaceDetails.spaceSlots),
                      startDate: widget.spaceDetails.startDate,
                      endDate: widget.spaceDetails.endDate,
                    ),
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

class SpaceDetailInfo extends StatelessWidget {
  const SpaceDetailInfo({
    super.key,
    required this.label,
    required this.info,
  });

  final String label;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          info,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 4),
      child: Container(
        height: 0.2,
        color: Colors.white,
      ),
    );
  }
}
