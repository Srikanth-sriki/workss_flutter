import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
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
    return TouchRippleEffect(
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
      rippleColor: Colors.white60,
      child: InkWell(
        onTap: onCardClick,
        splashColor: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
        child: Container(
          width: SizeConfig.blockWidth * 100,
          // margin: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 1.5),
          padding: EdgeInsets.all(SizeConfig.blockWidth * 3.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
            color: COLORS.primaryOne.withOpacity(0.15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: SizeConfig.blockWidth*60,
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 0.5),
                    child: Text(
                      capitalizeEachWord(title),
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 3.5,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 1,
                        vertical: SizeConfig.blockWidth * 0.5),
                    decoration: BoxDecoration(
                      color: COLORS.primaryOne,
                      borderRadius:
                          BorderRadius.circular(SizeConfig.blockWidth * 1),
                    ),
                    child: Text(
                      timeAgo,
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 2.6,
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
                    width: SizeConfig.blockWidth * 66,
                    child: Text(
                      capitalizeFirstLetter(location),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        color: COLORS.neutralDarkOne,
                        fontSize: SizeConfig.blockWidth * 3,
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
              registerText(
                text: jobType,
                image: jobTypeImage,
              ),
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
        Flexible(
          child: Text(
            capitalizeEachWord(text),
            style: TextStyle(
              color: COLORS.neutralDarkOne,
              fontSize: SizeConfig.blockWidth * 3.3,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget addFriendText({required String textOne, required String textTwo,required VoidCallback onTap}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        textOne.tr(),
        style: TextStyle(
          color: COLORS.neutralDarkOne,
          fontSize: SizeConfig.blockWidth * 3.8,
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
        ),
        textAlign: TextAlign.end,
      ),
      InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.2),
        child: Container(
          padding: EdgeInsets.all(SizeConfig.blockWidth * 2.25),
          decoration: BoxDecoration(
              color: COLORS.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2)),
          child: Text(
            textTwo.tr(),
            style: TextStyle(
              color: COLORS.accent,
              fontSize: SizeConfig.blockWidth * 3.2,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ),
    ],
  );
}

Widget addFriendCard({required bool added,required String image,required String name,
  required VoidCallback onTap,required VoidCallback onTapCard
}){
  return InkWell(
    onTap: onTapCard,
    splashColor: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
    child: Container(
      width: SizeConfig.blockWidth * 36,
      margin: EdgeInsets.only(top: SizeConfig.blockHeight * 1,bottom: SizeConfig.blockHeight * 1,right: SizeConfig.blockWidth * 3 ),
      padding: EdgeInsets.all(SizeConfig.blockWidth * 2),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(SizeConfig.blockWidth * 3.5),
        color: COLORS.primaryOne.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          AvatarImage(image: image,size:18 ,),
          // Container(
          //   width: SizeConfig.blockWidth * 18,
          //   height: SizeConfig.blockWidth * 18,
          //   decoration: BoxDecoration(
          //       image: DecorationImage(
          //         image: NetworkImage(image),
          //         fit: BoxFit.fill,
          //       ),
          //       borderRadius: BorderRadius.all(
          //           Radius.circular(SizeConfig.blockWidth * 2.5))),
          // ),

          SizedBox(height: SizeConfig.blockHeight*0.5),
          Text(
            name,
            style: TextStyle(
              color: COLORS.neutralDark,
              fontSize: SizeConfig.blockWidth * 3,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // textAlign: TextAlign.end,
          ),
          SizedBox(height: SizeConfig.blockHeight*2),
          customIconButton(
              text: added?'Request Sent':'Add Friend',
              onPressed: onTap,
              width: SizeConfig.blockWidth*30,
              height: SizeConfig.blockHeight * 5.25,
              backgroundColor: added?COLORS.neutralDarkTwo:COLORS.primary,
              textColor: added?COLORS.neutralDark:COLORS.white,
              textFontSize: 3,
              verticalSpaceButton: 1.25,
              showIcon: false)
        ],
      ),
    ),
  );
}

Widget friendViewCard({required String image,required String name,required VoidCallback onTap}){

  final double size = SizeConfig.blockWidth * 17;
  return InkWell(
    onTap: onTap,
    splashColor: COLORS.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(size / 2),
    child: SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: image,
            child: ClipOval(
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: COLORS.neutralDarkTwo),
                    ),
                    Positioned.fill(
                      child: Image.network(
                        image,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        loadingBuilder: (c, child, p) =>
                        p == null ? child : Container(color: COLORS.neutralDarkTwo),
                        errorBuilder: (c, e, s) =>
                            Container(color: COLORS.neutralDarkTwo),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 0.8),

          SizedBox(
            width: size,
            height: SizeConfig.blockHeight * 4.2,
            child: Text(
              capitalizeEachWord(name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 3,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
