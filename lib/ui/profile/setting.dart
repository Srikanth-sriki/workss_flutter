import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/profile/modal/account_delete.dart';
import 'package:works_app/ui/profile/modal/logout.dart';
import 'package:works_app/ui/profile/notification.dart';
import 'package:works_app/ui/profile/privacy_policy.dart';
import 'package:works_app/ui/profile/terms_and_con.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../components/colors.dart';
import '../../global_helper/reuse_widget.dart';
import '../onboarding/language_selection.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 6,vertical: SizeConfig.blockHeight*0.8),
          leading: Icon(
            icon,
            color: COLORS.black,
            size: SizeConfig.blockWidth * 6,
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
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: SizeConfig.blockWidth * 4,
            color: COLORS.black,
          ),
          onTap: onTap,
        ),
        Divider(
          color: COLORS.neutralDarkTwo,
          thickness: SizeConfig.blockHeight * 0.2,
        ),
      ],
    );
  }
}

class SettingApp extends StatefulWidget {
  const SettingApp({super.key});

  @override
  State<SettingApp> createState() => _SettingAppState();
}

class _SettingAppState extends State<SettingApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Settings',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SingleChildScrollView(
        child: SafeArea(
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
                    'Application Settings'.tr(),
                    style: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.4,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
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
                            )));
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => MultiBlocProvider(
                    //               providers: [
                    //                 BlocProvider(
                    //                   create: (context) => ProfileBloc(),
                    //                 ),
                    //               ],
                    //               child: const NotificationScreen(),
                    //             )));
                  },
                ),
                SettingsTile(
                  icon: Icons.language,
                  title: 'Change Language',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const LanguageSelectionScreen(
                                routeType: 'homo',
                              )),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockHeight,
                      horizontal: SizeConfig.blockWidth * 6),
                  child: Text(
                    'Terms & Policies'.tr(),
                    style: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.4,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.description,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              TermsAndCondition()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => PrivacyPolicy()),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockHeight,
                      horizontal: SizeConfig.blockWidth * 6),
                  child: Text(
                    'Leave & Delete'.tr(),
                    style: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.4,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.delete,
                  title: 'Delete Account',
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
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => BlocProvider<ProfileBloc>(
                        create: (context) =>
                            ProfileBloc(), // Provide your ProfileBloc
                        child: const AccountDeleteBottomSheet(),
                      ),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    showMaterialModalBottomSheet(
                      enableDrag: true,
                      expand: false,
                      isDismissible: true,
                      backgroundColor: COLORS.white,
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => LogoutBottomSheet(),
                    );
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
