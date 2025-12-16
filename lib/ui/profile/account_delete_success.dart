import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage_service.dart';
import 'package:works_app/main.dart';
import '../../bloc/authentication/authentication_bloc.dart';
import '../../bloc/login/login_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../main_screen/main_screen.dart';
import '../onboarding/splash_screen.dart';

class AccountDeleteSuccess extends StatefulWidget {
  const AccountDeleteSuccess({super.key});

  @override
  State<AccountDeleteSuccess> createState() => _AccountDeleteSuccessState();
}

class _AccountDeleteSuccessState extends State<AccountDeleteSuccess> with SingleTickerProviderStateMixin {
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
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: COLORS.primaryOne.withOpacity(0.2),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: SizeConfig.blockWidth * 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft:
                      Radius.circular(SizeConfig.blockWidth * 7.5),
                      bottomRight:
                      Radius.circular(SizeConfig.blockWidth * 7.5)),
                  color: COLORS.primaryOne.withOpacity(0.2),
                ),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/images/profile/account_delete.png',
                    width: SizeConfig.blockWidth * 100,
                    height: SizeConfig.blockWidth * 100,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 4),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    'Account Successfully Deleted'.tr(),
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 4.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    "Your account has been permanently deleted.\nWe're sorry to see you go.".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.7,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 4.5),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 9),
                child: customButton(
                  text: 'CREATE ACCOUNT'.tr(),
                  onPressed: ()async {
                    await StorageService.clear();
                    if (!context.mounted) return;
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => LoginBloc()..add(AppVersionCheck()),
                          child: const SplashScreen(),
                        ),
                      ),
                          (Route<dynamic> route) => false,
                    );
                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => BlocProvider(
                    //         create: (context) =>
                    //         AuthenticationBloc()..add(const InitializeApp()),
                    //         child: const Authentication()),
                    //   ),
                    //       (Route<dynamic> route) => false,
                    // );
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
