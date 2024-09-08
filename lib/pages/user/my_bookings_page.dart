import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/model/parking_space_post_model.dart';
import 'package:intrencity_provider/pages/user/parking_space_details_page.dart';
import 'package:intrencity_provider/pages/user/profile_page.dart';
import 'package:intrencity_provider/widgets/profilepic_avatar.dart';
import 'package:intrencity_provider/widgets/shimmer/spaces_list_shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  @override
  Widget build(BuildContext context) {
    String profilePic = '';
    String? uid;
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      uid = user.uid;
    } else {
      print("No user found");
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Parkings',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          leading: IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu_rounded),
          ),
          actions: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    uid!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      ),
                      child: const CircleAvatar(
                        backgroundColor: textFieldGrey,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  var userProfile =
                      snapshot.data!.data() as Map<String, dynamic>;
                  profilePic = userProfile['profilePic'] ?? '';
                  if (profilePic.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ProfilePicAvatar(
                        height: 45,
                        width: 45,
                        profilePic: profilePic,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        ),
                      ),
                    );
                  }
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ProfilePicAvatar(
                    height: 45,
                    width: 45,
                    profilePic: profilePic,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
        body: const SpacesListPage(),
      ),
    );
  }
}

class SpacesListPage extends StatefulWidget {
  const SpacesListPage({super.key});

  @override
  State<SpacesListPage> createState() => _SpacesListPageState();
}

class _SpacesListPageState extends State<SpacesListPage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final searchController = TextEditingController();
  List searchParkingSpace = [];
  late Future<List<ParkingSpacePostModel>> _fetchSpaces;

  bool _isListening = false;
  Timer? _timer;

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
    } catch (e) {
      return null;
    }
    setState(() {});
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
    });
    await _speechToText.listen(onResult: _onSpeechResult);

    // Start a timer to stop listening after 10 seconds
    _timer = Timer(const Duration(seconds: 5), () {
      if (_isListening) {
        _stopListening();
      }
    });
  }

  void _stopListening() async {
    _timer?.cancel(); // Cancel the timer if it’s still active
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      searchController.text = _lastWords;
      voicesearchSpace();
    });
    _stopListening();
  }

  void voicesearchSpace() async {
    String searchTerm = _lastWords.toLowerCase();
    List<ParkingSpacePostModel> spaces = await fetchSpaces();
    searchParkingSpace = spaces.where((space) {
      return space.spaceLocation.toLowerCase().contains(searchTerm);
    }).toList();
    setState(() {});
  }

  Future<List<ParkingSpacePostModel>> fetchSpaces() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('spaces').get();

    return querySnapshot.docs.map((doc) {
      return ParkingSpacePostModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> _refreshData() async {
    List<ParkingSpacePostModel> spaces = await fetchSpaces();
    setState(() {
      searchParkingSpace = spaces.where((space) {
        return space.spaceLocation.toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();

    searchController.addListener(() {
      _lastWords = searchController.text;
      voicesearchSpace();
    });
    _fetchSpaces = fetchSpaces();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: ClipSmoothRect(
              radius: const SmoothBorderRadius.all(
                SmoothRadius(
                  cornerRadius: 14,
                  cornerSmoothing: 1,
                ),
              ),
              child: TextField(
                controller: searchController,
                cursorColor: Colors.white,
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(15),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: textFieldGrey,
                  hintText: 'Search places',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _isListening
                      ? Lottie.asset(
                          'assets/animations/voice_search.json',
                          width: 50,
                          height: 50,
                          fit: BoxFit.fill,
                        )
                      : IconButton(
                          onPressed: _speechToText.isNotListening
                              ? _startListening
                              : _stopListening,
                          icon: const Icon(Icons.mic),
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('spaces').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SpacesListShimmer();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No parking spaces found'),
                  );
                } else {
                  List<ParkingSpacePostModel> spaces = snapshot.data!.docs
                      .map((doc) => ParkingSpacePostModel.fromJson(
                          doc.data() as Map<String, dynamic>))
                      .toList();

                  List<ParkingSpacePostModel> searchParkingSpace =
                      spaces.where((space) {
                    return space.spaceLocation.toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        );
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: searchController.text.isEmpty
                          ? spaces.length
                          : searchParkingSpace.length,
                      itemBuilder: (context, index) {
                        final space = searchController.text.isEmpty
                            ? spaces[index]
                            : searchParkingSpace[index];
                        return ParkingSpace(
                          size: size,
                          spaceName: space.spaceName,
                          spaceLocation: space.spaceLocation,
                          thumbnail: space.spaceThumbnail[0],
                          spacePrice: space.spacePrice,
                          navigateTo: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParkingSpaceDetailsPage(
                                  viewedByCurrentUser: false,
                                  spaceDetails: searchController.text.isEmpty
                                      ? spaces[index]
                                      : searchParkingSpace[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ParkingSpace extends StatelessWidget {
  const ParkingSpace({
    super.key,
    required this.size,
    required this.spaceName,
    required this.spaceLocation,
    required this.thumbnail,
    required this.spacePrice,
    this.navigateTo,
  });

  final Size size;
  final String spaceName;
  final String spaceLocation;
  final String spacePrice;
  final String thumbnail;
  final void Function()? navigateTo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: 20,
          cornerSmoothing: 1,
        ),
        child: GestureDetector(
          onTap: navigateTo,
          child: Stack(
            children: [
              SizedBox(
                height: size.height * 0.27,
                width: double.infinity,
                child: Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: size.height * 0.27,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color.fromARGB(170, 0, 0, 0),
                      Color.fromARGB(240, 0, 0, 0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                height: size.height * 0.27,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(spaceName),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 3),
                          child: Icon(
                            Icons.star,
                            color: Colors.orange,
                          ),
                        ),
                        const Text(
                          ' 4.5',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      spaceLocation,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Container(
                height: size.height * 0.27,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color.fromARGB(200, 0, 0, 0),
                    ],
                    begin: Alignment.bottomCenter,
                    tileMode: TileMode.clamp,
                    transform: GradientRotation(6),
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    spacePrice,
                    style: const TextStyle(
                      fontSize: 20,
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
