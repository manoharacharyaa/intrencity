import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/theme.dart';
import 'package:intrencity_provider/home_page.dart';
import 'package:intrencity_provider/providers/admin_provider.dart';
import 'package:intrencity_provider/providers/auth_provider.dart';
import 'package:intrencity_provider/providers/booking_provider.dart';
import 'package:intrencity_provider/providers/validator_provider.dart';
import 'package:provider/provider.dart';
import 'package:intrencity_provider/firebase_options.dart';

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
        ChangeNotifierProvider(create: (context) => AdminProvide()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: darkTheme,
        // home: StreamBuilder(
        //   stream: FirebaseAuth.instance.authStateChanges(),
        //   builder: (context, snapshot) {
        //     if (!snapshot.hasData) {
        //       return const AuthPage();
        //     }
        //     return const ParkingSlotPage();
        //   },
        // ),
        home: const HomePage(),
      ),
    );
  }
}
