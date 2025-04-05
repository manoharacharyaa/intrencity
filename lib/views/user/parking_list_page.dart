import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/parking_list_provider.dart';
import 'package:intrencity/providers/users_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/providers/auth_provider.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/widgets/profilepic_avatar.dart';
import 'package:intrencity/widgets/shimmer/spaces_list_shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ParkingListPage extends StatelessWidget {
  const ParkingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingListProvider>(context);
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final userProvider = context.watch<UsersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parkings',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          StreamBuilder(
            stream: parkingProvider.getUserStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !parkingProvider.isUserLoggedIn) {
                return _buildGuestAvatar(context, authProvider.isGuest);
              }
              if (snapshot.hasData && !authProvider.isGuest) {
                var userProfile = snapshot.data!.data() as Map<String, dynamic>;
                String profilePic = userProfile['profilePic'] ?? '';
                if (profilePic.isNotEmpty) {
                  return _buildProfileAvatar(context, profilePic);
                }
              }
              return _buildProfileAvatar(context, '');
            },
          )
        ],
      ),
      drawer: Drawer(
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: 12, cornerSmoothing: 0.8),
          ),
        ),
        child: Column(
          children: [
            Image.network(
              userProvider.user?.profilePic ?? '',
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: ListTile(
                onTap: () => context.push('/admin-page'),
                tileColor: Colors.amber,
                shape: const SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.all(
                    SmoothRadius(cornerRadius: 12, cornerSmoothing: 0.8),
                  ),
                ),
                leading: const Icon(
                  Icons.admin_panel_settings,
                  size: 30,
                ),
                title: Text(
                  'Admin Pannel',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
      ),
      body: userProvider.user == null
          ? const SpacesListShimmer()
          : const SpacesListPage(),
    );
  }

  Widget _buildGuestAvatar(BuildContext context, bool isGuest) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => isGuest
            ? context.push('/auth-page')
            : context.push('/profile-page'),
        child: const CircleAvatar(
          backgroundColor: textFieldGrey,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String profilePic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ProfilePicAvatar(
        height: 45,
        width: 45,
        profilePic: profilePic,
        onTap: () => context.push('/profile-page'),
      ),
    );
  }
}

class SpacesListPage extends StatelessWidget {
  const SpacesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingListProvider>(context);
    final size = MediaQuery.sizeOf(context);

    return Column(
      children: [
        _buildSearchBar(context, provider),
        Expanded(
          child: _buildSpacesList(context, provider, size),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, ParkingListProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ClipSmoothRect(
        radius: const SmoothBorderRadius.all(
          SmoothRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
        child: TextField(
          controller: provider.searchController,
          cursorColor: Colors.white,
          style: Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(15),
            border: InputBorder.none,
            filled: true,
            fillColor: textFieldGrey,
            hintText: 'Search places',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _buildSuffixIcon(provider),
          ),
        ),
      ),
    );
  }

  Widget _buildSuffixIcon(ParkingListProvider provider) {
    if (provider.isListening) {
      return Lottie.asset(
        'assets/animations/voice_search.json',
        width: 50,
        height: 50,
        fit: BoxFit.fill,
      );
    }
    return provider.searchController.text.isEmpty
        ? IconButton(
            onPressed: provider.startListening,
            icon: const Icon(Icons.mic),
          )
        : IconButton(
            onPressed: provider.clearSearch,
            icon: const Icon(Icons.clear_rounded),
          );
  }

  Widget _buildSpacesList(
    BuildContext context,
    ParkingListProvider provider,
    Size size,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: provider.getSpacesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SpacesListShimmer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No parking spaces found'));
        }

        List<ParkingSpacePostModel> spaces = snapshot.data!.docs
            .map((doc) => ParkingSpacePostModel.fromJson(
                doc.data() as Map<String, dynamic>))
            .toList();

        List<ParkingSpacePostModel> filteredSpaces = spaces.where((space) {
          return space.spaceLocation
              .toLowerCase()
              .contains(provider.searchController.text.toLowerCase());
        }).toList();

        return _buildSpacesListView(
          context,
          provider,
          size,
          spaces,
          filteredSpaces,
        );
      },
    );
  }

  Widget _buildSpacesListView(
    BuildContext context,
    ParkingListProvider provider,
    Size size,
    List<ParkingSpacePostModel> spaces,
    List<ParkingSpacePostModel> filteredSpaces,
  ) {
    return RefreshIndicator(
      onRefresh: () async {},
      color: Colors.white,
      child: ListView.builder(
        itemCount: provider.searchController.text.isEmpty
            ? spaces.length
            : filteredSpaces.length,
        itemBuilder: (context, index) {
          final space = provider.searchController.text.isEmpty
              ? spaces[index]
              : filteredSpaces[index];
          return ParkingSpace(
            size: size,
            spaceName: space.spaceName,
            spaceLocation: space.spaceLocation,
            thumbnail: space.spaceThumbnail[0],
            spacePrice: '${space.selectedCurrency} ${space.spacePrice}',
            navigateTo: () => context.push(
              '/parking-space-details',
              extra: {
                'spaceDetails': provider.searchController.text.isEmpty
                    ? spaces[index]
                    : filteredSpaces[index],
                'viewedByCurrentUser': false,
              },
            ),
          );
        },
      ),
    );
  }
}

class ParkingSpace extends StatelessWidget {
  const ParkingSpace({
    super.key,
    required this.size,
    this.spaceName,
    this.thumbnail,
    this.spaceLocation,
    this.spacePrice,
    this.navigateTo,
  });

  final Size size;
  final String? spaceName;
  final String? spaceLocation;
  final String? spacePrice;
  final String? thumbnail;
  final void Function()? navigateTo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: 15,
          cornerSmoothing: 0.8,
        ),
        child: GestureDetector(
          onTap: navigateTo,
          child: Stack(
            children: [
              SizedBox(
                height: size.height * 0.27,
                width: double.infinity,
                child: Image.network(
                  thumbnail ?? '',
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
                        Text(spaceName ?? ''),
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
                      spaceLocation ?? '',
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
                    spacePrice ?? '',
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
