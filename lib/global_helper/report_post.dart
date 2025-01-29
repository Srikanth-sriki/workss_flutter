import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/ui/profile/account_delete_success.dart';

import '../../../bloc/authentication/authentication_bloc.dart';
import '../../../components/global_handle.dart';
import '../../../components/local_constant.dart';
import '../../../global_helper/reuse_widget.dart';

class ReportPostsBottomSheet extends StatefulWidget {
  final String? message;
  const ReportPostsBottomSheet({super.key, this.message});

  @override
  _ReportPostsBottomSheetState createState() => _ReportPostsBottomSheetState();
}

class _ReportPostsBottomSheetState extends State<ReportPostsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController messageController = TextEditingController();

  bool messageError = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Ensure padding for keyboard
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 5,
              vertical: SizeConfig.blockHeight * 2.5),
          decoration: BoxDecoration(
              color: COLORS.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeConfig.blockWidth * 5),
                  topRight: Radius.circular(SizeConfig.blockWidth * 5))),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 4.25,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
                Divider(
                  color: COLORS.neutralDarkTwo,
                  thickness: SizeConfig.blockHeight * 0.15,
                ),
                SizedBox(
                  height: SizeConfig.blockHeight * 0.5,
                ),
                buildBioTextField(
                    label: 'Can you please share the reason with us'.tr(),
                    controller: messageController,
                    hintText: "Write the reason".tr(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() => messageError = true);
                        return 'Please enter reason'.tr();
                      } else if (value.length < 5) {
                        setState(() => messageError = true);
                        return 'Reason must be at least 5 characters long'.tr();
                      }
                      setState(() => messageError = false);
                      return null;
                    },
                    error: messageError,
                    title: 'Can you please share the reason with us'.tr(),
                    onChanged: (value) {},
                    maxLines: 5),
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockHeight * 1.5),
                  padding: EdgeInsets.only(
                      top: SizeConfig.blockHeight * 2.5,
                      bottom: SizeConfig.blockHeight * 1),
                  decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: COLORS.neutralDarkOne, width: 0.1))),
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
                        text: 'REPORT'.tr(),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop({
                              'message': messageController.text,
                            });
                          }
                        },
                        backgroundColor: COLORS.semantic,
                        showIcon: false,
                        width: SizeConfig.blockWidth * 42,
                        height: SizeConfig.blockHeight * 8,
                        textColor: COLORS.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
