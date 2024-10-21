import 'package:flutter/material.dart';
import 'package:works_app/global_helper/helper_function.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

// class WorkCard extends StatelessWidget {
//   final String title;
//   final String location;
//   final String timeAgo;
//   final String jobType;
//   final String experience;
//   final String language;
//   final String gender;
//   final VoidCallback onShowInterest;
//   final String jobTypeImage;
//   final String experienceImage;
//   final String languageImage;
//   final String genderImage;
//   final Widget actionRows;
//
//   const WorkCard(
//       {super.key,
//       required this.title,
//       required this.location,
//       required this.timeAgo,
//       required this.jobType,
//       required this.experience,
//       required this.onShowInterest,
//       required this.jobTypeImage,
//       required this.experienceImage,
//       required this.gender,
//       required this.genderImage,
//       required this.language,
//       required this.actionRows,
//       required this.languageImage});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: SizeConfig.blockWidth * 100,
//       margin: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 2),
//       padding: EdgeInsets.all(SizeConfig.blockWidth * 3.5),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//         color: COLORS.primaryOne.withOpacity(0.25),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: COLORS.neutralDark,
//                   fontSize: SizeConfig.blockWidth * 4.2,
//                   fontWeight: FontWeight.w500,
//                   fontFamily: "Poppins",
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(SizeConfig.blockWidth * 1.5),
//                 decoration: BoxDecoration(
//                   color: COLORS.primaryOne,
//                   borderRadius:
//                       BorderRadius.circular(SizeConfig.blockWidth * 1.5),
//                 ),
//                 child: Text(
//                   timeAgo,
//                   style: TextStyle(
//                     color: COLORS.neutralDark,
//                     fontSize: SizeConfig.blockWidth * 3.2,
//                     fontWeight: FontWeight.w500,
//                     fontFamily: "Poppins",
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               Icon(
//                 Icons.location_on_rounded,
//                 color: COLORS.accent,
//                 size: SizeConfig.blockWidth * 5.5,
//               ),
//               SizedBox(width: SizeConfig.blockWidth * 1.5),
//               Text(
//                 location,
//                 style: TextStyle(
//                   color: COLORS.neutralDarkOne,
//                   fontSize: SizeConfig.blockWidth * 3.5,
//                   fontWeight: FontWeight.w400,
//                   fontFamily: "Poppins",
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(
//             height: SizeConfig.blockHeight * 0.5,
//           ),
//           registerTextCard(text: jobType, image: jobTypeImage),
//           registerTextCard(text: experience, image: experienceImage),
//           registerTextCard(text: language, image: languageImage),
//           registerTextCard(text: gender, image: genderImage),
//           SizedBox(
//             height: SizeConfig.blockHeight,
//           ),
//           actionRows
//         ],
//       ),
//     );
//   }
// }

class IconAction extends StatelessWidget {
  final IconData icon;
  final Color? bgColor;
  final bool? changeColor;

  const IconAction(
      {super.key, required this.icon, this.bgColor, this.changeColor = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: SizeConfig.blockWidth * 2),
      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.5),
        color: changeColor == false
            ? COLORS.primaryOne.withOpacity(0.3)
            : bgColor?.withOpacity(0.3),
      ),
      child: Icon(
        icon,
        size: SizeConfig.blockWidth * 5.5,
        color: changeColor == false ? COLORS.black : bgColor,
      ),
    );
  }
}

Widget registerTextCard(
    {required String text,
    required String image,
    Color? color,
    double? textFontSize = 3.4,
    double? imageSize = 3.8,
    Color? textColor = COLORS.neutralDarkOne}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight * 0.25,
        horizontal: SizeConfig.blockWidth),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          image,
          width: SizeConfig.blockWidth * imageSize!,
          height: SizeConfig.blockWidth * imageSize!,
          color: color,
        ),
        SizedBox(width: SizeConfig.blockWidth * 2),
        Flexible(
          child: Text(
            capitalizeEachWord(text),
            style: TextStyle(
              color: textColor,
              fontSize: SizeConfig.blockWidth * textFontSize!,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 1,
          ),
        ),
      ],
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

Widget buildTextField(
    {required String label,
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    required String? Function(String?) onChanged,
    required bool error,
      Widget? prefixIcon,
    bool? prefix = false,
    void Function()? onTap,
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
          suffix: prefix!,
          errorMessage: '',
          hasError: error,
          suffixIcon: prefixIcon,
          onTap: onTap),
    ],
  );
}
