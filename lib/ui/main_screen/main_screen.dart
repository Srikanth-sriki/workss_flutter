import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:works_app/ui/post_work/post_work.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../home/home.dart';
import '../professional/professional.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ProfessionalsScreen(),
    // const ProfileScreen(),
    // HomeScreen(),
    // SearchScreen(),
    PostWorkScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: bottomTabIcon(icon: 'assets/images/login/hiring.png'),
            label: 'Works'.tr(),
            activeIcon:
                bottomTabIcon(icon: 'assets/images/login/hiring_select.png'),
          ),
          BottomNavigationBarItem(
            icon: bottomTabIcon(
                icon: 'assets/images/login/profession_select.png'),
            label: 'Pros'.tr(),
            activeIcon:
                bottomTabIcon(icon: 'assets/images/login/profession.png'),
          ),
          // BottomNavigationBarItem(
          //   icon: bottomTabIcon(icon: 'assets/images/bottom_tab/reel.png'),
          //   label: 'Clips',
          //   activeIcon:
          //       bottomTabIcon(icon: 'assets/images/bottom_tab/reel_select.png'),
          // ),
          // BottomNavigationBarItem(
          //   icon: bottomTabIcon(icon: 'assets/images/bottom_tab/chart.png'),
          //   label: 'Chat',
          //   activeIcon: bottomTabIcon(
          //       icon: 'assets/images/bottom_tab/chart_select.png'),
          // ),
          // BottomNavigationBarItem(
          //   icon: bottomTabIcon(icon: 'assets/images/bottom_tab/chart.png'),
          //   label: 'Chat',
          //   activeIcon: bottomTabIcon(
          //       icon: 'assets/images/bottom_tab/chart_select.png'),
          // ),
          BottomNavigationBarItem(
            icon: bottomTabIcon(icon: 'assets/images/bottom_tab/add_post.png'),
            label: 'Post Works'.tr(),
            activeIcon: bottomTabIcon(
                icon: 'assets/images/bottom_tab/add_post_select.png'),
          ),
          BottomNavigationBarItem(
            icon: bottomTabIcon(icon: 'assets/images/bottom_tab/profile.png'),
            label: 'Account'.tr(),
            activeIcon: bottomTabIcon(
                icon: 'assets/images/bottom_tab/profile_select.png'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
            color: COLORS.neutralDark,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w400,
            fontSize: SizeConfig.blockWidth * 3.2),
        unselectedLabelStyle: TextStyle(
            color: COLORS.neutralDarkOne,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w400,
            fontSize: SizeConfig.blockWidth * 3.2),
        unselectedItemColor: COLORS.neutralDarkOne,
        selectedItemColor: COLORS.neutralDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        backgroundColor: COLORS.white,
      ),
    );
  }
}


