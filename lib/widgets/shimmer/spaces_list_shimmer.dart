import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:shimmer/shimmer.dart';

class SpacesListShimmer extends StatelessWidget {
  const SpacesListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Shimmer.fromColors(
                    baseColor: const Color.fromARGB(255, 44, 44, 44),
                    highlightColor: const Color.fromARGB(255, 95, 95, 95),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipSmoothRect(
                        radius: SmoothBorderRadius(
                          cornerRadius: 20,
                          cornerSmoothing: 1,
                        ),
                        child: Container(
                          height: size.height * 0.27,
                          width: double.infinity,
                          color: textFieldGrey,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: SizedBox(
                      height: size.height * 0.27,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: CustomShimmerContainer(
                                height: 40,
                                width: size.width * 0.2,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomShimmerContainer(
                                height: 35,
                                width: size.width * 0.5,
                              ),
                              CustomShimmerContainer(
                                height: 35,
                                width: size.width * 0.1,
                              ),
                            ],
                          ),
                          const CustomShimmerContainer(
                            height: 25,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomShimmerContainer extends StatelessWidget {
  const CustomShimmerContainer({
    super.key,
    this.height,
    this.width,
    this.cornerRadius = 10,
  });

  final double? height;
  final double? width;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 84, 84, 84),
      highlightColor: const Color.fromARGB(255, 56, 56, 56),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: 1,
          ),
          child: Container(
            height: height,
            color: textFieldGrey,
            width: width,
          ),
        ),
      ),
    );
  }
}
