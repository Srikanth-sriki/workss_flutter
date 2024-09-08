import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';

import '../ui/main_screen/main_screen.dart';

SystemUiOverlayStyle customSystemOverlayStyle({
  Color statusBarColor = COLORS.white,
  Brightness statusBarIconBrightness = Brightness.dark,
  Brightness statusBarBrightness = Brightness.light,
}) {
  return SystemUiOverlayStyle(
    statusBarColor: statusBarColor,
    statusBarIconBrightness: statusBarIconBrightness,
    statusBarBrightness: statusBarBrightness,
  );
}

PreferredSizeWidget customAppBar({
  required VoidCallback? onSkipPressed,
  required BuildContext context,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(SizeConfig.blockHeight * 10),
    child: AppBar(
      backgroundColor: COLORS.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Workss',
        style: TextStyle(
          color: COLORS.primary,
          fontSize: SizeConfig.blockWidth * 6,
          fontWeight: FontWeight.bold,
          fontFamily: "Poppins",
        ),
      ),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const MainScreen()),
            );
          },
          child: Row(
            children: [
              Text(
                'skip'.tr(),
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 4.25,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                ),
              ),
              Icon(
                Icons.keyboard_double_arrow_right_outlined,
                color: COLORS.primaryOne,
                size: SizeConfig.blockWidth * 6,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget normalTextFieldWithMaxLine(
    {required String hintText,
    required TextEditingController controller,
    required TextInputType inputType,
    required ValueChanged onChanged,
    required FontWeight fontWeight,
    required String? Function(String?)? validator}) {
  return TextFormField(
    controller: controller,
    maxLines: 3,
    style: TextStyle(
        color: COLORS.neutralDark,
        fontFamily: "Poppins",
        fontWeight: fontWeight,
        letterSpacing: 0.3,
        fontSize: SizeConfig.blockWidth * 4),
    onChanged: onChanged,
    validator: validator,
    keyboardType: inputType,
    textCapitalization: TextCapitalization.words,
    textInputAction: TextInputAction.next,
    cursorColor: COLORS.black,
    decoration: textFieldDecoration(hint: hintText),
  );
}

Widget normalTextField(
    {required String hintText,
    required TextEditingController controller,
    required TextInputType inputType,
    required ValueChanged<String> onChanged,
    required FontWeight fontWeight,
    required String? Function(String?)? validator,
    int maxLines = 1,
    String? errorMessage,
    bool prefix = false,
    Widget? prefixIcon,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    bool hasError = false,
    Widget? suffixIcon,
    bool autofocus = false,
    bool suffix = false}) {
  return TextFormField(
    controller: controller,
    inputFormatters: inputFormatters,
    style: TextStyle(
      color: COLORS.neutralDark,
      fontFamily: "Poppins",
      fontWeight: fontWeight,
      letterSpacing: 0.3,
      fontSize: SizeConfig.blockWidth * 4,
    ),
    onChanged: onChanged,
    validator: validator,
    keyboardType: inputType,
    autofocus: autofocus,
    textCapitalization: TextCapitalization.words,
    textInputAction: TextInputAction.next,
    cursorColor: COLORS.black,
    cursorErrorColor: COLORS.black,
    maxLines: maxLines,
    decoration: textFieldDecoration(
        hint: hintText,
        prefix: prefix,
        suffix: suffix,
        prefixIcon: prefixIcon,
        errorMessage: errorMessage,
        hasError: hasError,
        suffixIcon: suffixIcon),
  );
}

InputDecoration textFieldDecoration(
    {required String hint,
    bool prefix = false,
    bool suffix = false,
    Widget? prefixIcon,
    String? errorMessage,
    bool hasError = false,
    Widget? suffixIcon}) {
  return InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.only(
      top: SizeConfig.blockHeight * 2.2,
      bottom: SizeConfig.blockHeight * 2.2,
      left: SizeConfig.blockWidth * 4,
      right: SizeConfig.blockWidth * 3,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? COLORS.semantic : COLORS.neutralDark,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? COLORS.semantic : COLORS.neutralDarkTwo,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? COLORS.semantic : COLORS.neutralDarkTwo,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? COLORS.semantic : COLORS.neutralDarkTwo,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
    ),
    errorText: errorMessage,
    hintText: hint,
    hintStyle: TextStyle(
      color: COLORS.neutralDark,
      fontWeight: FontWeight.w400,
      fontFamily: "Poppins",
      fontSize: SizeConfig.blockWidth * 3.2,
    ),
    prefixIcon: prefix ? prefixIcon : null,
    suffixIcon: suffix ? suffixIcon : null,
  );
}

Widget customButton(
    {required String text,
    IconData? icon,
    required VoidCallback onPressed,
    required double? width,
    required double? height,
    required Color? backgroundColor,
    required Color? textColor,
    required bool showIcon,
    bool? prefixIconBool = false,
    IconData? prefixIcon}) {
  return SizedBox(
    width: width ?? double.infinity,
    height: height ?? SizeConfig.blockHeight * 6.5,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? COLORS.primary,
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
        ),
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.blockHeight * 2,
          horizontal: SizeConfig.blockWidth * 4,
        ),
        child: Row(
          mainAxisAlignment: (prefixIconBool == false && showIcon == false)
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showIcon && icon != null) ...[
              Icon(
                icon,
                color: textColor ?? COLORS.white,
                size: SizeConfig.blockWidth * 5,
              ),
              // SizedBox(width: SizeConfig.blockWidth * 2),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor ?? COLORS.white,
                fontSize: SizeConfig.blockWidth * 4.25,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
            ),
            if (prefixIconBool! && prefixIcon != null) ...[
              Icon(
                prefixIcon,
                color: textColor ?? COLORS.white,
                size: SizeConfig.blockWidth * 5,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget registerText({required String text}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight * 0.5,
        horizontal: SizeConfig.blockWidth),
    child: Text(
      text,
      style: TextStyle(
        color: COLORS.neutralDark,
        fontSize: SizeConfig.blockWidth * 3.8,
        fontWeight: FontWeight.w500,
        fontFamily: "Poppins",
      ),
    ),
  );
}

class TextFieldWithDropdown extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final List<String> dropdownItems;
  final String? selectedValue;
  final ValueChanged<String?> onDropdownChanged;
  final TextInputType inputType;
  final bool hasError;
  final FormFieldValidator<String>? validator;

  const TextFieldWithDropdown({
    super.key,
    required this.controller,
    required this.hintText,
    required this.dropdownItems,
    this.selectedValue,
    required this.onDropdownChanged,
    this.inputType = TextInputType.text,
    this.hasError = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: hasError ? Colors.red : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: inputType,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              validator: validator,
            ),
          ),
          VerticalDivider(
            color: Colors.grey.shade300,
            thickness: 1,
            width: 1,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              icon: Icon(Icons.keyboard_arrow_down),
              onChanged: onDropdownChanged,
              items:
                  dropdownItems.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(value),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

Widget bottomTabIcon({required String icon}) {
  return Image.asset(icon,
      width: SizeConfig.blockWidth * 6, height: SizeConfig.blockWidth * 6);
}
