import 'package:flutter/material.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../global_helper/reuse_widget.dart';

class ReportOrBlockModal extends StatefulWidget {
  final String? message;
  const ReportOrBlockModal({super.key,required this.message});

  @override
  _ReportOrBlockModalState createState() => _ReportOrBlockModalState();
}

class _ReportOrBlockModalState extends State<ReportOrBlockModal> {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Report or Block'.tr(),
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 4,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: COLORS.black,
                        size: SizeConfig.blockWidth * 5,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(
                  color: COLORS.neutralDarkTwo,
                  thickness: SizeConfig.blockHeight * 0.15,
                ),
                buildBioTextField(
                    label: ''.tr(),
                    controller: messageController,
                    hintText: "Write a reason for report or block group".tr(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() => messageError = true);
                        return 'Please enter reason'.tr();
                      }
                      setState(() => messageError = false);
                      return null;
                    },
                    error: messageError,
                    title: ''.tr(),
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
                        backgroundColor: COLORS.neutralDarkTwo,
                        showIcon: false,
                        width: SizeConfig.blockWidth * 42,
                        height: SizeConfig.blockHeight * 8,
                        textColor: COLORS.neutralDark,
                      ),
                      customButton(
                        text: 'REPORT GROUP'.tr(),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop({
                              'message': messageController.text,
                            });
                          }
                        },
                        backgroundColor: COLORS.primary,
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
