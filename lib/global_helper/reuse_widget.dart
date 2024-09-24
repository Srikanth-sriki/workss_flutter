import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/profile/component.dart';

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
      scrolledUnderElevation: 0,
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
          onPressed: () {
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
    void Function()? onTap,
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
    onTap: onTap,
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
        width: 1,
      ),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? COLORS.semantic : COLORS.neutralDarkTwo,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? COLORS.semantic : COLORS.neutralDarkTwo,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? COLORS.semantic : COLORS.neutralDarkTwo,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
    ),
    errorText: errorMessage,
    hintText: hint,
    hintStyle: TextStyle(
      color: COLORS.neutralDarkOne,
      fontWeight: FontWeight.w400,
      fontFamily: "Poppins",
      fontSize: SizeConfig.blockWidth * 3.2,
    ),
    prefixIcon: prefix ? prefixIcon : null,
    suffixIcon: suffix ? suffixIcon : null,
  );
}

// Widget customButton(
//     {required String text,
//     IconData? icon,
//     required VoidCallback onPressed,
//     required double? width,
//      double? height,
//     required Color? backgroundColor,
//     required Color? textColor,
//     required bool showIcon,
//     bool? prefixIconBool = false,
//     IconData? prefixIcon}) {
//   return SizedBox(
//     width: width ?? double.infinity,
//     height: height ?? SizeConfig.blockHeight * 6.5,
//     child: TouchRippleEffect(
//       borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//       rippleColor: Colors.white60,
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//         child: Container(
//           decoration: BoxDecoration(
//             color: backgroundColor ?? COLORS.primary,
//             borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//           ),
//           padding: EdgeInsets.symmetric(
//             vertical: SizeConfig.blockHeight * 2,
//             horizontal: SizeConfig.blockWidth * 4,
//           ),
//           child: Row(
//             mainAxisAlignment: (prefixIconBool == false && showIcon == false)
//                 ? MainAxisAlignment.center
//                 : MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               if (showIcon && icon != null) ...[
//                 Icon(
//                   icon,
//                   color: textColor ?? COLORS.white,
//                   size: SizeConfig.blockWidth * 5,
//                 ),
//                 // SizedBox(width: SizeConfig.blockWidth * 2),
//               ],
//               Text(
//                 text,
//                 style: TextStyle(
//                   color: textColor ?? COLORS.white,
//                   fontSize: SizeConfig.blockWidth * 4.2,
//                   fontWeight: FontWeight.w500,
//                   fontFamily: "Poppins",
//                 ),
//               ),
//               if (prefixIconBool! && prefixIcon != null) ...[
//                 Icon(
//                   prefixIcon,
//                   color: textColor ?? COLORS.white,
//                   size: SizeConfig.blockWidth * 5,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

Widget loadingIndicator() {
  return SizedBox(
    height: SizeConfig.blockHeight * 2.8,
    width: SizeConfig.blockHeight * 2.8,
    child: CircularProgressIndicator(strokeWidth: SizeConfig.blockWidth*0.5, color: COLORS.white),
  );
}

Widget customButton({
  required String text,
  IconData? icon,
  required VoidCallback onPressed,
  double? width,
  double? height,
  required Color? backgroundColor,
  required Color? textColor,
  required bool showIcon,
  bool? prefixIconBool = false,
  IconData? prefixIcon,
  bool loading = false,
}) {
  return width == null
      ? IntrinsicWidth(
          child: _buildButtonContent(
              text: text,
              icon: icon,
              onPressed: onPressed,
              height: height,
              backgroundColor: backgroundColor,
              textColor: textColor,
              showIcon: showIcon,
              prefixIconBool: prefixIconBool,
              prefixIcon: prefixIcon,
              loading: loading),
        )
      : SizedBox(
          width: width,
          child: _buildButtonContent(
              text: text,
              icon: icon,
              onPressed: onPressed,
              height: height,
              backgroundColor: backgroundColor,
              textColor: textColor,
              showIcon: showIcon,
              prefixIconBool: prefixIconBool,
              prefixIcon: prefixIcon,
              loading: loading),
        );
}

Widget _buildButtonContent({
  required String text,
  IconData? icon,
  required VoidCallback onPressed,
  double? height,
  required Color? backgroundColor,
  required Color? textColor,
  required bool showIcon,
  bool? prefixIconBool = false,
  bool loading = false,
  IconData? prefixIcon,
}) {
  return SizedBox(
    height: height ?? SizeConfig.blockHeight * 6.5,
    child: TouchRippleEffect(
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.5),
      rippleColor: Colors.white60,
      child: InkWell(
        onTap: loading ? null : onPressed, // Disable button when loading
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.5),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? COLORS.primary,
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.5),
          ),
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.blockHeight * 2,
            horizontal: SizeConfig.blockWidth * 4,
          ),
          child: loading
              ? Center(
                  // Center the loading indicator
                  child: loadingIndicator(),
                )
              : Row(
                  mainAxisAlignment:
                      (prefixIconBool == false && showIcon == false)
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
                    ],
                    Flexible(
                      child: Text(
                        text.tr(),
                        style: TextStyle(
                          color: textColor ?? COLORS.white,
                          fontSize: SizeConfig.blockWidth * 3.8,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                        overflow: TextOverflow.clip,
                        softWrap: true,
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
    ),
  );
}

Widget customIconButton(
    {required String text,
    IconData? icon,
    required VoidCallback onPressed,
    required double? width,
    required double? height,
    required Color? backgroundColor,
    required Color? textColor,
    Color? iconColor,
    required bool showIcon,
    bool? prefixIconBool = false,
    bool? image = false,
    Widget? imageChild,
    IconData? prefixIcon}) {
  return SizedBox(
    width: width ?? double.infinity,
    height: height ?? SizeConfig.blockHeight * 6.5,
    child: TouchRippleEffect(
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
      rippleColor: Colors.white60,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? COLORS.primary,
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
          ),
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.blockHeight * 2,
            horizontal: SizeConfig.blockWidth * 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showIcon && icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? COLORS.white,
                  size: SizeConfig.blockWidth * 5,
                ),
                SizedBox(width: SizeConfig.blockWidth * 2),
              ],
              if (image == true) ...[imageChild!],
              Text(
                text.tr(),
                style: TextStyle(
                  color: textColor ?? COLORS.white,
                  fontSize: SizeConfig.blockWidth * 3.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          ),
        ),
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

Widget buildGenderSelection(
    {required void Function(String?)? onChanged, required String? groupValue}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      registerText(text: 'select_gender'.tr()),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio<String>(
                value: 'Male',
                groupValue: groupValue,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: const WidgetStatePropertyAll(COLORS.primary),
              ),
              Text(
                'Male'.tr(),
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 3.8,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          ),
          SizedBox(width: SizeConfig.blockWidth * 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio<String>(
                value: 'Female',
                groupValue: groupValue,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: const WidgetStatePropertyAll(COLORS.primary),
              ),
              Text(
                'Female'.tr(),
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 3.8,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final bool showLeadingIcon;
  final VoidCallback? onBackPress;
  final Color? titleColors;
  final bool? borderColor;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.backgroundColor = COLORS.primaryTwo,
      this.showLeadingIcon = true,
      this.onBackPress,
      this.titleColors = COLORS.white,
      this.borderColor = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      centerTitle: true,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: COLORS.neutralDarkTwo,
          height: borderColor!
              ? SizeConfig.blockHeight * 0.015
              : SizeConfig.blockHeight * 0.2,
        ),
      ),
      leading: showLeadingIcon
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_sharp,
                color: titleColors,
                size: SizeConfig.blockWidth * 4.5,
              ),
              onPressed: onBackPress ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title.tr(),
        style: TextStyle(
          color: titleColors,
          fontSize: SizeConfig.blockWidth * 4.25,
          fontWeight: FontWeight.w500,
          fontFamily: "Poppins",
        ),
      ),
      toolbarHeight: SizeConfig.blockHeight * 20,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        SizeConfig.blockHeight * 10,
      );
}

Widget buildBioTextField(
    {required String label,
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    required String? Function(String?) onChanged,
    required bool error,
    required String title}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      registerText(text: title),
      normalTextField(
          hintText: hintText,
          controller: controller,
          inputType: TextInputType.text,
          onChanged: onChanged,
          validator: validator,
          fontWeight: FontWeight.w400,
          prefix: false,
          errorMessage: '',
          hasError: error,
          maxLines: 8),
    ],
  );
}

Widget buildProfessionalCard(
    {required String name,
    required String profession,
    required String location,
    required String languages,
    required String gender,
    required String price,
    required String paymentType,
    required bool contacted,
    required String jobType,
    required String experience,
    required VoidCallback onShowInterest,
    required String jobTypeImage,
    required String experienceImage,
    required String genderImage,
    required String language,
    required String languageImage}) {
  return Stack(
    children: [
      Container(
        width: SizeConfig.blockWidth * 100,
        padding: EdgeInsets.all(SizeConfig.blockWidth * 3.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
          color: COLORS.primaryOne.withOpacity(0.25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: SizeConfig.blockWidth * 10,
                  height: SizeConfig.blockWidth * 10,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: COLORS.primary,
                          width: SizeConfig.blockWidth * 0.15),
                      borderRadius: BorderRadius.all(
                          Radius.circular(SizeConfig.blockWidth * 2))),
                ),
                SizedBox(width: SizeConfig.blockWidth * 2),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 3.8,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: COLORS.accent,
                          size: SizeConfig.blockWidth * 3.5,
                        ),
                        SizedBox(width: SizeConfig.blockWidth * 1),
                        Text(
                          location,
                          style: TextStyle(
                            color: COLORS.neutralDarkOne,
                            fontSize: SizeConfig.blockWidth * 3,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.blockHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                    width: SizeConfig.blockWidth * 55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        registerTextCard(text: jobType, image: jobTypeImage),
                        registerTextCard(
                            text: experience, image: experienceImage),
                        registerTextCard(text: language, image: languageImage),
                        registerTextCard(text: gender, image: genderImage)
                      ],
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 4.2,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      'Per Session',
                      style: TextStyle(
                        color: COLORS.neutralDarkOne,
                        fontSize: SizeConfig.blockWidth * 2.5,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: SizeConfig.blockHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                customButton(
                  width: SizeConfig.blockWidth * 55,
                  text: contacted ? 'CONTACTED' : "CONTACT",
                  onPressed: () {},
                  backgroundColor:
                      contacted ? COLORS.semanticTwo : COLORS.primary,
                  showIcon: false,
                  textColor: COLORS.white,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconActionCard(
                      iconBool: false,
                      imageUrl: Image.asset(
                        'assets/images/profile/bookmark.png',
                        width: SizeConfig.blockWidth * 4.25,
                        height: SizeConfig.blockHeight * 4.25,
                        fit: BoxFit.contain,
                        color: COLORS.neutralDarkOne,
                      ),
                    ),
                    IconActionCard(
                      iconBool: false,
                      imageUrl: Image.asset(
                        'assets/images/home/share.png',
                        width: SizeConfig.blockWidth * 5.2,
                        height: SizeConfig.blockHeight * 5.2,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 3,
              vertical: SizeConfig.blockHeight * 1),
          decoration: BoxDecoration(
            color: COLORS.semanticTwo,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(SizeConfig.blockWidth * 4),
                topRight: Radius.circular(SizeConfig.blockWidth * 4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                color: COLORS.white,
                size: SizeConfig.blockWidth * 3.5,
              ),
              SizedBox(
                width: SizeConfig.blockWidth * 1.5,
              ),
              Text(
                'Verified'.tr(),
                style: TextStyle(
                  color: COLORS.white,
                  fontSize: SizeConfig.blockWidth * 3,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          ),
        ),
      )
    ],
  );
}

Widget buildDynamicRadioSelection({
  required List<Map<String, String>> options,
  required void Function(String?)? onChanged,
  required String? groupValue,
  required String title,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      registerText(text: title.tr()),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: options.map((option) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio<String>(
                value: option['value']!,
                groupValue: groupValue,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: const WidgetStatePropertyAll(COLORS.primary),
              ),
              Text(
                option['label']!.tr(),
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 3.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ],
  );
}

class IconActionCard extends StatelessWidget {
  final IconData? icon;
  final bool? iconBool;
  final Widget? imageUrl;
  final double? width;
  final double? height;
  final void Function()? onTap;

  const IconActionCard(
      {super.key,
      this.icon,
      this.iconBool = true,
      this.imageUrl,
      this.width,
      this.height,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width ?? SizeConfig.blockWidth * 11,
        height: height ?? SizeConfig.blockWidth * 11,
        margin: EdgeInsets.only(left: SizeConfig.blockWidth * 2),
        // padding: EdgeInsets.symmetric(
        //   vertical: SizeConfig.blockWidth * 1.5,
        //   horizontal: SizeConfig.blockWidth * 3,
        // ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
          color: COLORS.primaryOne.withOpacity(0.3),
        ),
        child: iconBool == true
            ? Icon(
                icon,
                size: SizeConfig.blockWidth * 5.5,
              )
            : Center(
                child: imageUrl,
              ),
      ),
    );
  }
}

Widget showInterestButton({
  required final void Function()? onTapIconOne,
  required final void Function()? onTapIconTwo,
  required VoidCallback onShowInterest,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      customIconButton(
          text: 'SHOW INTEREST',
          onPressed: onShowInterest,
          backgroundColor: COLORS.primary,
          showIcon: false,
          width: SizeConfig.blockWidth * 55,
          height: SizeConfig.blockHeight * 6.5,
          image: true,
          imageChild: Padding(
            padding: EdgeInsets.only(right: SizeConfig.blockWidth),
            child: Image.asset(
              'assets/images/profile/like.png',
              width: SizeConfig.blockWidth * 5, // Adjust size as needed
              height: SizeConfig.blockHeight * 5,
              fit: BoxFit.contain, color: COLORS.white,
            ),
          ),
          textColor: COLORS.white,
          icon: Icons.thumb_up_outlined),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconActionCard(
            onTap: onTapIconOne,
            iconBool: false,
            imageUrl: Image.asset(
              'assets/images/home/phone.png',
              width: SizeConfig.blockWidth * 4.25,
              height: SizeConfig.blockHeight * 4.25,
              fit: BoxFit.contain,
            ),
          ),
          IconActionCard(
            onTap: onTapIconTwo,
            iconBool: false,
            imageUrl: Image.asset(
              'assets/images/home/share.png',
              width: SizeConfig.blockWidth * 5.2,
              height: SizeConfig.blockHeight * 5.2,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    ],
  );
}

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  Color backgroundColor = COLORS.semantic,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(
        color: COLORS.neutralDark,
        fontSize: SizeConfig.blockWidth * 3.6,
        fontWeight: FontWeight.w500,
        fontFamily: "Poppins",
      ),
    ),
    backgroundColor: backgroundColor,
    padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockWidth * 8,
        vertical: SizeConfig.blockHeight * 2.5),
    duration: duration,
    action: action,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
