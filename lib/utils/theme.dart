import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity/utils/colors.dart';

var darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(),
  useMaterial3: true,
  textTheme: TextTheme(
    bodySmall: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 25,
      fontWeight: FontWeight.w500,
    ),
  ),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Colors.white,
  ),
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(backgroundColor: primaryBlue),
);
