import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:works_app/components/local_constant.dart';
import 'package:works_app/ui/onboarding/phone_number.dart';
import '../../bloc/login/login_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  _IntroSliderScreenState createState() => _IntroSliderScreenState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        systemOverlayStyle: customSystemOverlayStyle(
          statusBarColor: COLORS.white,
        ),
        toolbarHeight: 0,
        backgroundColor: COLORS.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                buildPage(
                  image: 'assets/images/login/intro1.png',
                  title: 'intro_header1'.tr(),
                  description: 'intro_sub1'.tr(),
                ),
                buildPage(
                  image: 'assets/images/login/intro2.png',
                  title: 'intro_header2'.tr(),
                  description: 'intro_sub2'.tr(),
                ),
                buildPage(
                  image: 'assets/images/login/intro3.png',
                  title: 'intro_header3'.tr(),
                  description: 'intro_sub3'.tr(),
                  isLastPage: true,
                ),
              ],
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: _currentIndex != 2
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_currentIndex != 2) ...[
                    TextButton(
                      onPressed: () {
                        _pageController.jumpToPage(2);
                      },
                      child: Row(
                        children: [
                          Text(
                            'skip'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDark,
                              fontSize: SizeConfig.blockWidth * 4.25,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                          ),
                          Icon(
                            Icons.keyboard_double_arrow_right_outlined,
                            color: COLORS.primaryOne,
                            size: SizeConfig.blockWidth * 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                  customButton(
                    text: _currentIndex == 2 ? 'Login'.tr() : 'Next'.tr(),
                    onPressed: () async{
                      if (_currentIndex == 2) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setBool(LocalConstant.intoChecked, true);
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => BlocProvider(
                            create: (context) => LoginBloc(),
                            child: const LoginScreen(),
                          ),
                        ));
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    backgroundColor: COLORS.primary,
                    prefixIconBool: true,
                    width: SizeConfig.blockWidth * 32,
                    height: SizeConfig.blockHeight * 7.5,
                    textColor: COLORS.white,
                    prefixIcon: Icons.arrow_forward_outlined,
                    showIcon: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String description,
    bool isLastPage = false,
  }) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double scale = 1.0;
        double opacity = 1.0;
        Offset offset = Offset(0, 0);

        if (_pageController.position.haveDimensions) {
          double pageDifference = (_pageController.page! - _currentIndex).abs();
          scale = pageDifference < 1.0 ? 1.0 - pageDifference * 0.5 : 0.8;
          opacity = pageDifference < 1 ? 1.0 - pageDifference : 0.0;
          offset = Offset(0, 6 * pageDifference);
        }

        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 8,
              vertical: SizeConfig.blockHeight * 8),
          color: COLORS.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: Image.asset(
                  image,
                  height: SizeConfig.blockWidth * 100,
                  width: SizeConfig.blockWidth * 100,
                  fit: BoxFit.contain,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => buildDot(index, context),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 4),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: opacity,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 500),
                  offset: offset,
                  curve: Curves.easeOut,
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: COLORS.primaryTwo,
                          fontSize: SizeConfig.blockWidth * 4.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: SizeConfig.blockHeight * 1),
                      Text(
                        description,
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.6,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _currentIndex == index
          ? SizeConfig.blockWidth * 2.5
          : SizeConfig.blockWidth * 2,
      width: _currentIndex == index
          ? SizeConfig.blockWidth * 2.5
          : SizeConfig.blockWidth * 2,
      margin: EdgeInsets.only(right: SizeConfig.blockWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _currentIndex == index ? COLORS.primary : COLORS.primaryOne,
      ),
    );
  }
}
