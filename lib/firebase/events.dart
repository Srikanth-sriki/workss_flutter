import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logScreenEvent(String screenName) async {
    await _analytics.setCurrentScreen(
      screenName: screenName,
    );
  }

  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    // Ensure the timestamp is added as an Object type (String in this case)
    parameters['timestamp'] = DateTime.now().toIso8601String();

    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
    print(parameters);
    print(name);
  }
}
