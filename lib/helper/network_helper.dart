import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Network helper class to check connectivity and handle network errors
class NetworkHelper {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      // If no connectivity at all, return false
      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      // Check if we can actually reach the internet
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        return false;
      }
    } catch (e) {
      // Handle MissingPluginException or other errors
      debugPrint("Error checking connectivity: $e");
      // If plugin is not available, try direct internet check
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e2) {
        debugPrint("Direct internet check also failed: $e2");
        // Default to true to avoid blocking the app if plugin is not available
        return true;
      }
    }
  }

  /// Get current connectivity status (returns the first available connection type)
  static Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      // Return the first non-none result, or none if empty
      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        return ConnectivityResult.none;
      }

      // Return the first available connection type
      return connectivityResults.first;
    } catch (e) {
      debugPrint("Error getting connectivity status: $e");
      // If plugin not available, try to check internet directly
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 2));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return ConnectivityResult
              .wifi; // Assume wifi if we can reach internet
        }
      } catch (e2) {
        debugPrint("Direct check failed: $e2");
      }
      return ConnectivityResult.none;
    }
  }

  /// Get all current connectivity statuses
  static Future<List<ConnectivityResult>> getConnectivityStatuses() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint("Error getting connectivity statuses: $e");
      return [ConnectivityResult.none];
    }
  }

  /// Listen to connectivity changes
  static Stream<List<ConnectivityResult>> get connectivityStream {
    try {
      return _connectivity.onConnectivityChanged;
    } catch (e) {
      debugPrint("Error getting connectivity stream: $e");
      // Return a stream that emits empty list if plugin not available
      return Stream.value([ConnectivityResult.none]);
    }
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    if (error is SocketException) return true;
    if (error is http.ClientException) return true;
    if (error.toString().contains('SocketException')) return true;
    if (error.toString().contains('Network is unreachable')) return true;
    if (error.toString().contains('Failed host lookup')) return true;
    if (error.toString().contains('Connection refused')) return true;
    if (error.toString().contains('Connection timed out')) return true;
    if (error.toString().contains('No Internet connection')) return true;
    return false;
  }

  /// Get user-friendly error message from network error
  static String getNetworkErrorMessage(dynamic error) {
    // Handle SocketException
    if (error is SocketException) {
      final message = error.message.toLowerCase();

      if (message.contains('failed host lookup') ||
          message.contains('network is unreachable') ||
          message.contains('no address associated with hostname')) {
        return 'No internet connection. Please check your network and try again.';
      }

      if (message.contains('connection refused')) {
        return 'Unable to connect to server. Please try again later.';
      }

      if (message.contains('connection timed out') ||
          message.contains('timed out')) {
        return 'Connection timeout. Please check your internet and try again.';
      }

      return 'Network connection error. Please check your internet and try again.';
    }

    // Handle HTTP ClientException
    if (error is http.ClientException) {
      return 'Network error. Please check your internet connection and try again.';
    }

    // Handle string-based errors
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no internet connection') ||
        errorString.contains('no address associated')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (errorString.contains('connection refused')) {
      return 'Unable to connect to server. Please try again later.';
    }

    if (errorString.contains('connection timed out') ||
        errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'Connection timeout. Please check your internet and try again.';
    }

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    return 'Unable to connect. Please check your internet and try again.';
  }

  /// Handle network error with retry logic
  static Future<T?> handleNetworkCall<T>({
    required Future<T> Function() networkCall,
    String? customErrorMessage,
    int maxRetries = 0,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;

    while (attempts <= maxRetries) {
      try {
        // Check connectivity before making the call
        if (!await hasInternetConnection()) {
          throw SocketException('No internet connection');
        }

        return await networkCall();
      } catch (e) {
        attempts++;

        if (isNetworkError(e)) {
          if (attempts > maxRetries) {
            throw Exception(
              customErrorMessage ?? getNetworkErrorMessage(e),
            );
          }
          // Wait before retrying
          await Future.delayed(retryDelay);
        } else {
          // Non-network error, throw immediately
          rethrow;
        }
      }
    }

    throw Exception(customErrorMessage ?? 'Network error occurred');
  }
}
