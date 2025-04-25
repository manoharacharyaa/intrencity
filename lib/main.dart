import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/providers/booking_provider.dart';
import 'package:intrencity/providers/parking_list_provider.dart';
import 'package:intrencity/providers/profile_provider.dart';
import 'package:intrencity/providers/verification_provider.dart';
import 'package:intrencity/routes/app_routes.dart';
import 'package:intrencity/utils/theme.dart';
import 'package:intrencity/home_page.dart';
import 'package:intrencity/viewmodels/users_viewmodel.dart';
import 'package:intrencity/views/auth/auth_page.dart';
import 'package:intrencity/providers/auth_provider.dart';
import 'package:intrencity/providers/validator_provider.dart';
import 'package:provider/provider.dart';
import 'package:intrencity/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BookingProvider()),
        ChangeNotifierProvider(create: (context) => AuthValidationProvider()),
        ChangeNotifierProvider(create: (context) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (context) => ParkingListProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => VerificationProvider()),
        ChangeNotifierProvider(create: (context) => SpaceAdminViewmodel()),
        ChangeNotifierProvider(create: (context) => UsersViewmodel()),
        // ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: darkTheme,
        routerConfig: AppRoutes().router,
        // home: const AuthChecker(),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }
        return const AuthPage();
      },
    );
  }
}
