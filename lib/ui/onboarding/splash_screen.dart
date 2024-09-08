import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/onboarding/language_selection.dart';
import 'package:works_app/ui/onboarding/phone_number.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // _controller.repeat(reverse: true);
    _controller.forward();

    Timer(const Duration(seconds: 7), () {
      _controller.stop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => const LanguageSelectionScreen(routeType: 'intro',),
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        systemOverlayStyle: customSystemOverlayStyle(
          statusBarColor: COLORS.primary,
        ),
        toolbarHeight: 0,
        backgroundColor: COLORS.white,
      ),
      body: SafeArea(
        child: Container(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          color: COLORS.primary,
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: child),
                );
              },
              child: Text(
                'Workss',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: SizeConfig.blockWidth * 7,
                  fontWeight: FontWeight.w700,
                  color: COLORS.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
