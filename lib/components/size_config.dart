import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData = const MediaQueryData();
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;
  static double blockWidth = 0.0;
  static double blockHeight = 0.0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    // Calculate blocks based on screen size
    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;

    // Adjust blockHeight based on screen aspect ratio if needed
    if (screenHeight / screenWidth >= 1.7 && screenHeight / screenWidth < 1.8) {
      blockHeight = screenHeight / 110;
    } else if (screenHeight / screenWidth >= 1.8 && screenHeight / screenWidth < 1.9) {
      blockHeight = screenHeight / 114;
    } else if (screenHeight / screenWidth >= 1.9 && screenHeight / screenWidth < 2) {
      blockHeight = screenHeight / 116;
    } else if (screenHeight / screenWidth >= 2 && screenHeight / screenWidth < 2.1) {
      blockHeight = screenHeight / 118;
    } else if (screenHeight / screenWidth >= 2.1) {
      blockHeight = screenHeight / 120;
    }
  }
}
