import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/home/home_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/ui/chat/chat_main.dart';
import 'package:works_app/ui/post_work/post_work.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../components/colors.dart';
import '../../components/config.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/fetch_profile_model.dart';
import '../home/home.dart';
import '../professional/professional.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  DateTime? _lastPressed;

  late final Widget _cachedProfileScreen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();


    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args.containsKey('selectedIndex')) {
      setState(() {
        _selectedIndex = args['selectedIndex'];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Cache the Profile screen with its Bloc
    _cachedProfileScreen = BlocProvider(
      create: (_) => ProfileBloc()..add(const FetchProfileEvent()),
      child: const ProfileScreen(),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getTabScreen(int index) {
    if (Config.profileCompleted) {
      switch (index) {
        case 0:
          return MultiBlocProvider(providers: [
            BlocProvider(
                create: (context) => FriendsBloc()
                  ..add(FetchFriendsAddListEvent(
                      page: 1, pageSize: 10, keyWord: ''))),
            BlocProvider(
                create: (context) => HomeBloc()
                  ..add(FetchHomeScreenEvent(
                      page: 1,
                      pageSize: 10,
                      keyWord: '',
                      profession: '',
                      city: '',
                      gender: '',
                      currentLongitude: '',
                      currentLatitude: '',knownLanguages: [],
                      experienceLevel: '')))
          ], child: const HomeScreen());
        case 1:
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => FriendsBloc()
                    ..add(FetchFriendsAddListEvent(
                        page: 1, pageSize: 10, keyWord: ''))),
              BlocProvider(
                create: (_) => ProfessionalBloc()
                  ..add(ProfessionalListEvent(
                      page: 1,
                      pageSize: 10,
                      keyWord: "",
                      profession: "",
                      city: "",
                      gender: "",
                      currentLongitude: '',knownLanguages: [],
                      currentLatitude: '')),
              )
            ],
            child: const ProfessionalsScreen(),
          );
        case 2:
          return const PostWorkScreen(
            arrowBack: false,
          );
        case 3:
          return MultiBlocProvider(providers: [
            BlocProvider(
                create: (context) => FriendsBloc()
                  ..add(FetchFriendsListEvent(
                      page: 1, pageSize: 10, keyWord: ''))),
            BlocProvider(
                create: (context) => ChartBloc()..add(const ChartListEvent()))
          ], child: const ChatMainScreen());
        case 4:
          return _cachedProfileScreen;
        default:
          return MultiBlocProvider(providers: [
            BlocProvider(
                create: (context) => FriendsBloc()
                  ..add(FetchFriendsAddListEvent(
                      page: 1, pageSize: 10, keyWord: ''))),
            BlocProvider(
                create: (context) => HomeBloc()
                  ..add(FetchHomeScreenEvent(
                      page: 1,
                      pageSize: 10,
                      keyWord: '',
                      profession: '',
                      city: '',
                      gender: '',
                      currentLongitude: '',
                      currentLatitude: '',
                      knownLanguages: [],
                      experienceLevel: ''
                  )))
          ], child: const HomeScreen());
      }
    } else {
      switch (index) {
        case 0:
          return MultiBlocProvider(providers: [
            BlocProvider(
                create: (context) => FriendsBloc()
                  ..add(FetchFriendsAddListEvent(
                      page: 1, pageSize: 10, keyWord: ''))),
            BlocProvider(
                create: (context) => HomeBloc()
                  ..add(FetchHomeScreenEvent(
                      page: 1,
                      pageSize: 10,
                      keyWord: '',
                      profession: '',
                      city: '',
                      gender: '',
                      currentLongitude: '',
                      currentLatitude: '',
                      knownLanguages: [],
                      experienceLevel: ''
                  )))
          ], child: const HomeScreen());
        case 1:
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => FriendsBloc()
                    ..add(FetchFriendsAddListEvent(
                        page: 1, pageSize: 10, keyWord: ''))),
              BlocProvider(
                create: (_) => ProfessionalBloc()
                  ..add(ProfessionalListEvent(
                      page: 1,
                      pageSize: 10,
                      keyWord: "",
                      profession: "",
                      city: "",
                      gender: "",
                      currentLongitude: '',
                      currentLatitude: '',knownLanguages: [],)),
              )
            ],
            child: const ProfessionalsScreen(),
          );
        case 2:
          return MultiBlocProvider(providers: [
            BlocProvider(
                create: (context) => FriendsBloc()
                  ..add(FetchFriendsListEvent(
                      page: 1, pageSize: 10, keyWord: ''))),
            BlocProvider(
                create: (context) => ChartBloc()..add(const ChartListEvent()))
          ], child: const ChatMainScreen());
        case 3:
          return _cachedProfileScreen;
        default:
          return MultiBlocProvider(providers: [
            BlocProvider(
                create: (context) => FriendsBloc()
                  ..add(FetchFriendsAddListEvent(
                      page: 1, pageSize: 10, keyWord: ''))),
            BlocProvider(
                create: (context) => HomeBloc()
                  ..add(FetchHomeScreenEvent(
                      page: 1,
                      pageSize: 10,
                      keyWord: '',
                      profession: '',
                      city: '',
                      gender: '',
                      currentLongitude: '',
                      currentLatitude: '', knownLanguages: [],
                      experienceLevel: '')))
          ], child: const HomeScreen());
      }
    }
  }

  Future<bool> _handlePop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Don't pop
    } else {
      final now = DateTime.now();
      if (_lastPressed == null || now.difference(_lastPressed!) > const Duration(seconds: 2)) {
        _lastPressed = now;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Press back again to exit',style: TextStyle(
            color: COLORS.neutralDark,
            fontSize: SizeConfig.blockWidth * 3,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),),backgroundColor: COLORS.primaryOne,),

        );
        // Fluttertoast.showToast(
        //   msg: "Press back again to exit",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.black87,
        //   textColor: Colors.white,
        // );
        return false;
      }
      return true; // Pop (exit app)
    }
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
        onPopInvokedWithResult: (didPop,result) async {
        if (!didPop) {
          bool shouldExit = await _handlePop();
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: _getTabScreen(_selectedIndex), // Dynamically create the screen
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: bottomTabIcon(icon: 'assets/images/bottom_tab/work_01.png'),
              label: 'Works'.tr(),
              activeIcon: bottomTabIcon(
                  icon: 'assets/images/bottom_tab/work_select_01.png'),
            ),
            BottomNavigationBarItem(
              icon: bottomTabIcon(icon: 'assets/images/bottom_tab/prop_01.png'),
              label: 'Pros'.tr(),
              activeIcon: bottomTabIcon(
                  icon: 'assets/images/bottom_tab/prop_select_01.png'),
            ),
            if (Config.profileCompleted) ...[
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/bottom_tab/add_post.png',
                  width: SizeConfig.blockWidth * 4.2,
                  height: SizeConfig.blockWidth * 4.2,
                  fit: BoxFit.contain,
                  color: COLORS.neutralDarkOne,
                ),
                label: 'Post Works'.tr(),
                activeIcon: bottomTabIcon(
                    icon: 'assets/images/bottom_tab/add_post_select.png'),
              ),
            ],
            BottomNavigationBarItem(
              icon: ValueListenableBuilder<bool>(
                valueListenable: Config.chatHasNewMessage,
                builder: (context, hasNewMessage, _) => Stack(
                  children: [
                    bottomTabIcon(icon: 'assets/images/bottom_tab/chart.png'),
                    if (hasNewMessage)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              label: 'Chat'.tr(),
              activeIcon: ValueListenableBuilder<bool>(
                valueListenable: Config.chatHasNewMessage,
                builder: (context, hasNewMessage, _) => Stack(
                  children: [
                    bottomTabIcon(icon: 'assets/images/bottom_tab/chart_select.png'),
                    if (hasNewMessage)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),


            BottomNavigationBarItem(
              icon: bottomTabIcon(
                  icon: 'assets/images/bottom_tab/profile_01.png'),
              label: 'Account'.tr(),
              activeIcon: bottomTabIcon(
                  icon: 'assets/images/bottom_tab/profile_select_01.png'),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          selectedLabelStyle: TextStyle(
              color: COLORS.neutralDark,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w400,
              height: SizeConfig.blockHeight * 0.25,
              fontSize: SizeConfig.blockWidth * 2.6),
          unselectedLabelStyle: TextStyle(
              color: COLORS.neutralDarkOne,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w400,
              height: SizeConfig.blockHeight * 0.25,
              fontSize: SizeConfig.blockWidth * 2.6),
          unselectedItemColor: COLORS.neutralDarkOne,
          selectedItemColor: COLORS.neutralDark,
          type: BottomNavigationBarType.fixed,
          elevation: 8.0,
          backgroundColor: COLORS.white,
        ),
      ),
    );
  }
}
