import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:works_app/bloc/professional/professional_bloc.dart';
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
import 'bloc/post_work/post_work_bloc.dart';
import 'bloc/register_account/initial_register_bloc.dart';
import 'bloc/show_interested/show_interested_bloc.dart';
import 'components/config.dart';
import 'components/global_handle.dart';
import 'firebase/events.dart';
import 'firebase/locator.dart';
import 'firebase/notification.dart';


AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCqK_rQ6jRbUPLjhx1xaLRNbrwoy9byANs',
      appId: '1:389975309389:android:a6e07ea0a9ec26d3123004',
      messagingSenderId: '389975309389',
      projectId: 'workss-app',
      storageBucket: 'workss-app.appspot.com',
    ),
  );

  print("Handling a background message: ${message.messageId}");
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCqK_rQ6jRbUPLjhx1xaLRNbrwoy9byANs',
      appId: '1:389975309389:android:a6e07ea0a9ec26d3123004',
      messagingSenderId: '389975309389',
      projectId: 'workss-app',
      storageBucket: 'workss-app.appspot.com',
    ),
  );
  setupLocator();
  // Other setup code

  // Firebase Crashlytics setup
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };
  //
  // // Firebase Messaging setup
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Ensure localization is initialized
  await EasyLocalization.ensureInitialized();

  // Start the app
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
      child: MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {

  const MyApp({Key? key,}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final analyticsService = locator<AnalyticsService>();
  @override
  void initState() {
    super.initState();
    requestPermission();
    print('-----------------------------check notification');
    getMessage(context);
    analyticsService.logScreenEvent('main_screen');
     initializeNotifications(context);
  }


  ///permission for notifications
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
  //Function for notification handling
  void getMessage(BuildContext context) async{
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.instance.getToken().then((value)  {
      final String apnId=value!;
      print("Fcm token:....... $apnId");
      Config.fcmToken = apnId;
    });

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
    ));
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return  OverlaySupport.global(
      child: MaterialApp(
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
        routes: {
          "/authentication": (context) => BlocProvider(
            create: (context) =>
            AuthenticationBloc()..add(const InitializeApp()),
            child: const Authentication(),
          ),
          "/main_screen": (context) => MultiBlocProvider(
              providers: [
                BlocProvider(
                    create: (context) => HomeBloc()
                      ..add(FetchHomeScreenEvent(
                          page: 1,
                          pageSize: 20,
                          profession: '',
                          keyWord: '',
                          city: '',
                          gender: ''))),
                BlocProvider(create: (context) => ProfessionalBloc()),
                BlocProvider(create: (context) => ProfileBloc()..add(const FetchProfileEvent())),
                BlocProvider(create: (context) => ShowInterestedBloc()),
                BlocProvider(create: (context) => PostWorkBloc(),),
                BlocProvider(create: (context) => ShowInterestedBloc(),),
              ],
              child: const MainScreen()
          ),
        },
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
            return const SelectUserType();
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
              BlocProvider(create: (context) => ProfessionalBloc()),
              BlocProvider(create: (context) => ProfileBloc()..add(const FetchProfileEvent())),
              BlocProvider(create: (context) => ShowInterestedBloc()),
              BlocProvider(create: (context) => PostWorkBloc(),),
              BlocProvider(create: (context) => ShowInterestedBloc(),),
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
