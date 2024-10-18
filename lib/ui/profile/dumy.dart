import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';


class SwitchTile extends StatefulWidget {
  final String title;
  final ValueChanged<bool> onChanged;
  final bool initialValue;

  const SwitchTile({
    super.key,
    required this.title,
    required this.onChanged,
    this.initialValue = false,
  });

  @override
  _SwitchTileState createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  late bool isEnabled;

  @override
  void initState() {
    super.initState();
    isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 6,
            vertical: SizeConfig.blockHeight * 0.8,
          ),
          title: Text(
            widget.title.tr(),
            style: TextStyle(
              color: COLORS.neutralDark,
              fontSize: SizeConfig.blockWidth * 3.8,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
            ),
          ),
          trailing: Transform.scale(
            scale: 0.9, // Adjust the size of the switch
            child: Switch(
              value: isEnabled,
              onChanged: (value) {
                setState(() {
                  isEnabled = value;
                });
                widget.onChanged(value);
              },
              activeColor: COLORS.primary,
              inactiveThumbColor: COLORS.neutralDarkOne,
              trackOutlineWidth: WidgetStatePropertyAll(0.1),
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
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchSettingEvent());
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
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is NotificationSettingFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is NotificationFetchSettingSuccess) {
            var settings = state.settingFetchModelList;
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockHeight * 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockHeight,
                        horizontal: SizeConfig.blockWidth * 6,
                      ),
                      child: Text(
                        'Works Notifications'.tr(),
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.4,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    SwitchTile(
                      title: 'Works Posted in Cities',
                      initialValue: settings.workPostedInCity ?? false,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                          NotificationSettingEvent(
                            workPostedInCity: value,
                            workViewedIntrestShowed: settings.workViewedIntrestShowed!,
                            friendRequest: settings.friendRequest!,
                            newClipsFromFriends: settings.newClipsFromFriends!,
                            newFriendSuggestions: settings.newFriendSuggestions!,
                            msgRecevied: settings.msgRecevied!,
                            cmtOrLikeOnYourPost: settings.cmtOrLikeOnYourPost!,
                            groupAlert: settings.groupAlert!,
                          ),
                        );
                      },
                    ),
                    SwitchTile(
                      title: 'Works Viewed, Interest Showed',
                      initialValue: settings.workViewedIntrestShowed ?? false,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                          NotificationSettingEvent(
                            workPostedInCity: settings.workPostedInCity!,
                            workViewedIntrestShowed: value,
                            friendRequest: settings.friendRequest!,
                            newClipsFromFriends: settings.newClipsFromFriends!,
                            newFriendSuggestions: settings.newFriendSuggestions!,
                            msgRecevied: settings.msgRecevied!,
                            cmtOrLikeOnYourPost: settings.cmtOrLikeOnYourPost!,
                            groupAlert: settings.groupAlert!,
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockHeight,
                        horizontal: SizeConfig.blockWidth * 6,
                      ),
                      child: Text(
                        'Social Notifications'.tr(),
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.4,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    SwitchTile(
                      title: 'Friend Request',
                      initialValue: settings.friendRequest ?? false,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                          NotificationSettingEvent(
                            workPostedInCity: settings.workPostedInCity!,
                            workViewedIntrestShowed: settings.workViewedIntrestShowed!,
                            friendRequest: value,
                            newClipsFromFriends: settings.newClipsFromFriends!,
                            newFriendSuggestions: settings.newFriendSuggestions!,
                            msgRecevied: settings.msgRecevied!,
                            cmtOrLikeOnYourPost: settings.cmtOrLikeOnYourPost!,
                            groupAlert: settings.groupAlert!,
                          ),
                        );
                      },
                    ),
                    // Continue adding other SwitchTiles as needed
                  ],
                ),
              ),
            );
          } else if (state is NotificationFetchSettingFailed) {
            return Center(child: Text(state.message));
          }
          return Container(); // Fallback UI
        },
      ),
    );
  }
}
