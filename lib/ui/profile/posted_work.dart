import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/profile/component.dart';
import 'package:works_app/ui/profile/view_insights.dart';

import '../../components/colors.dart';
import '../../global_helper/reuse_widget.dart';
import '../home/component.dart';

class PostedWorkList extends StatefulWidget {
  const PostedWorkList({super.key});

  @override
  State<PostedWorkList> createState() => _PostedWorkListState();
}

class _PostedWorkListState extends State<PostedWorkList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Posted Works',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: SizeConfig.blockWidth * 4,
              horizontal: SizeConfig.blockHeight * 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WorkCard(
                title: 'UI/UX Designer',
                location: 'Siddhartha Layout, Mysuru ',
                timeAgo: '2d ago',
                jobType: 'Home',
                experience: 'Freshers',
                experienceImage: 'assets/images/home/work.png',
                gender: 'Male',
                genderImage: 'assets/images/home/gender.png',
                jobTypeImage: 'assets/images/home/home.png',
                language: 'Kannada, Hindi, English',
                languageImage: 'assets/images/home/speak.png',
                onShowInterest: () {},
                onCardClick: (){},
                actionRows: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    customIconButton(
                      text: 'VIEW INSIGHTS',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ViewInsightsScreen()),
                        );
                      },
                      backgroundColor: COLORS.primary,
                      showIcon: false,
                      height: SizeConfig.blockHeight * 6.5,
                      textColor: COLORS.white,
                      width: SizeConfig.blockWidth * 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconActionCard(
                          iconBool: false,
                          imageUrl: Image.asset(
                            'assets/images/home/phone.png',
                            width: SizeConfig.blockWidth * 4.25,
                            height: SizeConfig.blockHeight * 4.25,
                            fit: BoxFit.contain,
                          ),
                        ),
                        IconActionCard(
                          iconBool: false,
                          imageUrl: Image.asset(
                            'assets/images/home/share.png',
                            width: SizeConfig.blockWidth * 5.2,
                            height: SizeConfig.blockHeight * 5.2,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // actionRows: Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     customButton(
                //       width: SizeConfig.blockWidth*45,
                //         text: 'VIEW INSIGHTS',
                //         onPressed: () {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //                 builder: (BuildContext context) =>  ViewInsightsScreen()
                //             ),
                //           );
                //         },
                //         backgroundColor: COLORS.primary,
                //        showIcon: false,
                //
                //         height: SizeConfig.blockHeight * 8,
                //         textColor: COLORS.white,
                //     ),
                //     const Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         IconAction(icon: Icons.edit,),
                //         IconAction(icon: Icons.delete_rounded,changeColor: true,bgColor: COLORS.accent),
                //       ],
                //     )
                //   ],
                // ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
