import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/model/parking_space_post_model.dart';
import 'package:intrencity_provider/pages/user/parking_space_details_page.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Bookings',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          bottom: TabBar(
            dividerHeight: 0,
            enableFeedback: false,
            labelColor: primaryBlue,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 18,
                ),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide.none,
            ),
            tabs: const [
              Tab(text: 'Reserve'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              Reservation(),
              History(),
            ],
          ),
        ),
      ),
    );
  }
}

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('History'),
      ),
    );
  }
}

class Reservation extends StatefulWidget {
  const Reservation({super.key});

  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final searchController = TextEditingController();
  List searchParkingSpace = [];
  late Future<List<ParkingSpacePost>> _fetchSpaces;

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      searchController.text = _lastWords;
      searchSpace();
    });
  }

  // List<ParkingSpacePost> spaces = [
  //   ParkingSpacePost(
  //     spaceName: "Govandi",
  //     spacePrice: '99₹/hr',
  //     spaceLocation:
  //         'Location: 5th Avenue, Street No 16, Sakinaka, Mumbai 400065',
  //     spaceThumbnail: "assets/images/parkingslot.png",
  //   ),
  //   ParkingSpacePost(
  //     spaceName: "Sakinaka",
  //     spacePrice: '200₹/hr',
  //     spaceLocation:
  //         'Location: 5th Avenue, Street No 16, Sakinaka, Mumbai 400065',
  //     spaceThumbnail: "assets/images/parkingslot.png",
  //   ),
  //   ParkingSpacePost(
  //     spacePrice: '150₹/hr',
  //     spaceName: "Sakinaka",
  //     spaceLocation:
  //         'Location: 5th Avenue, Street No 16, Sakinaka, Mumbai 400065',
  //     spaceThumbnail: "assets/images/parkingslot.png",
  //   ),
  //   ParkingSpacePost(
  //     spacePrice: '150₹/hr',
  //     spaceName: "Dombivli",
  //     spaceLocation:
  //         'Location: 5th Avenue, Street No 16, Sakinaka, Mumbai 400065',
  //     spaceThumbnail: "assets/images/parkingslot.png",
  //   ),
  // ];

  // void searchSpace() {
  //   String searchTerm = _lastWords.toLowerCase();
  //   searchParkingSpace = spaces.where((space) {
  //     return space.spaceName.toLowerCase().contains(searchTerm);
  //   }).toList();
  //   setState(() {});
  // }

  void searchSpace() async {
    String searchTerm = _lastWords.toLowerCase();
    List<ParkingSpacePost> spaces = await fetchSpaces();
    searchParkingSpace = spaces.where((space) {
      return space.spaceName.toLowerCase().contains(searchTerm);
    }).toList();
    setState(() {});
  }

  Future<List<ParkingSpacePost>> fetchSpaces() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('spaces').get();

    return querySnapshot.docs.map((doc) {
      return ParkingSpacePost.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    searchController.addListener(() {
      _lastWords = searchController.text;
      searchSpace();
    });
    _fetchSpaces = fetchSpaces();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Column(
        children: [
          //Search Bar
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
                  suffixIcon: IconButton(
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
            child: FutureBuilder(
              future: _fetchSpaces,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error ${snapshot.error}'),
                  );
                } else {
                  List<ParkingSpacePost> spaces = snapshot.data!;
                  return ListView.builder(
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
                        thumbnail: space.spaceThumbnail,
                        spacePrice: space.spacePrice,
                        navigateTo: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParkingSpaceDetailsPage(
                                spaceDetails: spaces[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
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
