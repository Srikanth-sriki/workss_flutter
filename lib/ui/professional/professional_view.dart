import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/size_config.dart';

import '../../components/colors.dart';

class ProfessionalViewScreen extends StatefulWidget {
  const ProfessionalViewScreen({super.key});

  @override
  State<ProfessionalViewScreen> createState() => _ProfessionalViewScreenState();
}

class _ProfessionalViewScreenState extends State<ProfessionalViewScreen> {
  final bool saved = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(toolbarHeight: 0,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*4.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          color: COLORS.black, size: SizeConfig.blockWidth * 4.5),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: SizeConfig.blockWidth * 12,
                          height: SizeConfig.blockWidth * 12,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: COLORS.primary,
                                  width: SizeConfig.blockWidth * 0.2),
                              // image: DecorationImage(
                              //     image: NetworkImage(image), fit: BoxFit.cover),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(SizeConfig.blockWidth * 2))),
                        ),
                        SizedBox(width: SizeConfig.blockWidth * 2),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'name',
                              style: TextStyle(
                                color: COLORS.neutralDark,
                                fontSize: SizeConfig.blockWidth * 3.8,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: COLORS.accent,
                                  size: SizeConfig.blockWidth * 3.5,
                                ),
                                SizedBox(width: SizeConfig.blockWidth * 1),
                                Text(
                                  'location',
                                  style: TextStyle(
                                    color: COLORS.neutralDarkOne,
                                    fontSize: SizeConfig.blockWidth * 3,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Image.asset(
                      saved
                          ? 'assets/images/professions/bookmarked.png'
                          : 'assets/images/profile/bookmark.png',
                      width: saved
                          ? SizeConfig.blockWidth * 5.25
                          : SizeConfig.blockWidth * 4.25,
                      height: saved
                          ? SizeConfig.blockHeight * 5.25
                          : SizeConfig.blockHeight * 4.25,
                      fit: BoxFit.contain,
                      color: saved ? COLORS.accent : COLORS.neutralDarkOne,
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert,
                          color: COLORS.black, size: SizeConfig.blockWidth * 6.5),
                      onPressed: () {
                        // Add functionality for more button
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
