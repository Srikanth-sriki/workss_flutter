import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/main_screen/main_screen.dart';
import 'package:works_app/ui/onboarding/intro_slider.dart';
import 'package:works_app/ui/onboarding/language_selection.dart';
import 'package:works_app/ui/onboarding/register_form.dart';
import 'package:works_app/ui/onboarding/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';


Future<void> main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('kn', 'IN'),
        Locale('hi', 'IN'),
        Locale('ta', 'IN'),
        Locale('te', 'IN'),
        Locale('gu', 'IN'),
        Locale('ml', 'IN'),
        Locale('mr', 'IN'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        SizeConfig().init(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: const SplashScreen(),
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.0),
      ),
    );
  }
}
