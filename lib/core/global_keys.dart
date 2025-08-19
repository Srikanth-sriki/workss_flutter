import 'package:flutter/material.dart';

/// Use this in MaterialApp.navigatorKey
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Optional: if you prefer SnackBar instead of overlay_support
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
