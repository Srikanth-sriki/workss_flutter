// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:works_app/components/colors.dart';
// import 'package:works_app/components/size_config.dart';
// import 'package:works_app/ui/onboarding/intro_slider.dart';
// import 'package:works_app/ui/onboarding/phone_number.dart';
//
// import '../../global_helper/reuse_widget.dart';
//
// class LanguageSelectionScreen extends StatefulWidget {
//   const LanguageSelectionScreen({super.key});
//
//   @override
//   _LanguageSelectionScreenState createState() =>
//       _LanguageSelectionScreenState();
// }
//
// class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
//   Locale? selectedLocale;
//
//
//
//   void toggleLocale(Locale locale) {
//     setState(() {
//       if (selectedLocale == locale) {
//         selectedLocale = null;
//       } else {
//         selectedLocale = locale;
//       }
//     });
//   }
//
//   void updateLanguage() {
//     if (selectedLocale != null) {
//       context.setLocale(selectedLocale!);
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (BuildContext context) => const IntroSliderScreen()),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: COLORS.white,
//       appBar: AppBar(
//         backgroundColor: COLORS.white,
//         toolbarHeight: SizeConfig.blockHeight * 15,
//         flexibleSpace: FlexibleSpaceBar(
//           titlePadding: EdgeInsets.fromLTRB(
//               SizeConfig.blockWidth * 4,
//               SizeConfig.blockHeight * 3.5,
//               SizeConfig.blockWidth * 4,
//               SizeConfig.blockHeight * 1.5),
//           title: Text(
//             'select_language'.tr(),
//             style: TextStyle(
//               color: COLORS.primaryTwo,
//               fontSize: SizeConfig.blockWidth * 4.6,
//               fontWeight: FontWeight.w400,
//               fontFamily: "Poppins",
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GridView.count(
//               crossAxisCount: 2,
//               crossAxisSpacing: SizeConfig.blockWidth * 4,
//               mainAxisSpacing: SizeConfig.blockWidth * 4,
//               padding: EdgeInsets.all(SizeConfig.blockWidth * 6),
//               children: [
//                 languageTile(const Locale('en', 'US'), 'English', 'A'),
//                 languageTile(const Locale('kn', 'IN'), 'ಕನ್ನಡ', 'ಕ'),
//                 languageTile(const Locale('hi', 'IN'), 'हिंदी', 'हिं'),
//                 languageTile(const Locale('ta', 'IN'), 'தமிழ்', 'த'),
//                 languageTile(const Locale('te', 'IN'), 'తెలుగు', 'తె'),
//                 languageTile(const Locale('gu', 'IN'), 'ગુજરાતી', 'ગુ'),
//                 languageTile(const Locale('ml', 'IN'), 'മലയാളം', 'മ'),
//                 languageTile(const Locale('mr', 'IN'), 'मराठी', 'म'),
//               ],
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(
//                     color: COLORS.neutralDarkOne,
//                     width: SizeConfig.blockWidth * 0.1),
//               ),
//               color: COLORS.white,
//             ),
//             padding: EdgeInsets.symmetric(
//                 vertical: SizeConfig.blockHeight * 2.5,
//                 horizontal: SizeConfig.blockWidth * 6),
//             child: customButton(
//                 text: 'submit'.tr(),
//                 onPressed: updateLanguage,
//                 backgroundColor: COLORS.primary,
//                 showIcon: false,
//                 width: SizeConfig.blockWidth * 100,
//                 height: SizeConfig.blockHeight * 8,
//                 textColor: COLORS.white,
//                 prefixIconBool: false),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget languageTile(Locale locale, String name, String header) {
//     bool isSelected = selectedLocale == locale;
//     return GestureDetector(
//       onTap: () => toggleLocale(locale),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(SizeConfig.blockWidth * 5),
//         decoration: BoxDecoration(
//             border: Border.all(
//                 color: isSelected ? COLORS.primary : COLORS.primaryOne),
//             borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//             color: isSelected ? COLORS.primary : COLORS.white),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(header,
//                 style: TextStyle(
//                     fontSize: SizeConfig.blockWidth * 6.5,
//                     fontFamily: "Poppins",
//                     color: isSelected ? COLORS.white : COLORS.primary,
//                     fontWeight: FontWeight.w700)),
//             SizedBox(height: SizeConfig.blockHeight * 1.2),
//             Text(name,
//                 style: TextStyle(
//                   fontSize: SizeConfig.blockWidth * 4.5,
//                   fontWeight: FontWeight.w400,
//                   fontFamily: "Poppins",
//                   color: isSelected ? COLORS.white : COLORS.neutralDark,
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/storage_service.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/config.dart';
import 'package:works_app/components/local_constant.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/home/home.dart';
import 'package:works_app/ui/main_screen/main_screen.dart';
import 'package:works_app/ui/onboarding/intro_slider.dart';
import '../../global_helper/reuse_widget.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String routeType;
  const LanguageSelectionScreen({super.key,required this.routeType});

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Locale? selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
    print(Config.languageSelected);
  }

  Future<void> _loadSavedLocale() async {
    String? localeCode = StorageService.getString('selected_locale');
    if (localeCode != null) {
      List<String> localeParts = localeCode.split('_');
      if (localeParts.length == 2) {
        setState(() {
          selectedLocale = Locale(localeParts[0], localeParts[1]);
          Config.languageSelected = Locale(localeParts[0]).toString();
        });
      }
    }
  }

  void toggleLocale(Locale locale) {
    setState(() {
      if (selectedLocale == locale) {
        selectedLocale = null;
      } else {
        selectedLocale = locale;
      }
    });
  }

  Future<void> updateLanguage() async {
    if (selectedLocale != null) {
      await StorageService.setString(LocalConstant.localLanguageSelected, selectedLocale!.languageCode);
      await StorageService.setString('selected_locale',
          '${selectedLocale!.languageCode}_${selectedLocale!.countryCode}');

      context.setLocale(selectedLocale!);
      setState(() {
        Config.languageSelected = selectedLocale!.languageCode;
      });

      if(widget.routeType == 'intro'){
        await StorageService.setBool(LocalConstant.initialLanguage, true);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const IntroSliderScreen()),
        );
      }
      else{
        Navigator.pushNamed(context, '/main_screen');
      }

    }
    else{
      showCustomSnackBar(
          context: context,
          message: 'Please select a language',
          backgroundColor: COLORS.primaryOne);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: COLORS.white,
        toolbarHeight: SizeConfig.blockHeight * 15,
        scrolledUnderElevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.fromLTRB(
              SizeConfig.blockWidth * 4,
              SizeConfig.blockHeight * 3.5,
              SizeConfig.blockWidth * 4,
              SizeConfig.blockHeight * 1.5),
          title: Text(
            'select_language'.tr(),
            style: TextStyle(
              color: COLORS.primaryTwo,
              fontSize: SizeConfig.blockWidth * 4.25,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: SizeConfig.blockWidth * 4,
              mainAxisSpacing: SizeConfig.blockWidth * 4,
              padding: EdgeInsets.all(SizeConfig.blockWidth * 6),
              children: [
                languageTile(const Locale('en', 'US'), 'English', 'A'),
                languageTile(const Locale('kn', 'IN'), 'ಕನ್ನಡ', 'ಕ'),
                languageTile(const Locale('hi', 'IN'), 'हिंदी', 'हिं'),
                languageTile(const Locale('ta', 'IN'), 'தமிழ்', 'த',enabled: false),
                languageTile(const Locale('te', 'IN'), 'తెలుగు', 'తె',enabled: false),
                // languageTile(const Locale('gu', 'IN'), 'ગુજરાતી', 'ગુ'),
                languageTile(const Locale('ml', 'IN'), 'മലയാളം', 'മ',enabled: false),
                // languageTile(const Locale('mr', 'IN'), 'मराठी', 'म'),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: COLORS.neutralDarkOne.withOpacity(0.5),
                    width: SizeConfig.blockWidth * 0.1),
              ),
              color: COLORS.white,
            ),
            padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockHeight * 2.5,
                horizontal: SizeConfig.blockWidth * 6),
            child: customButton(
                text: 'submit'.tr(),
                onPressed: updateLanguage,
                backgroundColor: COLORS.primary,
                showIcon: false,
                width: SizeConfig.blockWidth * 100,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
                prefixIconBool: false),
          ),
        ],
      ),
    );
  }

  // Widget languageTile(Locale locale, String name, String header) {
  //   bool isSelected = selectedLocale == locale;
  //   return GestureDetector(
  //     onTap: () => toggleLocale(locale),
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 500),
  //       curve: Curves.easeInOut,
  //       padding: EdgeInsets.all(SizeConfig.blockWidth * 5),
  //       decoration: BoxDecoration(
  //           border: Border.all(
  //               color: isSelected ? COLORS.primary : COLORS.primaryOne),
  //           borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
  //           color: isSelected ? COLORS.primary : COLORS.white),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(header,
  //               style: TextStyle(
  //                   fontSize: SizeConfig.blockWidth * 6.8,
  //                   fontFamily: "Poppins",
  //                   color: isSelected ? COLORS.white : COLORS.primary,
  //                   fontWeight: FontWeight.w700)),
  //           SizedBox(height: SizeConfig.blockHeight * 1.2),
  //           Text(name,
  //               style: TextStyle(
  //                 fontSize: SizeConfig.blockWidth * 4.5,
  //                 fontWeight: FontWeight.w400,
  //                 fontFamily: "Poppins",
  //                 color: isSelected ? COLORS.white : COLORS.neutralDark,
  //               )),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget languageTile(
      Locale locale,
      String name,
      String header, {
        bool enabled = true,
      }) {
    final bool isSelected = selectedLocale == locale;

    final Color borderColor = !enabled
        ? COLORS.neutralDarkOne.withOpacity(0.25)
        : (isSelected ? COLORS.primary : COLORS.primaryOne);

    final Color bgColor = !enabled
        ? COLORS.neutralDarkTwo.withOpacity(0.08)
        : (isSelected ? COLORS.primary : COLORS.white);

    final Color headerColor = !enabled
        ? COLORS.neutralDark.withOpacity(0.4)
        : (isSelected ? COLORS.white : COLORS.primary);

    final Color nameColor = !enabled
        ? COLORS.neutralDark.withOpacity(0.4)
        : (isSelected ? COLORS.white : COLORS.neutralDark);

    return Semantics(
      button: true,
      enabled: enabled,
      label: name,
      child: GestureDetector(
        onTap: () {
          if (enabled) {
            toggleLocale(locale);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(SizeConfig.blockWidth * 5),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
            color: bgColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                header,
                style: TextStyle(
                  fontSize: SizeConfig.blockWidth * 6.8,
                  fontFamily: "Poppins",
                  color: headerColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 1.2),
              Text(
                name,
                style: TextStyle(
                  fontSize: SizeConfig.blockWidth * 4.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                  color: nameColor,
                ),
              ),
              if (!enabled) ...[
                SizedBox(height: SizeConfig.blockHeight * 1.2),
                Text(
                  'Coming soon',
                  style: TextStyle(
                    fontSize: SizeConfig.blockWidth * 3.2,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                    color: COLORS.neutralDark.withOpacity(0.45),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}
