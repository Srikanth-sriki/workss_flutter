import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/chat/addFriends.dart';
import 'package:works_app/ui/chat/component.dart';
import 'package:works_app/ui/chat/modal/editGroupDescripation.dart';
import 'package:works_app/ui/chat/modal/editGroupName.dart';
import 'package:works_app/ui/chat/remove_friends.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/chat/chat_view_pro_modal.dart';
import '../professional/professional_view.dart';
import '../profile/notification.dart';
import 'archived_chats.dart';
import 'chat_view.dart';
import 'invite_friends.dart';
import 'modal/markas_admin_modal.dart';
import 'modal/report_or_block.dart';

class ChatProfileViewScreen extends StatefulWidget {
  final ChatViewGroupInfo chatViewGroupInfo;
  const ChatProfileViewScreen({super.key, required this.chatViewGroupInfo});

  @override
  State<ChatProfileViewScreen> createState() => _ChatProfileViewScreenState();
}

class _ChatProfileViewScreenState extends State<ChatProfileViewScreen> {
  late ChartBloc chartBloc;
  late InitialRegisterBloc initialRegisterBloc;
  File? _profileImage;
  String profilePic = '';

  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    profilePic = widget.chatViewGroupInfo.picture!;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<InitialRegisterBloc, InitialRegisterState>(
          listener: (context, state) {
            if (state is UploadImageSuccess) {
              chartBloc.add(EditGroupChatProfileEvent(
                picture: state.filePath,
                name: widget.chatViewGroupInfo.name!,
                description: widget.chatViewGroupInfo.description!,
                chatId: widget.chatViewGroupInfo.id!,
                onSuccess: (message) {},
                onError: (message) {
                  Navigator.pop(context);
                  showCustomSnackBar(
                    context: context,
                    message: 'Something Went wrong',
                  );
                },
              ));
            } else if (state is UploadImageFailed) {
              showCustomSnackBar(
                context: context,
                message: state.message,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xffF5FAFF),
        appBar: CustomAppBar(
          title: '',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark,
          showLeadingIcon: true,
          borderColor: true,
          actions: [
            if(widget.chatViewGroupInfo.isGroup!)...[
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) => ChartBloc()
                                            ..add(InviteMemberChartEvent(
                                                page: 1,
                                                pageSize: 10,
                                                groupId: widget
                                                    .chatViewGroupInfo.id!,
                                                keyWord: '')),
                                        ),
                                      ],
                                      child: InviteFriendsList(
                                        groupId: widget.chatViewGroupInfo.id!,
                                      ),
                                    )))
                      },
                    ),
                    BottomSheetItem(
                      title: 'Remove People',
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) => ChartBloc()
                                            ..add(FetchChartViewProfileEvent(
                                                chatId: widget
                                                    .chatViewGroupInfo.id!)),
                                        ),
                                      ],
                                      child: RemoveFriendsChat(
                                          chatViewGroupInfo:
                                              widget.chatViewGroupInfo),
                                    )))
                      },
                    ),
                    BottomSheetItem(
                      title: 'Archive',
                      onTap: () => {
                        chartBloc.add(ArchiveChatEvent(
                            chatId: widget.chatViewGroupInfo.id!,
                            onSuccess: (message) {
                              showCustomSnackBar(
                                  context: context,
                                  message: message,
                                  backgroundColor: COLORS.neutralDarkTwo);
                              Navigator.pushNamed(
                                context,
                                '/main_screen',
                                arguments: {'selectedIndex': 3},
                              );
                            },
                            onError: (message) {
                              showCustomSnackBar(
                                context: context,
                                message: message,
                              );
                            }))
                      },
                    ),
                    BottomSheetItem(
                      title: 'Mute Notification',
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) => ProfileBloc()
                                            ..add(const FetchSettingEvent()),
                                        ),
                                      ],
                                      child: const NotificationScreen(),
                                    )))
                      },
                    ),
                    BottomSheetItem(
                      title: 'Leave Group',
                      onTap: () => {
                        if (widget.chatViewGroupInfo.createdBy == Config.id)
                          {
                            showMaterialModalBottomSheet(
                              enableDrag: true,
                              expand: false,
                              isDismissible: true,
                              backgroundColor: COLORS.white,
                              context: context,
                              closeProgressThreshold: 0,
                              duration: const Duration(seconds: 0),
                              useRootNavigator: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) => const MarkasAdminModal(),
                            ),
                          }
                        else
                          {
                            chartBloc.add(LeaveGroupChatEvent(
                                chatId: widget.chatViewGroupInfo.id!,
                                onSuccess: (message) {
                                  showCustomSnackBar(
                                      context: context,
                                      message: message,
                                      backgroundColor: COLORS.neutralDarkTwo);
                                  Navigator.pushNamed(
                                    context,
                                    '/main_screen',
                                    arguments: {'selectedIndex': 3},
                                  );
                                },
                                onError: (message) {
                                  showCustomSnackBar(
                                    context: context,
                                    message: message,
                                  );
                                }))
                          }
                      },
                    ),
                    BottomSheetItem(
                      title: 'Clear Chat',
                      onTap: () => {
                        chartBloc.add(ClearChatEvent(
                            chatId: widget.chatViewGroupInfo.id!,
                            onSuccess: (message) {
                              showCustomSnackBar(
                                  context: context,
                                  message: message,
                                  backgroundColor: COLORS.neutralDarkTwo);
                              Navigator.pushNamed(
                                context,
                                '/main_screen',
                                arguments: {'selectedIndex': 3},
                              );
                            },
                            onError: (message) {
                              showCustomSnackBar(
                                context: context,
                                message: message,
                              );
                            }))
                      },
                    ),
                    BottomSheetItem(
                      title: 'Report or Block',
                      onTap: () => {
                        showMaterialModalBottomSheet(
                          enableDrag: true,
                          expand: false,
                          isDismissible: true,
                          backgroundColor: COLORS.white,
                          context: context,
                          closeProgressThreshold: 0,
                          duration: const Duration(seconds: 0),
                          useRootNavigator: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => const ReportOrBlockModal(),
                        ),
                      },
                    ),
                  ],
                );
              },
            )],
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
                Container(
                  color: COLORS.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(SizeConfig.blockWidth * 0.5),
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
                                    widget.chatViewGroupInfo.name!,
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(
                                                  SizeConfig.blockWidth * 3.5)),
                                        ),
                                        builder: (context) =>
                                            BlocProvider<ChartBloc>(
                                          create: (context) =>
                                              ChartBloc(), // Provide your ProfileBloc
                                          child: EditGroupNameModal(
                                              chatViewGroupInfo:
                                                  widget.chatViewGroupInfo),
                                        ),
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
                                '${widget.chatViewGroupInfo.participants!.length} Members'
                                    .tr(),
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
                      SizedBox(
                        height: SizeConfig.blockHeight * 2,
                      ),
                      const Divider(
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                            SizeConfig.blockWidth * 3.5)),
                                  ),
                                  builder: (context) => BlocProvider<ChartBloc>(
                                    create: (context) =>
                                        ChartBloc(), // Provide your ProfileBloc
                                    child: EditGroupDescriptionModal(
                                        chatViewGroupInfo:
                                            widget.chatViewGroupInfo),
                                  ),
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockWidth * 4.5),
                        child: Text(
                          widget.chatViewGroupInfo.description!,
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
                        height: SizeConfig.blockHeight * 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: COLORS.neutralDarkTwo,
                              width: SizeConfig.blockWidth * 0.2))),
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockHeight * 2,
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
                            margin:
                                EdgeInsets.only(left: SizeConfig.blockWidth),
                            alignment: Alignment.center,
                            width: SizeConfig.blockWidth * 7,
                            height: SizeConfig.blockHeight * 3.5,
                            decoration: BoxDecoration(
                              color: COLORS.accent,
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 1.5),
                            ),
                            child: Text(
                              widget.chatViewGroupInfo.participants!.length!
                                  .toString(),
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
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                create: (context) => FriendsBloc()
                                                  ..add(
                                                      FetchFriendsAddListEvent(
                                                          page: 1,
                                                          pageSize: 10,
                                                          keyWord: '')),
                                              ),
                                              BlocProvider(
                                                  create: (context) =>
                                                      ShowInterestedBloc())
                                            ],
                                            child: const AddFriendsScreen(
                                                header: 'Add Friend'),
                                          )));
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
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                create: (context) => FriendsBloc()
                                                  ..add(
                                                      FetchFriendsAddListEvent(
                                                          page: 1,
                                                          pageSize: 10,
                                                          keyWord: '')),
                                              ),
                                              BlocProvider(
                                                  create: (context) =>
                                                      ShowInterestedBloc())
                                            ],
                                            child: const AddFriendsScreen(
                                                header: 'Friend Suggestion'),
                                          )));
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
                      itemCount: widget.chatViewGroupInfo.participants!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        Participant participants =
                            widget.chatViewGroupInfo.participants![index];
                        return chartMemberCardViewSearchCards(
                          image: participants.user.profilePic,
                          name: participants.user.name,
                          admin: participants.isAdmin,
                          onTapCard: () {
                            showDynamicBottomSheet(
                              context,
                              'Member Options',
                              [
                                BottomSheetItem(
                                  title: 'View Profile',
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider(
                                                      create: (context) =>
                                                          ProfessionalBloc()
                                                            ..add(FetchProfessionalView(
                                                                participants
                                                                    .userId)),
                                                    ),
                                                    BlocProvider(
                                                      create: (context) =>
                                                          ShowInterestedBloc(),
                                                    ),
                                                    BlocProvider(
                                                        create: (context) =>
                                                            ReportPostBloc())
                                                  ],
                                                  child: ProfessionalViewScreen(
                                                    id: participants.userId,
                                                    refreshPageCallback: () {},
                                                  ),
                                                )))
                                  },
                                ),
                                if (widget.chatViewGroupInfo.createdBy ==
                                    Config.id) ...[
                                  BottomSheetItem(
                                    title: 'Mark as admin',
                                    onTap: () => {
                                      showMaterialModalBottomSheet(
                                        enableDrag: true,
                                        expand: false,
                                        isDismissible: true,
                                        backgroundColor: COLORS.white,
                                        context: context,
                                        closeProgressThreshold: 0,
                                        duration: const Duration(seconds: 0),
                                        useRootNavigator: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        builder: (context) =>
                                            const MarkasAdminModal(),
                                      ),
                                    },
                                  ),
                                ],
                                BottomSheetItem(
                                  title: 'Message',
                                  onTap: () => {},
                                ),
                                if (widget.chatViewGroupInfo.createdBy ==
                                    Config.id) ...[
                                  BottomSheetItem(
                                    title: 'Remove (${participants.user.name})',
                                    onTap: () => {
                                      chartBloc.add(SendRemoveMemberEvent(
                                          chatId: participants.chatId!,
                                          removeMember: [participants.userId!],
                                          onSuccess: (message) {
                                            showCustomSnackBar(
                                              context: context,
                                              message: message,
                                            );
                                          },
                                          onError: (message) {
                                            showCustomSnackBar(
                                              context: context,
                                              message: message,
                                            );
                                          }))
                                    },
                                  ),
                                ],
                              ],
                            );
                          },
                          message: participants.user.professionType,
                        );
                      }),
                )
              ],
            ),
          ),
        )),
      ),
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
                profilePic = '';
                _profileImage = image;
              });
              initialRegisterBloc
                  .add(UploadImageEvent(imagePath: _profileImage!));
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
                    initialRegisterBloc
                        .add(UploadImageEvent(imagePath: _profileImage!));
                  },
                ),
              )
            ],
          ),
        ] else if (profilePic.isNotEmpty) ...[
          Stack(
            children: [
              Container(
                height: SizeConfig.blockWidth * 30,
                width: SizeConfig.blockWidth * 30,
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
        SizedBox(height: SizeConfig.blockHeight * 2),
      ],
    );
  }
}
