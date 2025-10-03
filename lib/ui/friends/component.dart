import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/image_preview_modal.dart';

import '../../global_helper/reuse_widget.dart';

Widget friendSearchCards(
    {required String image,
    required String name,
    required VoidCallback onTapCard,
    required VoidCallback onTapMessage,
      required BuildContext context,
      required String itemID,
    required VoidCallback onTapIcon}) {
  //final tag = 'avatarTag_$image';
  final tag = 'fri_${itemID}';
  return InkWell(
    onTap: onTapCard,
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight * 0.8,
      ),
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 4,vertical: SizeConfig.blockWidth * 3),
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
              InkWell(
                onTap: () => showModernImagePreview(context,image,heroTag: tag),
                splashColor: COLORS.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 14 / 2),
                child: Hero(
                  tag: tag,
                  child: Container(
                    width: SizeConfig.blockWidth * 15,
                    height: SizeConfig.blockWidth * 15,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(SizeConfig.blockWidth * 7.5))),
                  ),
                ),
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
  bool sendMessageButtonRequired = false,
  Widget? widgetButton,
  bool widgetButtonRequired = false,
  bool isGroup = false,
  required String itemID,
  required BuildContext context,
}) {
  //final tag = 'avatarTag_$image';
  final tag = 'friDel_${itemID}';
  return InkWell(
    onTap: onTapCard,
    splashColor: COLORS.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
    child: Container(
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
              if(image.isNotEmpty)...[
                InkWell(
                  onTap: (){
                    showModernImagePreview(context, image, heroTag: tag);
                  },
                  splashColor: COLORS.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 14 / 2),
                  child: Container(
                    width: SizeConfig.blockWidth * 14,
                    height: SizeConfig.blockWidth * 14,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(SizeConfig.blockWidth * 7))),
                  ),
                )
              ]
              else...[
                Container(
                  width: SizeConfig.blockWidth * 15,
                  height: SizeConfig.blockWidth * 15,
                  decoration: BoxDecoration(
                    color: COLORS.neutralDarkTwo,
                    borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 7.5),
                  ),
                  child: Icon(
                    isGroup ? Icons.people : Icons.person,
                    color: COLORS.neutralDark,
                    size: SizeConfig.blockWidth * 7,
                  ),
                ),
              ],
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
                    if(disc.isNotEmpty)
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
                height: SizeConfig.blockHeight * 6,
                backgroundColor: added ? COLORS.neutralDarkTwo : COLORS.primary,
                textColor: added ? COLORS.neutralDark : COLORS.white,
                textFontSize: 3.2,
                verticalSpaceButton: 1.5,
                showIcon: false)
          ],
          if(widgetButtonRequired)...[
            widgetButton!
          ],
          if (sendMessageButtonRequired) ...[
          SizedBox(
            width: SizeConfig.blockWidth * buttonWidth,
            height: SizeConfig.blockHeight * 5.6,
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
                    // vertical: SizeConfig.blockHeight,
                    horizontal: SizeConfig.blockWidth * 4,
                  ),
                  child: Text(
                    'Message'.tr(),
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 3.2,
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
  required VoidCallback onTapButton,
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
                            SizeConfig.blockWidth * 6))),
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
                    if(disc.isNotEmpty)
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
              onPressed: onTapButton,
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
