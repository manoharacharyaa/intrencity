import 'package:go_router/go_router.dart';
import 'package:intrencity/home_page.dart';
import 'package:intrencity/main.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/views/auth/auth_page.dart';
import 'package:intrencity/views/user/edit_post_page.dart';
import 'package:intrencity/views/user/parking_list_page.dart';
import 'package:intrencity/views/user/parking_space_details_page.dart';
import 'package:intrencity/views/user/post_space_page.dart';
import 'package:intrencity/views/user/profile_page.dart';

class AppRoutes {
  GoRouter get router => _router;

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthChecker(),
      ),
      GoRoute(
        path: '/home-page',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/parking-list',
        builder: (context, state) => const ParkingListPage(),
      ),
      GoRoute(
        path: '/profile-page',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/auth-page',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/space-posting-page',
        builder: (context, state) => const SpacePostingPage(),
      ),
      GoRoute(
        path: '/parking-space-details',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final spaceDetails = args['spaceDetails'] as ParkingSpacePostModel;
          final viewedByCurrentUser = args['viewedByCurrentUser'] as bool;
          return ParkingSpaceDetailsPage(
            spaceDetails: spaceDetails,
            viewedByCurrentUser: viewedByCurrentUser,
          );
        },
      ),
      GoRoute(
        path: '/edit-post-page',
        builder: (context, state) {
          final currentUserSpace = state.extra as ParkingSpacePostModel;
          return EditPostPage(
            currentUserSpace: currentUserSpace,
          );
        },
      ),
    ],
  );
}
