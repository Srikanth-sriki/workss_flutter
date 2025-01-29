import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/chat/addFriends.dart';
import 'package:works_app/ui/chat/component.dart';
import 'package:works_app/ui/chat/modal/editGroupDescripation.dart';
import 'package:works_app/ui/chat/modal/editGroupName.dart';
import 'package:works_app/ui/chat/remove_friends.dart';

import '../../components/colors.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/reuse_widget.dart';
import 'archived_chats.dart';
import 'chat_view.dart';
import 'invite_friends.dart';

class ChatProfileViewScreen extends StatefulWidget {
  const ChatProfileViewScreen({super.key});

  @override
  State<ChatProfileViewScreen> createState() => _ChatProfileViewScreenState();
}

class _ChatProfileViewScreenState extends State<ChatProfileViewScreen> {
  File? _profileImage;
  String profilePic = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: '',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
        showLeadingIcon: true,
        actions: [
          InkWell(
            child: Image.asset(
              'assets/images/home/share.png',
              height: SizeConfig.blockWidth * 5,
              width: SizeConfig.blockWidth * 5,
            ),
          ),
          SizedBox(width: SizeConfig.blockWidth * 1.5),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: COLORS.black,
              size: SizeConfig.blockWidth * 6,
            ),
            onPressed: () {
              showDynamicBottomSheet(
                context,
                'Group Options',
                [
                  BottomSheetItem(
                    title: 'Invite People',
                    onTap: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const InviteFriendsList(),))
                    },
                  ),
                  BottomSheetItem(
                    title: 'Remove People',
                    onTap: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RemoveFriendsChat(),))
                    },
                  ),
                  BottomSheetItem(
                    title: 'Archive',
                    onTap: () => {},
                  ),
                  BottomSheetItem(
                    title: 'Mute Notification',
                    onTap: () => print('Add Friends clicked'),
                  ),
                  BottomSheetItem(
                    title: 'Leave Group',
                    onTap: () => {
                    },
                  ),
                  BottomSheetItem(
                    title: 'Clear Chat',
                    onTap: () => print('Add Friends clicked'),
                  ),
                  BottomSheetItem(
                    title: 'Report or Block',
                    onTap: () => print('Add Friends clicked'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: SizedBox(
          width: SizeConfig.blockWidth * 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfilePicture(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Group Name Goes Here'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDark,
                              fontSize: SizeConfig.blockWidth * 4,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.blockWidth * 1.5,
                          ),
                          InkWell(
                            onTap: () {
                              showMaterialModalBottomSheet(
                                enableDrag: true,
                                expand: false,
                                isDismissible: true,
                                backgroundColor: COLORS.white,
                                context: context,
                                closeProgressThreshold: 0,
                                duration: const Duration(seconds: 0),
                                useRootNavigator: true,
                                shape:  RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(SizeConfig.blockWidth*3.5)),
                                ),
                                builder: (context) => const EditGroupNameModal(),
                              );
                            },
                            child: Image.asset(
                              'assets/images/profile/edit.png',
                              width: SizeConfig.blockWidth * 5,
                              height: SizeConfig.blockWidth * 5,
                              color: COLORS.primary,
                            ),
                          )
                        ],
                      ),
                      Text(
                        '23 Members'.tr(),
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.5,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: COLORS.neutralDarkTwo,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockHeight,
                    horizontal: SizeConfig.blockWidth * 4.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Description'.tr(),
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 4,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showMaterialModalBottomSheet(
                          enableDrag: true,
                          expand: false,
                          isDismissible: true,
                          backgroundColor: COLORS.white,
                          context: context,
                          closeProgressThreshold: 0,
                          duration: const Duration(seconds: 0),
                          useRootNavigator: true,
                          shape:  RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.vertical(top: Radius.circular(SizeConfig.blockWidth*3.5)),
                          ),
                          builder: (context) => const EditGroupDescriptionModal(),
                        );
                      },
                      child: Image.asset(
                        'assets/images/profile/edit.png',
                        width: SizeConfig.blockWidth * 5,
                        height: SizeConfig.blockWidth * 5,
                        color: COLORS.primary,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockHeight * 1.5,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4.5),
                child: Text(
                  'Lorem ipsum dolor sit amet consectetur. Blandit enim euismod eget a amet etiam venenatis nunc libero. Netus quis a pharetra felis lectus. Mi eu at augue pharetra molestie odio donec gravida nisi. Porttitor orci auctor sapien sociis vitae.'
                      .tr(),
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.5,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  softWrap: true,
                ),
              ),
              SizedBox(
                height: SizeConfig.blockHeight * 1,
              ),
              Divider(
                color: COLORS.neutralDarkTwo,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockHeight,
                    horizontal: SizeConfig.blockWidth * 4.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Members'.tr(),
                          style: TextStyle(
                            color: COLORS.neutralDark,
                            fontSize: SizeConfig.blockWidth * 4,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: SizeConfig.blockWidth),
                          alignment: Alignment.center,
                          width: SizeConfig.blockWidth * 8.5,
                          height: SizeConfig.blockHeight * 3.5,
                          decoration: BoxDecoration(
                            color: COLORS.accent,
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockWidth * 1.5),
                          ),
                          child: Text(
                            '23'.tr(),
                            style: TextStyle(
                              color: COLORS.white,
                              fontSize: SizeConfig.blockWidth * 2.8,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddFriendsScreen(header: 'Add Friend'),));
                          },
                          child: Icon(
                            Icons.add_circle_outline,
                            color: COLORS.neutralDark,
                            size: SizeConfig.blockWidth * 5,
                          ),
                        ),
                        SizedBox(
                          width: SizeConfig.blockWidth * 3,
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddFriendsScreen(header: 'Friend Suggestion'),));
                          },
                          child: Icon(
                            Icons.search,
                            color: COLORS.neutralDark,
                            size: SizeConfig.blockWidth * 6,
                          ),
                        )

                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockHeight * 0.5,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 4.5,

                ),
                child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return chartMemberCardViewSearchCards(
                        image: 'assets/images/home/dumy1.png',
                        name: 'Julia Vandervort-Will',
                        onTapCard: () {
                          showDynamicBottomSheet(
                            context,
                            'Member Options',
                            [
                              BottomSheetItem(
                                title: 'View Profile',
                                onTap: () => {},
                              ),
                              BottomSheetItem(
                                title: 'Mark as admin',
                                onTap: () => {},
                              ),
                              BottomSheetItem(
                                title: 'Message',
                                onTap: () => {},
                              ),
                              BottomSheetItem(
                                title: 'Remove (User name goes her)',
                                onTap: () => print('Add Friends clicked'),
                              ),
                            ],
                          );
                        },
                        message: 'Lorem ipsum dolor sit',
                      );
                    }),
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_profileImage == null && profilePic.isEmpty) ...[
          ImagePickerComponent(
            onImageSelected: (File image) {
              setState(() {
                _profileImage = image;
                profilePic = '';
              });
            },
          ),
        ] else if (_profileImage != null) ...[
          Stack(
            children: [
              Container(
                height: SizeConfig.blockWidth * 32,
                width: SizeConfig.blockWidth * 34,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: COLORS.primary,
                    width: SizeConfig.blockWidth * 0.5,
                  ),
                  image: DecorationImage(
                    image: FileImage(
                      File(_profileImage!.path),
                    ),
                    fit: BoxFit.fill,
                  ),
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.5),
                ),
              ),
              // Image picker modal for changing the image
              Positioned(
                bottom: 0,
                right: 0,
                child: ImagePickerModal(
                  onImageSelected: (File image) {
                    setState(() {
                      _profileImage = image;
                      profilePic = '';
                    });
                  },
                ),
              )
            ],
          ),
        ] else if (profilePic.isNotEmpty) ...[
          Stack(
            children: [
              Container(
                height: SizeConfig.blockWidth * 32,
                width: SizeConfig.blockWidth * 34,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: COLORS.primary,
                    width: SizeConfig.blockWidth * 0.25,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(profilePic),
                    fit: BoxFit.fill,
                  ),
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.5),
                ),
              ),
              // Image picker modal for changing the image
              Positioned(
                bottom: 0,
                right: 0,
                child: ImagePickerModal(
                  onImageSelected: (File image) {
                    setState(() {
                      _profileImage = image;
                      profilePic = '';
                    });
                  },
                ),
              )
            ],
          ),
        ],
        SizedBox(height: SizeConfig.blockHeight * 3),
      ],
    );
  }
}
