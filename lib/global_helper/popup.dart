import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/reuse_widget.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String positiveButtonText;
  final String negativeButtonText;
  final VoidCallback onPositivePressed;
  final VoidCallback onNegativePressed;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.positiveButtonText,
    required this.negativeButtonText,
    required this.onPositivePressed,
    required this.onNegativePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth*4),
      ),
      child: Padding(
        padding:  EdgeInsets.all(SizeConfig.blockWidth*6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.tr(),
              style: TextStyle(
                color:  COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 4,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: SizeConfig.blockWidth*3),
            Text(
              message.tr(),
              style: TextStyle(
                color:  COLORS.neutralDarkOne,
                fontSize: SizeConfig.blockWidth * 3.4,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: SizeConfig.blockWidth*3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: customButton(
                    text:  negativeButtonText,
                    onPressed: onNegativePressed,
                    backgroundColor: COLORS.primaryOne.withOpacity(0.5),
                    showIcon: false,
                    textColor: COLORS.primary,
                  ),
                ),
                SizedBox(width: SizeConfig.blockWidth*3),
                Expanded(
                  child: customButton(
                  text:  positiveButtonText,
                  onPressed: onPositivePressed,
                  backgroundColor: COLORS.primary,
                  showIcon: false,
                  textColor: COLORS.white,
                ),


                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


void showCustomAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String positiveButtonText,
  required String negativeButtonText,
  required VoidCallback onPositivePressed,
  required VoidCallback onNegativePressed,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return CustomAlertDialog(
        title: title,
        message: message,
        positiveButtonText: positiveButtonText,
        negativeButtonText: negativeButtonText,
        onPositivePressed: onPositivePressed,
        onNegativePressed: onNegativePressed,
      );
    },
  );
}
