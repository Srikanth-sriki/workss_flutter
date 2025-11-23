import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'network_helper.dart';

/// Network error handler utility
class NetworkErrorHandler {
  /// Handle HTTP response errors
  static String handleHttpError(http.Response? response, dynamic error) {
    // First check if it's a network error
    if (NetworkHelper.isNetworkError(error)) {
      return NetworkHelper.getNetworkErrorMessage(error);
    }

    // Handle HTTP status codes
    if (response != null) {
      switch (response.statusCode) {
        case 400:
          return 'Invalid request. Please check your input and try again.';
        case 401:
          return 'Session expired. Please login again.';
        case 403:
          return 'Access denied. You don\'t have permission for this action.';
        case 404:
          return 'Requested resource not found. Please try again.';
        case 408:
          return 'Request timeout. Please check your connection and try again.';
        case 500:
          return 'Server error. Our team has been notified. Please try again later.';
        case 502:
          return 'Service temporarily unavailable. Please try again in a moment.';
        case 503:
          return 'Service is currently unavailable. Please try again later.';
        case 504:
          return 'Server timeout. Please check your connection and try again.';
        default:
          if (response.statusCode >= 500) {
            return 'Server error occurred. Please try again later.';
          } else if (response.statusCode >= 400) {
            return 'Request failed. Please try again.';
          }
      }
    }

    // Generic error message
    return 'Something went wrong. Please try again.';
  }

  /// Show network error snackbar with clean, user-friendly message
  static void showNetworkErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show network error dialog with clean, user-friendly message
  static Future<void> showNetworkErrorDialog(
    BuildContext context,
    String message, {
    String title = 'Connection Error',
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red.shade700),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Check network before operation and show error if offline
  static Future<bool> checkNetworkBeforeOperation(
    BuildContext context, {
    bool showError = true,
  }) async {
    final hasConnection = await NetworkHelper.hasInternetConnection();

    if (!hasConnection && showError) {
      showNetworkErrorSnackBar(
        context,
        'No internet connection. Please check your network and try again.',
      );
    }

    return hasConnection;
  }
}
