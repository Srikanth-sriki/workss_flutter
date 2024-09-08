import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/ui/onboarding/language_selection.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: COLORS.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Container(
          width: SizeConfig.screenWidth,
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 5,
              vertical: SizeConfig.blockHeight * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '.Workss',
                    style: TextStyle(
                      color: COLORS.primary,
                      fontSize: SizeConfig.blockWidth * 6,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>  const LanguageSelectionScreen(routeType: 'homo',)
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
                          margin:
                              EdgeInsets.only(right: SizeConfig.blockWidth * 2.8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 2.5),
                              color: COLORS.neutralDarkTwo.withOpacity(0.6)),
                          child: Image.asset(
                            'assets/images/home/translation.png',
                            width: SizeConfig.blockWidth * 5.5,
                            height: SizeConfig.blockWidth * 5.5,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockWidth * 2.5),
                            color: COLORS.neutralDarkTwo.withOpacity(0.6)),
                        child: Icon(
                          Icons.notifications_none,
                          size: SizeConfig.blockWidth * 5.5,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: SizeConfig.blockHeight * 4.5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: SizeConfig.blockWidth * 72,
                    height: SizeConfig.blockHeight * 9,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                        color: COLORS.neutralDarkTwo.withOpacity(0.6)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockWidth * 4),
                          child: Icon(
                            Icons.search,
                            color: COLORS.neutralDarkOne,
                            size: SizeConfig.blockWidth * 6,
                          ),
                        ),
                        Text(
                          'Search by Profession type',
                          style: TextStyle(
                            color: COLORS.neutralDarkOne,
                            fontSize: SizeConfig.blockWidth * 3,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                    height: SizeConfig.blockHeight * 9,
                    width: SizeConfig.blockHeight * 9,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 2.5),
                        color: COLORS.neutralDarkTwo.withOpacity(0.6)),
                    child: Image.asset(
                      'assets/images/home/filter.png',
                      width: SizeConfig.blockWidth * 5.5,
                      height: SizeConfig.blockWidth * 5.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              )
            ],
          ),
        )),
      ),
    );
  }
}
