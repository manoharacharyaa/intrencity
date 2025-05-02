import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: 'Find Parking Spaces',
      description:
          'Discover convenient parking spots near your destination with real-time availability.',
      image: 'assets/images/onboarding1.png',
    ),
    OnboardingItem(
      title: 'Easy Booking',
      description:
          'Book your parking space in advance with just a few taps and secure your spot.',
      image: 'assets/images/onboarding2.png',
    ),
    OnboardingItem(
      title: 'Manage Your Space',
      description:
          'List your parking space and earn by renting it out when you\'re not using it.',
      image: 'assets/images/onboarding3.png',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    if (mounted) {
      context.go('/auth-page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with onboarding content
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == onboardingItems.length - 1;
              });
            },
            itemCount: onboardingItems.length,
            itemBuilder: (context, index) {
              return OnboardingScreen(item: onboardingItems[index]);
            },
          ),

          // Page indicator
          Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip button
                TextButton(
                  onPressed: () {
                    _controller.jumpToPage(onboardingItems.length - 1);
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Page indicator dots
                SmoothPageIndicator(
                  controller: _controller,
                  count: onboardingItems.length,
                  effect: const WormEffect(
                    spacing: 16,
                    dotColor: Colors.white,
                    activeDotColor: primaryBlue,
                  ),
                  onDotClicked: (index) {
                    _controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                  },
                ),

                // Next/Done button
                TextButton(
                  onPressed: () {
                    if (isLastPage) {
                      _completeOnboarding();
                      context.go('/auth-page');
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    isLastPage ? 'Done' : 'Next',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            item.image,
            height: 300,
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
  });
}
