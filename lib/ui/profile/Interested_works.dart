import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/profile/component.dart';

import '../../components/colors.dart';
import '../../global_helper/reuse_widget.dart';

class InterestedWorkList extends StatefulWidget {
  const InterestedWorkList({super.key});

  @override
  State<InterestedWorkList> createState() => _InterestedWorkListState();
}

class _InterestedWorkListState extends State<InterestedWorkList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Interested Works',
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
                actionRows: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    customIconButton(
                        text: 'INTERESTED',
                        onPressed: () {},
                        backgroundColor: COLORS.semanticTwo.withOpacity(0.4),
                        showIcon: true,
                        width: SizeConfig.blockWidth * 62,
                        height: SizeConfig.blockHeight * 7.5,
                        textColor: COLORS.white,
                        iconColor: COLORS.semanticTwo,
                        icon: Icons.thumb_up_alt),
                    IconAction(
                      icon: Icons.share,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
