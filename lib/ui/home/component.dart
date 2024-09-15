import 'package:flutter/material.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

class WorkCard extends StatelessWidget {
  final String title;
  final String location;
  final String timeAgo;
  final String jobType;
  final String experience;
  final String language;
  final String gender;
  final VoidCallback onShowInterest;
  final String jobTypeImage;
  final String experienceImage;
  final String languageImage;
  final String genderImage;

  const WorkCard(
      {super.key,
      required this.title,
      required this.location,
      required this.timeAgo,
      required this.jobType,
      required this.experience,
      required this.onShowInterest,
      required this.jobTypeImage,
      required this.experienceImage,
      required this.gender,
      required this.genderImage,
      required this.language,
      required this.languageImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.blockWidth * 100,
      margin: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 2),
      padding: EdgeInsets.all(SizeConfig.blockWidth * 3.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
        color: COLORS.primaryOne.withOpacity(0.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 4.2,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                ),
              ),
              Container(
                padding: EdgeInsets.all(SizeConfig.blockWidth * 1.5),
                decoration: BoxDecoration(
                  color: COLORS.primaryOne,
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 1.5),
                ),
                child: Text(
                  timeAgo,
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 3.2,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: COLORS.accent,
                size: SizeConfig.blockWidth * 5.5,
              ),
              SizedBox(width: SizeConfig.blockWidth * 1.5),
              Text(
                location,
                style: TextStyle(
                  color: COLORS.neutralDarkOne,
                  fontSize: SizeConfig.blockWidth * 3.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          ),
          SizedBox(
            height: SizeConfig.blockHeight*0.5,
          ),
          registerText(text: jobType, image: jobTypeImage),
          registerText(text: experience, image: experienceImage),
          registerText(text: language, image: languageImage),
          registerText(text: gender, image: genderImage),
          SizedBox(
            height: SizeConfig.blockHeight,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              customIconButton(
                  text: 'SHOW INTEREST',
                  onPressed: () {},
                  backgroundColor: COLORS.primary,
                  showIcon: true,
                  width: SizeConfig.blockWidth * 55,
                  height: SizeConfig.blockHeight * 6.5,
                  textColor: COLORS.white,
                  icon: Icons.thumb_up_alt_outlined),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconAction(icon: Icons.phone_rounded),
                  IconAction(icon: Icons.share),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class IconAction extends StatelessWidget {
  final IconData icon;

  const IconAction({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: SizeConfig.blockWidth * 2),
      padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.5),
        color: COLORS.primaryOne.withOpacity(0.3),
      ),
      child: Icon(
        icon,
        size: SizeConfig.blockWidth * 5.5,
      ),
    );
  }
}

Widget registerText({required String text, required String image}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight * 0.5,
        horizontal: SizeConfig.blockWidth),
    child: Row(
      children: [
        Image.asset(
          image,
          width: SizeConfig.blockWidth * 4.5,
          height: SizeConfig.blockWidth * 4.5,
        ),
        SizedBox(width: SizeConfig.blockWidth * 2),
        Text(
          text,
          style: TextStyle(
            color: COLORS.neutralDarkOne,
            fontSize: SizeConfig.blockWidth * 3.6,
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
          ),
        ),
      ],
    ),
  );
}