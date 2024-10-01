import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/main_screen/main_screen.dart';
import 'package:works_app/ui/onboarding/intro_slider.dart';
import 'package:works_app/ui/onboarding/language_selection.dart';
import 'package:works_app/ui/onboarding/phone_number.dart';
import 'package:works_app/ui/onboarding/register_form.dart';
import 'package:works_app/ui/onboarding/select_user_type.dart';
import 'package:works_app/ui/onboarding/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';

import 'bloc/authentication/authentication_bloc.dart';
import 'bloc/home/home_bloc.dart';
import 'bloc/login/login_bloc.dart';
import 'bloc/register_account/initial_register_bloc.dart';
import 'components/global_handle.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: SplashScreen(),
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.0),
      ),
    );
  }
}

class Authentication extends StatefulWidget {
  const Authentication({Key? key}) : super(key: key);

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  late AuthenticationBloc authenticationBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GlobalBlocClass.authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);
    GlobalBlocClass.authenticationContext = context;
    authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocBuilder(
        bloc: authenticationBloc,
        builder: (context, state) {
          if (state is AuthenticationLoading) {
            print("auth loading ------------");
            return const SplashScreen();
          }
          if (state is AuthenticationLoginRequired) {
            print("auth phone ------------");
            return MultiBlocProvider(providers: [
              BlocProvider(
                create: (context) => LoginBloc(),
              ),
            ], child: const LoginScreen());
          }
          if (state is AuthenticationProfileRequired) {
            print("auth profile ------------");
            return SelectUserType();
          }
          if (state is AuthenticationHomeScreen) {
            print("auth home ");
            return MultiBlocProvider(providers: [
              BlocProvider(
                  create: (context) => HomeBloc()
                    ..add(FetchHomeScreenEvent(
                        page: 1,
                        pageSize: 20,
                        profession: '',
                        keyWord: '',
                        city: '',
                        gender: ''))),
              //   BlocProvider(create: (context) => BookMarkBloc()..add(FetchBookMarkEvent(pageNumber: 0))),
              //   BlocProvider(create: (context) => CartListBloc()..add( const FetchCartList())),
              //   BlocProvider(create: (context) => AddCartBloc(),),
              //   BlocProvider(create: (context) => SearchBloc(),),
              BlocProvider(
                  create: (context) =>
                      ProfileBloc()..add(const FetchProfileEvent())),
              //   BlocProvider(create: (context) => AuthenticationBloc(),),
              //   BlocProvider(create: (context) => FetchSiteDetailsBloc()..add(const FetchSiteDetailEvent())),
              //   BlocProvider(create: (context) => TermsAndConditionBloc()..add(const FetchTermsAndConditionEvent())),
            ], child: const MainScreen());
          }
          return MultiBlocProvider(providers: [
            BlocProvider(
              create: (context) => LoginBloc(),
            ),
          ], child: const LoginScreen());
        });
  }
}
