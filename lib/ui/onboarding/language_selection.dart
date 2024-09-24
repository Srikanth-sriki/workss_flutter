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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:works_app/components/colors.dart';
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
  }

  Future<void> _loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeCode = prefs.getString('selected_locale');
    if (localeCode != null) {
      List<String> localeParts = localeCode.split('_');
      if (localeParts.length == 2) {
        setState(() {
          selectedLocale = Locale(localeParts[0], localeParts[1]);
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_locale',
          '${selectedLocale!.languageCode}_${selectedLocale!.countryCode}');

      context.setLocale(selectedLocale!);

      if(widget.routeType == 'intro'){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(LocalConstant.initialLanguage, true);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const IntroSliderScreen()),
        );
      }
      else{
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const MainScreen()),
        );
      }

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
              fontSize: SizeConfig.blockWidth * 4.6,
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
                languageTile(const Locale('ta', 'IN'), 'தமிழ்', 'த'),
                languageTile(const Locale('te', 'IN'), 'తెలుగు', 'తె'),
                languageTile(const Locale('gu', 'IN'), 'ગુજરાતી', 'ગુ'),
                languageTile(const Locale('ml', 'IN'), 'മലയാളം', 'മ'),
                languageTile(const Locale('mr', 'IN'), 'मराठी', 'म'),
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

  Widget languageTile(Locale locale, String name, String header) {
    bool isSelected = selectedLocale == locale;
    return GestureDetector(
      onTap: () => toggleLocale(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(SizeConfig.blockWidth * 5),
        decoration: BoxDecoration(
            border: Border.all(
                color: isSelected ? COLORS.primary : COLORS.primaryOne),
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
            color: isSelected ? COLORS.primary : COLORS.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(header,
                style: TextStyle(
                    fontSize: SizeConfig.blockWidth * 6.5,
                    fontFamily: "Poppins",
                    color: isSelected ? COLORS.white : COLORS.primary,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: SizeConfig.blockHeight * 1.2),
            Text(name,
                style: TextStyle(
                  fontSize: SizeConfig.blockWidth * 4.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                  color: isSelected ? COLORS.white : COLORS.neutralDark,
                )),
          ],
        ),
      ),
    );
  }
}
