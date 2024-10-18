import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/main.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/post_work/post_work_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../main_screen/main_screen.dart';

class LoginSuccess extends StatefulWidget {
  const LoginSuccess({super.key});

  @override
  State<LoginSuccess> createState() => _LoginSuccessState();
}

class _LoginSuccessState extends State<LoginSuccess>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: COLORS.white,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig.blockHeight * 6),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: SizeConfig.blockWidth * 80,
                  height: SizeConfig.blockWidth * 80,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SizeConfig.screenWidth * 40),
                    color: COLORS.primaryOne.withOpacity(0.5),
                  ),
                  child: Image.asset(
                    'assets/images/login/login_success.png',
                    width: SizeConfig.blockWidth * 100,
                    height: SizeConfig.blockHeight * 50,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 6),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  'Congratulations!'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 4.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  'Your account has been successfully \nCreated.'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 4,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 4.5),
              const Spacer(),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 5),
                child: customButton(
                  text: 'Explore'.tr(),
                  onPressed: () {
                    Navigator.pushNamed(context, '/main_screen');
                  },
                  backgroundColor: COLORS.primary,
                  showIcon: false,
                  width: SizeConfig.blockWidth * 100,
                  height: SizeConfig.blockHeight * 8,
                  textColor: COLORS.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
