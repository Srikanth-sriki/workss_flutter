import 'package:flutter/material.dart';
import 'network_helper.dart';
import 'network_error_handler.dart';

/// Global network error handler that works with the overlay
class GlobalNetworkErrorHandler {
  /// Handle network errors in BLoC and show appropriate messages
  static String handleError(dynamic error, {String? customMessage}) {
    // Check if it's a network error
    if (NetworkHelper.isNetworkError(error)) {
      return customMessage ?? NetworkHelper.getNetworkErrorMessage(error);
    }
    
    // Return custom message or generic error
    return customMessage ?? 'Something went wrong. Please try again.';
  }

  /// Show error snackbar (only if network overlay is not showing)
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    bool isNetworkError = false,
  }) {
    // If it's a network error, the overlay will handle it
    // But we can still show a snackbar for immediate feedback
    if (isNetworkError) {
      NetworkErrorHandler.showNetworkErrorSnackBar(context, message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Check network before operation
  static Future<bool> checkNetwork(
    BuildContext context, {
    bool showSnackBar = false,
  }) async {
    final hasConnection = await NetworkHelper.hasInternetConnection();
    
    if (!hasConnection && showSnackBar) {
      NetworkErrorHandler.showNetworkErrorSnackBar(
        context,
        'No internet connection. Please check your network and try again.',
      );
    }
    
    return hasConnection;
  }
}

