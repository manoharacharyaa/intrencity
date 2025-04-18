import 'package:go_router/go_router.dart';
import 'package:intrencity/home_page.dart';
import 'package:intrencity/main.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/views/admin/super_admin/admin_page.dart';
import 'package:intrencity/views/admin/parking_space_admin/admin_parking_page.dart';
import 'package:intrencity/views/admin/parking_space_admin/my_spaces_page.dart';
import 'package:intrencity/views/admin/parking_space_admin/tab_pages/bookings_page.dart';
import 'package:intrencity/views/auth/auth_page.dart';
import 'package:intrencity/views/user/edit_post_page.dart';
import 'package:intrencity/views/user/parking_list_page.dart';
import 'package:intrencity/views/user/parking_space_details_page.dart';
import 'package:intrencity/views/user/post_space_page.dart';
import 'package:intrencity/views/user/profile_page.dart';
import 'package:intrencity/views/verification_page.dart';

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
      GoRoute(
        path: '/verification-page',
        builder: (context, state) => const VerificationPage(),
      ),
      GoRoute(
        path: '/admin-page',
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        path: '/parking-bookings-page',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final spaceId = args['spaceId'] as String;
          final docId = args['docId'] as String;
          return BookingsPage(
            spaceId: spaceId,
            docId: docId,
          );
        },
      ),
      GoRoute(
        path: '/my-spaces-page',
        builder: (context, state) => const MySpacesPage(),
      ),
      GoRoute(
        path: '/admin-parking-page',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final spaceId = args['spaceId'] as String;
          final docId = args['docId'] as String;
          return AdminParkingPage(
            spaceId: spaceId,
            docId: docId,
          );
        },
      ),
    ],
  );
}
