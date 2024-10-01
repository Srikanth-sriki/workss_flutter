import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:works_app/ui/post_work/post_work.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/fetch_profile_model.dart';
import '../home/home.dart';
import '../professional/professional.dart';
import '../profile/profile_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  late ProfileBloc profileBloc;





  void returnHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  void returnProfile() {
    setState(() {
      _selectedIndex = 3;
    });
  }

  final List<Widget> _pages = [
     HomeScreen(),
    const ProfessionalsScreen(),
    PostWorkScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {

    // if(index ==3){
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => BlocProvider(
    //               create: (context) => ProfileBloc()..add(const FetchProfileEvent()),
    //               child: const ProfileScreen())));
    // }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        ///Will not loose state of other pages
        index: _selectedIndex,
        children: _pages,
      ),
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
            fontSize: SizeConfig.blockWidth * 3),
        unselectedLabelStyle: TextStyle(
            color: COLORS.neutralDarkOne,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w400,
            fontSize: SizeConfig.blockWidth * 3),
        unselectedItemColor: COLORS.neutralDarkOne,
        selectedItemColor: COLORS.neutralDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        backgroundColor: COLORS.white,
      ),
    );
  }
}

