import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/ui/post_work/post_work.dart';

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
  late ProfessionalBloc professionalBloc;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
  }


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
    const HomeScreen(),
    const ProfessionalsScreen(),
    const PostWorkScreen(),
    const ProfileScreen(),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if(index == 1){
      professionalBloc.add(ProfessionalListEvent(
        page: 1,
        pageSize: 10,
        keyWord: "",
        profession: "",
        city: "",
        gender: "",
      ));
    }


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(

        height:  SizeConfig.blockHeight * 10,
        width: SizeConfig.blockWidth * 100,
        // decoration: const BoxDecoration(
        //   boxShadow: [
        //     BoxShadow(
        //       color: COLORS.black,
        //       spreadRadius: 1,
        //       blurRadius: 4,
        //       offset: Offset(2, 2),
        //     ),
        //   ],
        // ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: bottomTabIcon(icon: 'assets/images/bottom_tab/work.png'),
              label: 'Works'.tr(),
              activeIcon:
                  bottomTabIcon(icon: 'assets/images/bottom_tab/work_select.png'),
            ),
            BottomNavigationBarItem(
              icon: bottomTabIcon(icon: 'assets/images/bottom_tab/prop.png'),
              label: 'Pros'.tr(),
              activeIcon:
                  bottomTabIcon(icon: 'assets/images/bottom_tab/prop_select.png'),
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
