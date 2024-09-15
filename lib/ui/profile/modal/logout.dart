import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/ui/profile/logout_success.dart';

import '../../../global_helper/reuse_widget.dart';

class LogoutBottomSheet extends StatefulWidget {
  const LogoutBottomSheet({super.key});

  @override
  _LogoutBottomSheetState createState() => _LogoutBottomSheetState();
}

class _LogoutBottomSheetState extends State<LogoutBottomSheet> {
  final TextEditingController messageController = TextEditingController();

  bool messageError = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 5,
          vertical: SizeConfig.blockHeight * 2.5),
      decoration: BoxDecoration(
          color: COLORS.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeConfig.blockWidth * 5),
              topRight: Radius.circular(SizeConfig.blockWidth * 5))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/profile/logout.png',
            height: SizeConfig.blockWidth * 30,
            width: SizeConfig.blockWidth * 30,
            fit: BoxFit.contain,
          ),
          SizedBox(height: SizeConfig.blockHeight*2,),
          Text(
            "Are you sure you want to log out? Your session will end, and you'll need to log in again to continue.".tr(),
            style: TextStyle(
              color: COLORS.neutralDarkOne,
              fontSize: SizeConfig.blockWidth * 3.4,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: SizeConfig.blockHeight * 1.5),
            padding: EdgeInsets.only(
                top: SizeConfig.blockHeight * 2.5,
                bottom: SizeConfig.blockHeight * 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customButton(
                  text: 'CANCEL'.tr(),
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  backgroundColor: COLORS.primary,
                  showIcon: false,
                  width: SizeConfig.blockWidth * 42,
                  height: SizeConfig.blockHeight * 8,
                  textColor: COLORS.white,
                ),
                customButton(
                  text: 'LOGOUT'.tr(),
                  onPressed: () {
                   // Navigator.of(context).pop();
                    // if (_formKey.currentState!.validate()) {
                    //   _submitButton();
                    // }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => LogoutSuccess()),
                    );
                  },
                  backgroundColor: COLORS.semantic,
                  showIcon: false,
                  width: SizeConfig.blockWidth * 42,
                  height: SizeConfig.blockHeight * 8,
                  textColor: COLORS.white,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
