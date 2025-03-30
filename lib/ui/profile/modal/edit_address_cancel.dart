import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/ui/profile/logout_success.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../components/global_handle.dart';
import '../../../global_helper/reuse_widget.dart';

class EditAddressCancelBottomSheet extends StatefulWidget {

  final VoidCallback reset;

  const EditAddressCancelBottomSheet({required this.reset,super.key});

  @override
  _EditAddressCancelBottomSheetState createState() => _EditAddressCancelBottomSheetState();
}

class _EditAddressCancelBottomSheetState extends State<EditAddressCancelBottomSheet> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockHeight * 35,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockWidth * 5,
        vertical: SizeConfig.blockHeight * 2.5,
      ),
      decoration: BoxDecoration(
        color: COLORS.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeConfig.blockWidth * 5),
          topRight: Radius.circular(SizeConfig.blockWidth * 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SizedBox(height: SizeConfig.blockHeight * 3),
          Padding(
            padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 0.5),
            child: Text(
              "Are you sure you want to \ncancel?".tr(),
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 3.8,
                fontWeight: FontWeight.w600,
                fontFamily: "Poppins",
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            "Any unsaved changes will be discarded.".tr(),
            style: TextStyle(
              color: COLORS.neutralDarkOne,
              fontSize: SizeConfig.blockWidth * 3.4,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeConfig.blockHeight * 2),
          Container(
            padding: EdgeInsets.only(
              top: SizeConfig.blockHeight * 2.5,
              bottom: SizeConfig.blockHeight * 1,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customButton(
                  text: 'NO'.tr(),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: COLORS.neutralDarkTwo,
                  showIcon: false,
                  width: SizeConfig.blockWidth * 40,
                  height: SizeConfig.blockHeight * 8,
                  textColor: COLORS.black,
                ),
                customButton(
                  text: 'DISCARD'.tr(),
                  onPressed: () {
                    widget.reset();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  backgroundColor: COLORS.primary,
                  showIcon: false,
                  width: SizeConfig.blockWidth * 40,
                  height: SizeConfig.blockHeight * 8,
                  textColor: COLORS.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
