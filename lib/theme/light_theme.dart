import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';

Color _primaryColor = ColorResources.colorPrimary;
Color _secondaryColor = ColorResources.colorPrimaryVariant;


ThemeData light({Color? primaryColor, Color? secondaryColor})=> ThemeData(
  fontFamily: 'TitilliumWeb',
  primaryColor: _primaryColor,
  brightness: Brightness.light,
  highlightColor: Colors.white,
  hintColor: ColorResources.colorPrimaryVariant, //Border Color
  splashColor: Colors.transparent,
  cardColor: Colors.white,

  scaffoldBackgroundColor: const Color(0xFFF7F8FA),

  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Color(0xFF222324)),  // Text color primary
    bodyMedium: TextStyle(color: _primaryColor), // Text color Secondary
    bodySmall: TextStyle(color: ColorResources.colorPrimaryVariant),  // Text color Light grey

    titleMedium: TextStyle(color: ColorResources.colorPrimaryDark),

  ),

  colorScheme:  ColorScheme.light(
    primary: _primaryColor,  // Primary Color
    secondary: _secondaryColor,  // Secondary Color
    tertiary: const Color(0xFFFFBB38), // Warning Color
    tertiaryContainer: ColorResources.colorPrimaryLight,
    onTertiaryContainer: const Color(0xFF04BB7B), // Success Color
    onPrimary: ColorResources.colorPrimaryLight,
    surface: ColorResources.white,
    onSecondary: secondaryColor ?? ColorResources.colorPrimaryMedium,
    error: const Color(0xFFFF4040), // Danger Color
    onSecondaryContainer: ColorResources.colorPrimaryLight,
    outline: const Color(0xff5C8FFC), // Info Color
    onTertiary: ColorResources.colorPrimaryLight,
    shadow: ColorResources.colorPrimaryDark,

    primaryContainer: ColorResources.colorPrimaryMedium,
    secondaryContainer: const Color(0xFFE9EEF4),
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);
