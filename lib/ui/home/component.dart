import 'package:flutter/material.dart';
import 'package:works_app/global_helper/helper_function.dart';
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
  final Widget actionRows;
  final VoidCallback onCardClick;

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
      required this.actionRows,
      required this.onCardClick,
      required this.languageImage});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCardClick,
      child: Container(
        width: SizeConfig.blockWidth * 100,
        // margin: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 1.5),
        padding: EdgeInsets.all(SizeConfig.blockWidth * 3.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
          color: COLORS.primaryOne.withOpacity(0.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*0.5),
                  child: Text(
                    capitalizeEachWord(title),
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 3.7,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 1,
                      vertical: SizeConfig.blockWidth * 0.5),
                  decoration: BoxDecoration(
                    color: COLORS.primaryOne,
                    borderRadius:
                        BorderRadius.circular(SizeConfig.blockWidth * 1.5),
                  ),
                  child: Text(
                    timeAgo,
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 2.8,
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
                  size: SizeConfig.blockWidth * 4,
                ),
                SizedBox(width: SizeConfig.blockWidth * 1.5),
                SizedBox(
                  width: SizeConfig.blockWidth*66,
                  child: Text(
                    capitalizeFirstLetter(location),
                    maxLines: 1,overflow: TextOverflow.ellipsis,softWrap: true,
                    style: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.1,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.blockHeight * 0.5,
            ),
            registerText(text: jobType, image: jobTypeImage,),
            registerText(text: experience, image: experienceImage),
            registerText(text: language, image: languageImage),
            registerText(text: gender, image: genderImage),
            SizedBox(
              height: SizeConfig.blockHeight,
            ),
            actionRows
          ],
        ),
      ),
    );
  }
}

Widget registerText({required String text, required String image}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight * 0.2,
        horizontal: SizeConfig.blockWidth),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          image,
          width: SizeConfig.blockWidth * 3.4,
          height: SizeConfig.blockWidth * 3.4,
        ),
        SizedBox(width: SizeConfig.blockWidth * 2),
        Text(
          capitalizeEachWord(text),
          style: TextStyle(
            color: COLORS.neutralDarkOne,
            fontSize: SizeConfig.blockWidth * 3.4,
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
          ),
        ),
      ],
    ),
  );
}
