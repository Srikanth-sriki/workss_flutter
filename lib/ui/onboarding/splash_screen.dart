// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:works_app/components/colors.dart';
// // import 'package:works_app/components/local_constant.dart';
// // import 'package:works_app/components/size_config.dart';
// // import 'package:works_app/global_helper/reuse_widget.dart';
// // import 'package:works_app/ui/onboarding/language_selection.dart';
// // import 'package:works_app/ui/onboarding/phone_number.dart';
// //
// // import '../../bloc/authentication/authentication_bloc.dart';
// // import '../../bloc/login/login_bloc.dart';
// // import '../../main.dart';
// //
// // class SplashScreen extends StatefulWidget {
// //   const SplashScreen({super.key});
// //
// //   @override
// //   State<SplashScreen> createState() => _SplashScreenState();
// // }
// //
// // class _SplashScreenState extends State<SplashScreen>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _controller;
// //   late Animation<double> _scaleAnimation;
// //   late Animation<double> _opacityAnimation;
// //   late LoginBloc loginBloc;
// //
// //
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeAnimations();
// //     _initializeApp();
// //     loginBloc = BlocProvider.of<LoginBloc>(context);
// //   }
// //
// //
// //   void _initializeAnimations() {
// //     _controller = AnimationController(
// //       vsync: this,
// //       duration: const Duration(seconds: 5),
// //     );
// //     _scaleAnimation = Tween<double>(begin: 0.4, end: 1.2).animate(
// //       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
// //     );
// //     _opacityAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
// //       CurvedAnimation(parent: _controller, curve: Curves.easeIn),
// //     );
// //     _controller.forward();
// //     Timer(const Duration(seconds: 7), () {
// //       _controller.stop();
// //     });
// //   }
// //
// //
// //   Future<void> _initializeApp() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     bool? newUser = prefs.getBool(LocalConstant.initialLanguage);
// //     await Future.delayed(const Duration(seconds: 7));
// //     if (newUser == true) {
// //       Navigator.of(context).pushReplacement(
// //         MaterialPageRoute(
// //           builder: (BuildContext context) => BlocProvider(
// //             create: (context) => AuthenticationBloc()..add(const InitializeApp()),
// //             child: const Authentication(),
// //           ),
// //         ),
// //       );
// //     } else {
// //       Navigator.of(context).pushReplacement(
// //         MaterialPageRoute(
// //           builder: (BuildContext context) => const LanguageSelectionScreen(routeType: 'intro'),
// //         ),
// //       );
// //     }
// //   }
// //
// //
// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     SizeConfig().init(context);
// //     return Scaffold(
// //       backgroundColor: COLORS.white,
// //       appBar: AppBar(
// //         systemOverlayStyle: customSystemOverlayStyle(
// //           statusBarColor: COLORS.primary,
// //         ),
// //         toolbarHeight: 0,
// //         backgroundColor: COLORS.white,
// //       ),
// //       body: SafeArea(
// //         child: Container(
// //           height: SizeConfig.screenHeight,
// //           width: SizeConfig.screenWidth,
// //           color: COLORS.primary,
// //           child: Center(
// //             child: AnimatedBuilder(
// //               animation: _controller,
// //               builder: (context, child) {
// //                 return Transform.scale(
// //                   scale: _scaleAnimation.value,
// //                   child: Opacity(
// //                       opacity: _opacityAnimation.value,
// //                       child: child),
// //                 );
// //               },
// //               child: Text(
// //                 'Workss',
// //                 style: TextStyle(
// //                   fontFamily: "Poppins",
// //                   fontSize: SizeConfig.blockWidth * 7,
// //                   fontWeight: FontWeight.w700,
// //                   color: COLORS.white,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
// import 'dart:async';
// import 'dart:io'; // For platform check
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../bloc/authentication/authentication_bloc.dart';
// import '../../bloc/login/login_bloc.dart';
// import '../../components/colors.dart';
// import '../../components/local_constant.dart';
// import '../../components/size_config.dart';
// import '../../global_helper/reuse_widget.dart';
// import '../../main.dart';
// import '../../models/app_version_modal.dart';
// import '../onboarding/language_selection.dart';
// import '../onboarding/phone_number.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _opacityAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _startBlocFlow();
//   }
//
//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 5),
//     );
//     _scaleAnimation = Tween<double>(begin: 0.4, end: 1.2).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//     _opacityAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeIn),
//     );
//     _controller.forward();
//     Timer(const Duration(seconds: 7), () {
//       _controller.stop();
//     });
//   }
//
//   void _startBlocFlow() {
//     context.read<LoginBloc>().add(AppVersionCheck());
//   }
//
//   void _handleVersionLogic(List<AppVersion> versions) async {
//     final platformType = Platform.isAndroid ? "android" : "ios";
//     final platformVersion = versions.firstWhere(
//           (item) => item.type?.toLowerCase() == platformType,
//       orElse: () => AppVersion(),
//     );
//
//     await Future.delayed(const Duration(seconds: 7));
//     _initializeApp();
//
//     // if (platformVersion.forceUpdate == true) {
//     //   Navigator.pushReplacementNamed(context, '/maintenance');
//     // } else if (platformVersion.maintainanceMode == true) {
//     //   Navigator.pushReplacementNamed(context, '/maintenance');
//     // } else {
//     //   _initializeApp();
//     // }
//   }
//
//
//     Future<void> _initializeApp() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? newUser = prefs.getBool(LocalConstant.initialLanguage);
//
//     if (newUser == true) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (BuildContext context) => BlocProvider(
//             create: (context) => AuthenticationBloc()..add(const InitializeApp()),
//             child: const Authentication(),
//           ),
//         ),
//       );
//     } else {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (BuildContext context) => const LanguageSelectionScreen(routeType: 'intro'),
//         ),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return Scaffold(
//       backgroundColor: COLORS.primary,
//       appBar: AppBar(
//         systemOverlayStyle: customSystemOverlayStyle(
//           statusBarColor: COLORS.primary,
//         ),
//         toolbarHeight: 0,
//         backgroundColor: COLORS.primary,
//       ),
//       body: BlocListener<LoginBloc, LoginState>(
//         listener: (context, state) {
//           if (state is AppVersionSuccess) {
//             _handleVersionLogic(state.appVersion);
//           }
//         },
//         child: SafeArea(
//           child: Container(
//             height: SizeConfig.screenHeight,
//             width: SizeConfig.screenWidth,
//             color: COLORS.primary,
//             child: Center(
//               child: AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   return Transform.scale(
//                     scale: _scaleAnimation.value,
//                     child: Opacity(
//                         opacity: _opacityAnimation.value, child: child),
//                   );
//                 },
//                 child: Text(
//                   'Workss',
//                   style: TextStyle(
//                     fontFamily: "Poppins",
//                     fontSize: SizeConfig.blockWidth * 7,
//                     fontWeight: FontWeight.w700,
//                     color: COLORS.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//

import 'dart:async';
import 'dart:io'; // For platform check
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/authentication/authentication_bloc.dart';
import '../../bloc/login/login_bloc.dart';
import '../../components/colors.dart';
import '../../components/local_constant.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../../helper/network_helper.dart';
import '../../main.dart';
import '../../models/app_version_modal.dart';
import '../onboarding/language_selection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription? _networkSubscription;
  bool _isWaitingForNetwork = false;
  bool _hasHandledVersion = false;

  @override
  void initState() {
    super.initState();
    _startBlocFlow();
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }

  void _startBlocFlow() {
    context.read<LoginBloc>().add(AppVersionCheck());
  }

  /// Listen for network restoration and retry API call
  void _setupNetworkRetry() {
    if (_isWaitingForNetwork) return; // Already listening

    _isWaitingForNetwork = true;
    _networkSubscription?.cancel();

    _networkSubscription = NetworkHelper.connectivityStream.listen(
      (connectivityResults) async {
        // Debounce: Wait a bit before checking
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if we actually have internet
        final hasInternet = await NetworkHelper.hasInternetConnection();

        if (hasInternet &&
            _isWaitingForNetwork &&
            mounted &&
            !_hasHandledVersion) {
          debugPrint("Network restored, retrying AppVersionCheck...");
          _isWaitingForNetwork = false;
          // Retry the API call
          context.read<LoginBloc>().add(AppVersionCheck());
        }
      },
      onError: (error) {
        debugPrint("Network stream error in splash: $error");
      },
    );
  }

  void _handleVersionLogic(List<AppVersion> versions) async {
    final platformType = Platform.isAndroid ? "android" : "ios";
    final platformVersion = versions.firstWhere(
      (item) => item.type?.toLowerCase() == platformType,
      orElse: () => AppVersion(),
    );

    // keep the same delay logic as before
    await Future.delayed(const Duration(seconds: 4));
    // _initializeApp();

    if (platformVersion.forceUpdate == true) {
      Navigator.pushReplacementNamed(context, '/force-update');
    } else if (platformVersion.maintainanceMode == true) {
      Navigator.pushReplacementNamed(context, '/maintenance');
    } else {
      _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? newUser = prefs.getBool(LocalConstant.initialLanguage);

    if (newUser == true) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) =>
                AuthenticationBloc()..add(const InitializeApp()),
            child: const Authentication(),
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              const LanguageSelectionScreen(routeType: 'intro'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: COLORS.primary,
      appBar: AppBar(
        systemOverlayStyle: customSystemOverlayStyle(
          statusBarColor: COLORS.primary,
        ),
        toolbarHeight: 0,
        backgroundColor: COLORS.primary,
      ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is AppVersionSuccess) {
            // Mark as handled to prevent multiple calls
            if (!_hasHandledVersion) {
              _hasHandledVersion = true;
              _networkSubscription?.cancel();
              _handleVersionLogic(state.appVersion);
            }
          } else if (state is AppVersionFailed) {
            // Check if it's a network error
            final isNetworkError =
                NetworkHelper.isNetworkError(state.message) ||
                    state.message.toLowerCase().contains('internet') ||
                    state.message.toLowerCase().contains('network') ||
                    state.message.toLowerCase().contains('connection');

            if (isNetworkError && !_hasHandledVersion) {
              debugPrint(
                  "Network error detected in splash, waiting for connection...");
              // Set up listener to retry when network is restored
              _setupNetworkRetry();
              // Don't navigate away - wait for network to be restored
            } else if (!_hasHandledVersion) {
              // Non-network error - proceed after delay
              Future.delayed(const Duration(seconds: 4), () {
                if (mounted && !_hasHandledVersion) {
                  _hasHandledVersion = true;
                  _initializeApp();
                }
              });
            }
          }
        },
        child: SafeArea(
          child: Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            color: COLORS.primary,
            child: Center(
                // No AnimatedBuilder anymore — just static text
                child: Image.asset(
              'assets/images/home/works_logo.png',
              width: SizeConfig.blockWidth * 35,
              height: SizeConfig.blockWidth * 35,
              fit: BoxFit.contain,
            )
                // Text(
                //   'Workss',
                //   style: TextStyle(
                //     fontFamily: "Poppins",
                //     fontSize: SizeConfig.blockWidth * 7,
                //     fontWeight: FontWeight.w700,
                //     color: COLORS.white,
                //   ),
                // ),
                ),
          ),
        ),
      ),
    );
  }
}
