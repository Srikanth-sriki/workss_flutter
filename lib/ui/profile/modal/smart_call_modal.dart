import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../bloc/chart/chart_bloc.dart';
import '../../../global_helper/reuse_widget.dart';

class SmartCallModal extends StatefulWidget {
  final String header;
  final String buttonText;
  final VoidCallback onPress;
  final Color backgroundColor;

  const SmartCallModal(
      {super.key, required this.header, required this.buttonText,required this.backgroundColor,required this.onPress});

  @override
  _SmartCallModalState createState() => _SmartCallModalState();
}

class _SmartCallModalState extends State<SmartCallModal> {

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
              vertical: SizeConfig.blockHeight * 3.5),
          decoration: BoxDecoration(
              color: COLORS.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeConfig.blockWidth * 5),
                  topRight: Radius.circular(SizeConfig.blockWidth * 5))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.header.tr(),
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 3.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.blockHeight*3,),
              Row(
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
                  SizedBox(width: SizeConfig.blockWidth*4,),
                  customButton(
                    text: widget.buttonText.tr(),
                    onPressed: widget.onPress,
                    backgroundColor: widget.backgroundColor,
                    showIcon: false,
                    width: SizeConfig.blockWidth * 42,
                    height: SizeConfig.blockHeight * 8,
                    textColor: COLORS.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
