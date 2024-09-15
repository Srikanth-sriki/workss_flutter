import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/colors.dart';

import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import 'component.dart';

class ViewInsightsScreen extends StatefulWidget {
  const ViewInsightsScreen({super.key});

  @override
  State<ViewInsightsScreen> createState() => _ViewInsightsScreenState();
}

class _ViewInsightsScreenState extends State<ViewInsightsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: COLORS.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopCard(),
            SizedBox(height: SizeConfig.blockHeight * 4),
            _buildStatistics(),
            SizedBox(height: SizeConfig.blockHeight * 4),
            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 4.5),
              child: Text(
                'Interested Professionals'.tr(),
                style: TextStyle(
                  color: COLORS.neutralDarkOne,
                  fontSize: SizeConfig.blockWidth * 3.8,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
            ),
            _buildProfessionalList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
      decoration: BoxDecoration(
        color: COLORS.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(SizeConfig.blockWidth * 6),
          bottomRight: Radius.circular(SizeConfig.blockWidth * 6),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(SizeConfig.blockWidth * 2.5),
                    margin: EdgeInsets.only(right: SizeConfig.blockWidth * 3),
                    decoration: BoxDecoration(
                      color: COLORS.primaryOne.withOpacity(0.6),
                      borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 1.5),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_sharp,
                      color: COLORS.white,
                      size: SizeConfig.blockWidth * 4,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Swimming Coach",
                      style: TextStyle(
                        color: COLORS.white,
                        fontSize: SizeConfig.blockWidth * 4,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: COLORS.accent,
                          size: SizeConfig.blockWidth * 4,
                        ),
                        SizedBox(width: SizeConfig.blockWidth * 1.5),
                        Text(
                          'Siddhartha Layout, Mysuru',
                          style: TextStyle(
                            color: COLORS.primaryOne,
                            fontSize: SizeConfig.blockWidth * 3.3,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.more_vert,
              color: COLORS.white,
              size: SizeConfig.blockHeight * 4,
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 11,
              vertical: SizeConfig.blockHeight * 0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              registerTextCard(
                  text: "jobType",
                  image: "assets/images/home/home.png",
                  color: COLORS.white,
                  textColor: COLORS.primaryOne,
                  imageSize: 3.6,
                  textFontSize: 3.3),
              registerTextCard(
                  text: "experience",
                  image: "assets/images/home/work.png",
                  color: COLORS.white,
                  textColor: COLORS.primaryOne,
                  imageSize: 3.6,
                  textFontSize: 3.3),
              registerTextCard(
                  text: "language",
                  image: "assets/images/home/speak.png",
                  color: COLORS.white,
                  textColor: COLORS.primaryOne,
                  imageSize: 3.6,
                  textFontSize: 3.3),
              registerTextCard(
                  text: "gender",
                  image: "assets/images/home/gender.png",
                  color: COLORS.white,
                  textColor: COLORS.primaryOne,
                  imageSize: 3.6,
                  textFontSize: 3.3),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 4.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatBox('Interested Professional', '25', COLORS.primary!),
          _buildStatBox('Work Post Viewed by', '255', COLORS.accent!),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color bgColor) {
    return Container(
      width: SizeConfig.blockWidth * 42,
      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr(),
            style: TextStyle(
              color: COLORS.neutralDark,
              fontSize: SizeConfig.blockWidth * 3.8,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 3),
          Text(
            value,
            style: TextStyle(
              color: bgColor,
              fontSize: SizeConfig.blockWidth * 6.5,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 0.5),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 2.5,
                vertical: SizeConfig.blockHeight * 1),
            decoration: BoxDecoration(
                color: bgColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 4)),
            child: Text(
              'From 30 Days'.tr(),
              style: TextStyle(
                color: bgColor,
                fontSize: SizeConfig.blockWidth * 3,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfessionalList() {
    return Padding(
      padding:  EdgeInsets.all(SizeConfig.blockWidth*4.5),
      child: Column(
        children: [
          buildProfessionalCard(
            name: 'Gilbert Hermann',
            profession: 'Swimming Coach',
            location: 'Siddhartha Layout, Mysuru',
            languages: 'Kannada, Hindi, English',
            gender: 'Male',
            price: '₹ 50,000',
            paymentType: 'Per Project',
            contacted: true,
            experience: 'Freshers',
            experienceImage: 'assets/images/home/work.png',
            genderImage: 'assets/images/home/gender.png',
            jobTypeImage: 'assets/images/profile/prof.png',
            language: 'Kannada, Hindi, English',
            languageImage: 'assets/images/home/speak.png',
            onShowInterest: () {},
            jobType: 'Swimming Coach',
          ),
          SizedBox(height: SizeConfig.blockHeight * 2.5),
        ],
      ),
    );
  }
}


