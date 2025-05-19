import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

class ForceUpdateScreen extends StatefulWidget {
  const ForceUpdateScreen({super.key});

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  @override
  Future<void> _launchPlayStore() async {
    const url = 'https://play.google.com/store/apps/details?id=com.workss.works_app';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop,result) async {
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: COLORS.white,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: COLORS.white,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/login/force_update.png',
                width: SizeConfig.blockWidth * 60,
                height: SizeConfig.blockWidth * 60,
              ),
              SizedBox(height: SizeConfig.blockHeight * 4),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 5.5),
                child: Text(
                  'New Version, New Possibilities!'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 4.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 5.5),
                child: Text(
                  'We’ve made some exciting updates just for you. Tap below to upgrade and explore \nwhat’s new!'
                      .tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.7,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 4.5),
              customButton(
                text: 'UPDATE'.tr(),
                onPressed: _launchPlayStore,
                backgroundColor: COLORS.primary,
                showIcon: false,
                width: SizeConfig.blockWidth * 50,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
              )

            ],
          ),
        ),
      ),
    );
  }
}
