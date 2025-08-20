import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:works_app/firebase/notification.dart';
import 'package:works_app/ui/chat/chat_main.dart';
import 'package:works_app/ui/post_work/post_work.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../components/colors.dart';
import '../../components/config.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../home/home.dart';
import '../professional/professional.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  DateTime? _lastPressed;

  // cache profile
  late final Widget _cachedProfileScreen;

  // keep tab widgets so they’re not rebuilt
  late List<Widget> _tabs;

  // create blocs once (and dispose with the screen)
  late final FriendsBloc _friendsBlocForHome;
  late final HomeBloc _homeBloc;

  late final FriendsBloc _friendsBlocForPros;
  late final ProfessionalBloc _professionalBloc;

  // Chat tab blocs (or let ChatMainScreen create/fetch its own)
  late final FriendsBloc _friendsBlocForChat;
  late final ChartBloc _chartBloc;

  // 🔔 focus notifier for the Chat tab
  final ValueNotifier<bool> _chatFocus = ValueNotifier<bool>(false);

  bool _routeArgsApplied = false;

  // computed index for Chat tab depending on profileCompleted
  int get _chatTabIndex => Config.profileCompleted ? 3 : 2;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeNotifications(context);
      // read route args once, after first frame
      if (!_routeArgsApplied) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('selectedIndex')) {
          final idx = args['selectedIndex'] as int? ?? 0;
          if (idx != _selectedIndex) {
            setState(() => _selectedIndex = idx);
          }
        }
        _routeArgsApplied = true;
      }

      // set initial focus state
      _chatFocus.value = (_selectedIndex == _chatTabIndex);
    });

    // create blocs ONCE
    _friendsBlocForHome = FriendsBloc()
      ..add(FetchFriendsAddListEvent(page: 1, pageSize: 10, keyWord: ''));
    _homeBloc = HomeBloc()
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
        experienceLevel: '',
      ));

    _friendsBlocForPros = FriendsBloc()
      ..add(FetchFriendsAddListEvent(page: 1, pageSize: 10, keyWord: ''));
    _professionalBloc = ProfessionalBloc()
      ..add(ProfessionalListEvent(
        page: 1,
        pageSize: 10,
        keyWord: '',
        profession: '',
        city: '',
        gender: '',
        currentLongitude: '',
        currentLatitude: '',
        knownLanguages: [],
      ));

    _friendsBlocForChat = FriendsBloc()
      ..add(FetchFriendsListEvent(page: 1, pageSize: 10, keyWord: ''));
    _chartBloc = ChartBloc();

    // cache profile
    _cachedProfileScreen = BlocProvider(
      create: (_) => ProfileBloc()..add(const FetchProfileEvent()),
      child: const ProfileScreen(),
    );

    // build tabs ONCE
    _tabs = _buildTabs();
  }

  List<Widget> _buildTabs() {
    final homeTab = MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _friendsBlocForHome),
        BlocProvider.value(value: _homeBloc),
      ],
      child: const HomeScreen(),
    );

    final prosTab = MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _friendsBlocForPros),
        BlocProvider.value(value: _professionalBloc),
        BlocProvider(
            create: (_) =>
                ChartBloc()), // if Professionals needs ChartBloc separately
      ],
      child: const ProfessionalsScreen(),
    );

    final postWorkTab = const PostWorkScreen(arrowBack: false);

    final chatTab = MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _friendsBlocForChat),
        BlocProvider.value(value: _chartBloc),
      ],
      // 👇 pass the focus notifier to the chat tab
      child: ChatMainScreen(chatFocus: _chatFocus),
    );

    if (Config.profileCompleted) {
      return [
        homeTab, // 0
        prosTab, // 1
        postWorkTab, // 2
        chatTab, // 3
        _cachedProfileScreen, // 4
      ];
    } else {
      return [
        homeTab, // 0
        prosTab, // 1
        chatTab, // 2  (no post work)
        _cachedProfileScreen, // 3
      ];
    }
  }

  @override
  void dispose() {
    _friendsBlocForHome.close();
    _homeBloc.close();
    _friendsBlocForPros.close();
    _professionalBloc.close();
    _friendsBlocForChat.close();
    _chartBloc.close();
    _chatFocus.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // guard: no-op if same tab tapped
    setState(() => _selectedIndex = index);
    // update focus state for chat tab
    _chatFocus.value = (index == _chatTabIndex);
    // optional: clear red dot when user navigates to chat
    if (index == _chatTabIndex) {
      Config.chatHasNewMessage.value = false;
    }
  }

  Future<bool> _handlePop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      _chatFocus.value = (_selectedIndex == _chatTabIndex);
      return false;
    } else {
      final now = DateTime.now();
      if (_lastPressed == null ||
          now.difference(_lastPressed!) > const Duration(seconds: 2)) {
        _lastPressed = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Press back again to exit',
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 3,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
            ),
            backgroundColor: COLORS.primaryOne,
          ),
        );
        return false;
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await _handlePop();
          if (shouldExit) SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,

        // 🔒 Persist tab widgets and their blocs
        body: IndexedStack(
          index: _selectedIndex,
          children: _tabs,
        ),

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
            if (Config.profileCompleted)
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
                          width: SizeConfig.blockWidth * 2.5,
                          height: SizeConfig.blockWidth * 2.5,
                          decoration: const BoxDecoration(
                              color: COLORS.semantic, shape: BoxShape.circle),
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
                    bottomTabIcon(
                        icon: 'assets/images/bottom_tab/chart_select.png'),
                    if (hasNewMessage)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                            width: SizeConfig.blockWidth * 2,
                            height: SizeConfig.blockWidth * 2,
                            decoration: const BoxDecoration(
                                color: COLORS.semantic,
                                shape: BoxShape.circle)),
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
            fontSize: SizeConfig.blockWidth * 2.6,
          ),
          unselectedLabelStyle: TextStyle(
            color: COLORS.neutralDarkOne,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w400,
            height: SizeConfig.blockHeight * 0.25,
            fontSize: SizeConfig.blockWidth * 2.6,
          ),
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
