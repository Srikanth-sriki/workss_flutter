import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/show_interested/show_interested_bloc.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/post_work/post_work_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../main_screen/main_screen.dart';
import '../profile/posted_work.dart';
import '../profile/view_insights.dart';

class PostWorkSuccessScreen extends StatefulWidget {
  final String workId;
   const PostWorkSuccessScreen({super.key,required this.workId});

  @override
  State<PostWorkSuccessScreen> createState() => _PostWorkSuccessScreenState();
}

class _PostWorkSuccessScreenState extends State<PostWorkSuccessScreen> with SingleTickerProviderStateMixin{
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
      onWillPop: () async {
        Navigator.pushNamed(context, '/main_screen');
        return true;
      },
      child: Scaffold(
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
                      'assets/images/home/post_success.png',
                      width: SizeConfig.blockWidth * 100,
                      height: SizeConfig.blockHeight * 50,
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 6),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    'Work successfully posted!'.tr(),
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
                    'You can now view insights on who showed \ninterest.'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.8,
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
                    text: 'View Insights'.tr(),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (context) => ProfileBloc()
                                      ..add( FetchPostViewEvent(workId: widget.workId)),
                                  ),
                                  BlocProvider(
                                    create: (context) => ShowInterestedBloc(),
                                  ),
                                ],
                                child: const ViewInsightsScreen(),
                              )));
                    },
                    backgroundColor: COLORS.neutralDarkTwo,
                    showIcon: false,
                    width: SizeConfig.blockWidth * 100,
                    height: SizeConfig.blockHeight * 8,
                    textColor: COLORS.black,
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 2.5),
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 5),
                  child: customButton(
                    text: 'Explore Professionals'.tr(),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (context) => ProfileBloc()
                                      ..add(const FetchPostedEvent()),
                                  ),
                                ],
                                child: const PostedWorkList(),
                              )));
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
      ),
    );
  }
}
