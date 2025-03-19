import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';

import '../../global_helper/reuse_widget.dart';

Widget friendSearchCards(
    {required String image,
    required String name,
    required VoidCallback onTapCard,
    required VoidCallback onTapMessage,
    required VoidCallback onTapIcon}) {
  return InkWell(
    onTap: onTapCard,
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight * 1,
      ),
      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
        color: COLORS.primaryOne.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: SizeConfig.blockWidth * 15,
                height: SizeConfig.blockWidth * 15,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(SizeConfig.blockWidth * 3))),
              ),
              SizedBox(width: SizeConfig.blockWidth * 2),
              SizedBox(
                width: SizeConfig.blockWidth * 40,
                child: Text(
                  name,
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 3.25,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: onTapMessage,
                  child: Image.asset(
                    'assets/images/friends/message.png',
                    width: SizeConfig.blockWidth * 6,
                    height: SizeConfig.blockWidth * 6,
                  ),
                ),
                SizedBox(width: SizeConfig.blockWidth * 4),
                InkWell(
                  onTap: onTapIcon,
                  child: Icon(Icons.more_vert,
                      color: COLORS.neutralDark,
                      size: SizeConfig.blockWidth * 6),
                )
              ])
        ],
      ),
    ),
  );
}

Widget friendSearchDetailsCards({
  required String image,
  required String name,
  required bool added,
  required VoidCallback onTapCard,
  required String disc,
  String buttonText1 = 'Request Sent',
  String buttonText2 = 'Add Friend',
  bool bgFriend = true,
  bool buttonRequired = true,
  double width = 30,
  double buttonWidth = 32,
  required VoidCallback onTapButtonCard,
  bool sendMessageButtonRequired = false
}) {
  return InkWell(
    onTap: onTapCard,
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight * 1,
      ),
      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
        color: bgFriend ? COLORS.primaryOne.withOpacity(0.1) : COLORS.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: SizeConfig.blockWidth * 12,
                height: SizeConfig.blockWidth * 12,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(SizeConfig.blockWidth * 2.5))),
              ),
              SizedBox(width: SizeConfig.blockWidth * 2),
              SizedBox(
                width: SizeConfig.blockWidth * width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 3.5,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // textAlign: TextAlign.end,
                    ),
                    Text(
                      disc,
                      style: TextStyle(
                        color: COLORS.neutralDarkOne,
                        fontSize: SizeConfig.blockWidth * 3,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (buttonRequired) ...[
            customIconButton(
                text: added ? buttonText1 : buttonText2,
                onPressed: onTapButtonCard,
                width: SizeConfig.blockWidth * buttonWidth,
                height: SizeConfig.blockHeight * 6.25,
                backgroundColor: added ? COLORS.neutralDarkTwo : COLORS.primary,
                textColor: added ? COLORS.neutralDark : COLORS.white,
                showIcon: false)
          ],
          if (sendMessageButtonRequired) ...[
          SizedBox(
            width: SizeConfig.blockWidth * buttonWidth,
            height: SizeConfig.blockHeight * 6.25,
            child: TouchRippleEffect(
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
              rippleColor: Colors.white60,
              child: InkWell(
                onTap: onTapButtonCard,
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
                child: Container(
                  width: SizeConfig.blockWidth * buttonWidth,

                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: COLORS.white,
                      borderRadius:
                          BorderRadius.circular(SizeConfig.blockWidth * 2),
                      border: Border.all(
                          color: COLORS.neutralDark,
                          width: SizeConfig.blockWidth * 0.3)),
                  padding: EdgeInsets.symmetric(
                    // vertical: SizeConfig.blockHeight*2,
                    horizontal: SizeConfig.blockWidth * 4,
                  ),
                  child: Text(
                    'Messaage'.tr(),
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 3.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ),
            ),
          )
          ]
        ],
      ),
    ),
  );
}

Widget friendChatRemoveSearchDetailsCards({
  required String image,
  required String name,
  required VoidCallback onTapCard,
  required String disc,
  required double? width
}) {
  return InkWell(
    onTap: onTapCard,
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight * 1,
      ),
      padding: EdgeInsets.only(
          top: SizeConfig.blockWidth * 3,
          bottom: SizeConfig.blockWidth * 3,
          right: SizeConfig.blockWidth * 2,
          left: SizeConfig.blockWidth * 2),
      color: COLORS.white,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: SizeConfig.blockWidth * 12,
                height: SizeConfig.blockWidth * 12,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: COLORS.primary,
                      width: SizeConfig.blockWidth * 0.2,
                    ),
                    image: DecorationImage(
                        image: NetworkImage(
                          image
                              .isEmpty
                              ? 'https://via.placeholder.com/150'
                              : image,
                        ),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.all(
                        Radius.circular(
                            SizeConfig.blockWidth * 2.5))),
              ),
              SizedBox(width: SizeConfig.blockWidth * 2),
              SizedBox(
                width: SizeConfig.blockWidth * 25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 3.5,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // textAlign: TextAlign.end,
                    ),
                    Text(
                      disc,
                      style: TextStyle(
                        color: COLORS.neutralDarkOne,
                        fontSize: SizeConfig.blockWidth * 3,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
          customIconButton(
              text: 'Remove',
              onPressed: onTapCard,
              width: SizeConfig.blockWidth * 25,
              height: SizeConfig.blockHeight * 6.25,
              backgroundColor: COLORS.neutralDarkTwo,
              textColor: COLORS.semantic,
              showIcon: false)
        ],
      ),
    ),
  );
}
