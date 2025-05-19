import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
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
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 5.5,vertical: SizeConfig.blockHeight*2.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: SizeConfig.blockWidth * 100,
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockHeight*6.5),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(SizeConfig.blockWidth * 6.5)),
                    color: COLORS.primaryOne.withOpacity(0.2),
                  ),
                  child: Image.asset(
                    'assets/images/login/maintenace.png',
                    width: SizeConfig.blockWidth * 80,
                    height: SizeConfig.blockWidth * 80,
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 8),
                Text(
                  'We’ll be back shortly!'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 4.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight),

                RichText(
                  text: TextSpan(
                    text: ".Workss ".tr(),
                    style: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.6,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Poppins",),
                    children: [
                      TextSpan(
                        text: "is currently under maintenance.".tr(),
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.8,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),

                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight * 4.5),
                customButton(
                  text: 'OKAY'.tr(),
                  onPressed: (){
                    SystemNavigator.pop();
                  },
                  backgroundColor: COLORS.primary,
                  showIcon: false,
                  width: SizeConfig.blockWidth * 40,
                  height: SizeConfig.blockHeight * 8,
                  textColor: COLORS.white,
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
