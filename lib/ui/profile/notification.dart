import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/setting_fetch_model.dart';

class SwitchTile extends StatelessWidget {
  final String title;
  final ValueChanged<bool> onChanged;
  final bool value;

  const SwitchTile({
    super.key,
    required this.title,
    required this.onChanged,
    this.value = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 6,
            vertical: SizeConfig.blockHeight * 0.8,
          ),
          title: Text(
            title.tr(),
            style: TextStyle(
              color: COLORS.neutralDark,
              fontSize: SizeConfig.blockWidth * 3.8,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
            ),
          ),
          trailing: Transform.scale(
            scale: 0.9, // Adjust scale to change the size
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: COLORS.primary,
              inactiveThumbColor: COLORS.neutralDarkOne,
            ),
          ),
        ),
        Divider(
          color: COLORS.neutralDarkTwo,
          thickness: SizeConfig.blockHeight * 0.2,
          height: SizeConfig.blockHeight * 1.5,
        ),
      ],
    );
  }
}


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late ProfileBloc profileBloc;
  late SettingFetchModelList settingFetchModelList;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    context.read<ProfileBloc>().add(FetchSettingEvent()); // Fetch settings here
  }

  // Helper method to update the specific switch's value in the settings model
  void _updateNotificationSetting({
    bool? workPostedInCity,
    bool? workViewedIntrestShowed,
    bool? friendRequest,
    bool? newClipsFromFriends,
    bool? newFriendSuggestions,
    bool? msgRecevied,
    bool? cmtOrLikeOnYourPost,
    bool? groupAlert,
  }) {
    setState(() {
      if (workPostedInCity != null) settingFetchModelList.workPostedInCity = workPostedInCity;
      if (workViewedIntrestShowed != null) settingFetchModelList.workViewedIntrestShowed = workViewedIntrestShowed;
      if (friendRequest != null) settingFetchModelList.friendRequest = friendRequest;
      if (newClipsFromFriends != null) settingFetchModelList.newClipsFromFriends = newClipsFromFriends;
      if (newFriendSuggestions != null) settingFetchModelList.newFriendSuggestions = newFriendSuggestions;
      if (msgRecevied != null) settingFetchModelList.msgRecevied = msgRecevied;
      if (cmtOrLikeOnYourPost != null) settingFetchModelList.cmtOrLikeOnYourPost = cmtOrLikeOnYourPost;
      if (groupAlert != null) settingFetchModelList.groupAlert = groupAlert;
    });

    // Dispatch the event with the updated values
    context.read<ProfileBloc>().add(
      NotificationSettingEvent(
        workPostedInCity: settingFetchModelList.workPostedInCity!,
        workViewedIntrestShowed: settingFetchModelList.workViewedIntrestShowed!,
        friendRequest: settingFetchModelList.friendRequest!,
        newClipsFromFriends: settingFetchModelList.newClipsFromFriends!,
        newFriendSuggestions: settingFetchModelList.newFriendSuggestions!,
        msgRecevied: settingFetchModelList.msgRecevied!,
        cmtOrLikeOnYourPost: settingFetchModelList.cmtOrLikeOnYourPost!,
        groupAlert: settingFetchModelList.groupAlert!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: 'Notifications'.tr(),
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            setState(() {
              loading = true;
            });
          } else if (state is NotificationFetchSettingSuccess) {
            setState(() {
              loading = false;
              error = false;
              settingFetchModelList = state.settingFetchModelList;
            });
          } else if (state is NotificationFetchSettingFailed) {
            setState(() {
              loading = false;
              error = true;
            });
          }
        },
        child: Column(
          children: [
            if (loading) ...[
              Center(child: CircularProgressIndicator())
            ] else if (error) ...[
              Center(child: Text('state.message'))
            ] else if (!loading && !error) ...[
              SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockHeight * 2,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSectionHeaderFirst('Works Notifications'),
                        buildSwitchTile(
                          title: 'Works Posted in Cities',
                          value: settingFetchModelList.workPostedInCity!,
                          onChanged: (value) {
                            _updateNotificationSetting(workPostedInCity: value);
                          },
                        ),
                        buildSwitchTile(
                          title: 'Works Viewed, Interest Showed',
                          value: settingFetchModelList.workViewedIntrestShowed!,
                          onChanged: (value) {
                            _updateNotificationSetting(workViewedIntrestShowed: value);
                          },
                        ),
                        buildSectionHeader('Social Notifications'),
                        buildSwitchTile(
                          title: 'Friend Request',
                          value: settingFetchModelList.friendRequest!,
                          onChanged: (value) {
                            _updateNotificationSetting(friendRequest: value);
                          },
                        ),
                        buildSwitchTile(
                          title: 'New Clips from Friends',
                          value: settingFetchModelList.newClipsFromFriends!,
                          onChanged: (value) {
                            _updateNotificationSetting(newClipsFromFriends: value);
                          },
                        ),
                        buildSwitchTile(
                          title: 'New Friends and Suggestions',
                          value: settingFetchModelList.newFriendSuggestions!,
                          onChanged: (value) {
                            _updateNotificationSetting(newFriendSuggestions: value);
                          },
                        ),
                        buildSectionHeader('Clips Notifications'),
                        buildSwitchTile(
                          title: 'Messages Received',
                          value: settingFetchModelList.msgRecevied!,
                          onChanged: (value) {
                            _updateNotificationSetting(msgRecevied: value);
                          },
                        ),
                        buildSwitchTile(
                          title: 'Comments or Likes on Your Posts',
                          value: settingFetchModelList.cmtOrLikeOnYourPost!,
                          onChanged: (value) {
                            _updateNotificationSetting(cmtOrLikeOnYourPost: value);
                          },
                        ),
                        buildSwitchTile(
                          title: 'Group Alerts',
                          value: settingFetchModelList.groupAlert!,
                          onChanged: (value) {
                            _updateNotificationSetting(groupAlert: value);
                          },
                        ),
                      ],
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

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        top: SizeConfig.blockHeight*3,bottom: SizeConfig.blockHeight,
        right: SizeConfig.blockWidth * 6,left: SizeConfig.blockWidth * 6,
      ),
      child: Text(
        title.tr(),
        style: TextStyle(
          color: COLORS.neutralDarkOne,
          fontSize: SizeConfig.blockWidth * 3.4,
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
        ),
      ),
    );
  }
  Widget buildSectionHeaderFirst(String title) {
    return Padding(
      padding: EdgeInsets.only(
        top: SizeConfig.blockHeight,bottom: SizeConfig.blockHeight,
        right: SizeConfig.blockWidth * 6,left: SizeConfig.blockWidth * 6,
      ),
      child: Text(
        title.tr(),
        style: TextStyle(
          color: COLORS.neutralDarkOne,
          fontSize: SizeConfig.blockWidth * 3.4,
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
        ),
      ),
    );
  }

  // Helper method to build the switch tile
  Widget buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchTile(
      title: title,
      value: value,
      onChanged: onChanged,
    );
  }
}
