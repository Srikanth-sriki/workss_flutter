import 'dart:io';
import 'package:flutter/material.dart';
import '../helper/network_helper.dart';
import '../components/colors.dart';
import '../components/size_config.dart';

/// Global network connectivity overlay that shows when network is unavailable
class NetworkConnectivityOverlay extends StatefulWidget {
  final Widget child;

  const NetworkConnectivityOverlay({
    super.key,
    required this.child,
  });

  @override
  State<NetworkConnectivityOverlay> createState() =>
      _NetworkConnectivityOverlayState();
}

class _NetworkConnectivityOverlayState
    extends State<NetworkConnectivityOverlay> {
  bool _isConnected = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToConnectivityChanges();
  }

  /// Check initial connection status
  Future<void> _checkInitialConnection() async {
    setState(() => _isChecking = true);

    // Primary check: Use NetworkHelper which has better error handling
    bool hasInternet = false;
    try {
      hasInternet = await NetworkHelper.hasInternetConnection();
      debugPrint("NetworkHelper check result: $hasInternet");
    } catch (e) {
      debugPrint("NetworkHelper check error: $e");
      // If NetworkHelper fails, try direct check as fallback
      try {
        final result = await InternetAddress.lookup('8.8.8.8')
            .timeout(const Duration(seconds: 5));
        hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        debugPrint("Fallback DNS check result: $hasInternet");
      } catch (e2) {
        debugPrint("Fallback DNS check failed: $e2");
        hasInternet = false;
      }
    }

    if (mounted) {
      setState(() {
        _isConnected = hasInternet;
        _isChecking = false;
      });
      debugPrint("Final network status: $_isConnected");
    }
  }

  /// Listen to connectivity changes
  void _listenToConnectivityChanges() {
    try {
      NetworkHelper.connectivityStream.listen(
        (connectivityResults) async {
          try {
            // Debounce: Wait a bit before checking to avoid rapid changes
            await Future.delayed(Duration(milliseconds: 500));

            // Primary check: Use NetworkHelper
            bool hasInternet = false;
            try {
              hasInternet = await NetworkHelper.hasInternetConnection();
            } catch (e) {
              // If NetworkHelper fails, try direct check as fallback
              try {
                final result = await InternetAddress.lookup('8.8.8.8')
                    .timeout(const Duration(seconds: 5));
                hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
              } catch (e2) {
                hasInternet = false;
              }
            }

            debugPrint("Network status changed: $hasInternet");

            if (mounted) {
              setState(() {
                _isConnected = hasInternet;
              });
            }
          } catch (e) {
            debugPrint("Error in connectivity listener: $e");
            // Try direct check
            _checkConnectionDirectly();
          }
        },
        onError: (error) {
          debugPrint("Connectivity stream error: $error");
          // Try direct check on stream error
          _checkConnectionDirectly();
        },
      );
    } catch (e) {
      debugPrint("Error setting up connectivity listener: $e");
      // Set up periodic check if stream fails
      _setupPeriodicCheck();
    }
  }

  /// Check connection directly using NetworkHelper
  Future<void> _checkConnectionDirectly() async {
    try {
      final hasInternet = await NetworkHelper.hasInternetConnection();
      if (mounted) {
        setState(() {
          _isConnected = hasInternet;
        });
      }
    } catch (e) {
      debugPrint("Direct connection check failed: $e");
      // Try fallback DNS check
      try {
        final result = await InternetAddress.lookup('8.8.8.8')
            .timeout(const Duration(seconds: 5));
        final hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        if (mounted) {
          setState(() {
            _isConnected = hasInternet;
          });
        }
      } catch (e2) {
        if (mounted) {
          setState(() {
            _isConnected = false; // Show as disconnected
          });
        }
      }
    }
  }

  /// Set up periodic check if connectivity stream is not available
  void _setupPeriodicCheck() {
    // Check every 5 seconds if stream is not working
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        _checkConnectionDirectly();
        _setupPeriodicCheck(); // Continue checking
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (!_isConnected && !_isChecking)
            Positioned.fill(
              child: _buildNetworkErrorModal(),
            ),
        ],
      ),
    );
  }

  /// Build network error modal
  Widget _buildNetworkErrorModal() {
    return IgnorePointer(
      ignoring: false,
      child: Material(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {}, // Prevent dismissing on background tap
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 5,
              ),
              padding: EdgeInsets.all(SizeConfig.blockWidth * 5),
              decoration: BoxDecoration(
                color: COLORS.white,
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: SizeConfig.blockWidth * 20,
                    height: SizeConfig.blockWidth * 20,
                    decoration: BoxDecoration(
                      color: COLORS.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wifi_off,
                      size: SizeConfig.blockWidth * 10,
                      color: COLORS.accent,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 3),

                  // Title
                  Text(
                    'No Internet Connection',
                    style: TextStyle(
                      fontSize: SizeConfig.blockWidth * 4.5,
                      fontWeight: FontWeight.w600,
                      color: COLORS.neutralDark,
                      fontFamily: "Poppins",
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 1.5),

                  // Message
                  Text(
                    'Please check your internet connection and try again.',
                    style: TextStyle(
                      fontSize: SizeConfig.blockWidth * 3.5,
                      fontWeight: FontWeight.w400,
                      color: COLORS.neutralDarkOne,
                      fontFamily: "Poppins",
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 4),

                  // Retry Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() => _isChecking = true);
                        await Future.delayed(Duration(milliseconds: 500));

                        // Use NetworkHelper as primary check
                        bool hasInternet = false;
                        try {
                          hasInternet = await NetworkHelper.hasInternetConnection();
                        } catch (e) {
                          // If NetworkHelper fails, try direct check as fallback
                          try {
                            final result = await InternetAddress.lookup('8.8.8.8')
                                .timeout(const Duration(seconds: 5));
                            hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
                          } catch (e2) {
                            hasInternet = false;
                          }
                        }

                        if (mounted) {
                          setState(() {
                            _isConnected = hasInternet;
                            _isChecking = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: COLORS.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockHeight * 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            SizeConfig.blockWidth * 2.5,
                          ),
                        ),
                      ),
                      child: _isChecking
                          ? SizedBox(
                              height: SizeConfig.blockWidth * 4,
                              width: SizeConfig.blockWidth * 4,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  COLORS.white,
                                ),
                              ),
                            )
                          : Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: SizeConfig.blockWidth * 3.8,
                                fontWeight: FontWeight.w600,
                                color: COLORS.white,
                                fontFamily: "Poppins",
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
