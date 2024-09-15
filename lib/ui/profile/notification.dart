import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
            contentPadding:
                EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 6),
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
              scale: 0.9, // Increase or decrease this value to change the size
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
            )),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar:  CustomAppBar(
          title: 'Notifications'.tr(),
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      horizontal: SizeConfig.blockWidth * 6),
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
                  onChanged: (value) {
                    // Handle value change
                  },
                ),
                SwitchTile(
                  title: 'Works Viewed, Interest Showed',
                  onChanged: (value) {
                    // Handle value change
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockHeight,
                      horizontal: SizeConfig.blockWidth * 6),
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
                  onChanged: (value) {
                    // Handle value change
                  },
                ),
                SwitchTile(
                  title: 'New Clips from Friends',
                  onChanged: (value) {
                    // Handle value change
                  },
                ),
                SwitchTile(
                  title: 'New Friends and Suggestions',
                  onChanged: (value) {
                    // Handle value change
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockHeight,
                      horizontal: SizeConfig.blockWidth * 6),
                  child: Text(
                    'Clips & Chats'.tr(),
                    style: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.4,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                SwitchTile(
                  title: 'Messages Received',
                  onChanged: (value) {
                    // Handle value change
                  },
                ),
                SwitchTile(
                  title: 'Comments or Likes on Your Posts',
                  onChanged: (value) {
                    // Handle value change
                  },
                ),
                SwitchTile(
                  title: 'Group Alerts',
                  onChanged: (value) {
                    // Handle value change
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
