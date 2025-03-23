import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/home/home_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/ui/chat/chat_main.dart';
import 'package:works_app/ui/post_work/post_work.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../components/colors.dart';
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

  late final Widget _cachedProfileScreen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments from Navigator
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
    switch (index) {
      case 0:
        return BlocProvider(
          create: (_) => HomeBloc()
            ..add(FetchHomeScreenEvent(
                page: 1,
                pageSize: 10,
                keyWord: '',
                profession: '',
                city: '',
                gender: '',
                currentLongitude: '',
                currentLatitude: '')),
          child: const HomeScreen(),
        );
      case 1:
        return BlocProvider(
          create: (_) => ProfessionalBloc()
            ..add(ProfessionalListEvent(
                page: 1,
                pageSize: 10,
                keyWord: "",
                profession: "",
                city: "",
                gender: "",
                currentLongitude: '',
                currentLatitude: '')),
          child: const ProfessionalsScreen(),
        );
      case 2:
        return const PostWorkScreen();
      case 3:
        return MultiBlocProvider(providers: [
          BlocProvider(
              create: (context) => FriendsBloc()
                ..add(
                    FetchFriendsListEvent(page: 1, pageSize: 10, keyWord: ''))),
          BlocProvider(create: (context) => ChartBloc()..add(const ChartListEvent()) )
        ], child: const ChatMainScreen());
      case 4:
        return _cachedProfileScreen;
      default:
        return BlocProvider(
          create: (_) => HomeBloc()
            ..add(FetchHomeScreenEvent(
                page: 1,
                pageSize: 10,
                keyWord: '',
                profession: '',
                city: '',
                gender: '',
                currentLongitude: '',
                currentLatitude: '')),
          child: const HomeScreen(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == 0) {
          bool shouldExit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: COLORS.white,
              title: Text(
                'Exit App',
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 4.25,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                ),
              ),
              content: Text('Are you sure you want to exit?',
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.6,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  )),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel',
                      style: TextStyle(
                        color: COLORS.primary,
                        fontSize: SizeConfig.blockWidth * 3.8,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      )),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Exit',
                      style: TextStyle(
                        color: COLORS.primary,
                        fontSize: SizeConfig.blockWidth * 3.8,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      )),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        } else {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
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
            BottomNavigationBarItem(
              icon: bottomTabIcon(icon: 'assets/images/bottom_tab/chart.png'),
              label: 'Chat'.tr(),
              activeIcon: bottomTabIcon(
                  icon: 'assets/images/bottom_tab/chart_select.png'),
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
