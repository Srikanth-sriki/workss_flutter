import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/ui/home/component.dart';
import 'package:works_app/ui/onboarding/language_selection.dart';
import 'package:works_app/ui/professional/categories.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../home/filter.dart';
import 'categories_item.dart';

class ProfessionalsScreen extends StatefulWidget {
  const ProfessionalsScreen({super.key});

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  final List<Map<String, dynamic>> categoriesData = [
    {
      'title': 'Construction',
      'images': 'assets/images/professions/cat1.png',
      'pro': [
        'Architect',
        'Carpenter',
        'Civil Engineer',
        'Construction Worker',
        'Construction engineering'
      ]
    },
    {
      'title': 'Tutors',
      'images': 'assets/images/professions/cat2.png',
      'pro': [
        'Architect',
        'Carpenter',
        'Civil Engineer',
        'Construction Worker',
        'Construction engineering'
      ]
    },
    {
      'title': 'Automobile',
      'images': 'assets/images/professions/cat3.png',
      'pro': [
        'Architect',
        'Carpenter',
        'Civil Engineer',
        'Construction Worker',
        'Construction engineering'
      ]
    },
    {
      'title': 'Music teacher',
      'images': 'assets/images/professions/cat2.png',
      'pro': [
        'Architect',
        'Carpenter',
        'Civil Engineer',
        'Construction Worker',
        'Construction engineering'
      ]
    },
    {
      'title': 'Driver',
      'images': 'assets/images/professions/cat1.png',
      'pro': [
        'Architect',
        'Carpenter',
        'Civil Engineer',
        'Construction Worker',
        'Construction engineering'
      ]
    },
    {
      'title': 'Self defense',
      'images': 'assets/images/professions/cat3.png',
      'pro': [
        'Architect',
        'Carpenter',
        'Civil Engineer',
        'Construction Worker',
        'Construction engineering'
      ]
    },
  ];

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
          padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 5,
                ),
                child: Row(
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const LanguageSelectionScreen(
                                        routeType: 'homo',
                                      )),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
                            margin: EdgeInsets.only(
                                right: SizeConfig.blockWidth * 2.8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 2.5),
                                color: COLORS.primaryOne.withOpacity(0.3)),
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
                              color: COLORS.primaryOne.withOpacity(0.3)),
                          child: Icon(
                            Icons.notifications_none,
                            size: SizeConfig.blockWidth * 5.5,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockHeight * 3.5,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: SizeConfig.blockWidth * 72,
                      height: SizeConfig.blockHeight * 8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              SizeConfig.blockWidth * 3.25),
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
                            'Search by Profession type'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 3.3,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showMaterialModalBottomSheet(
                          enableDrag: true,
                          expand: false,
                          isDismissible: true,
                          backgroundColor: COLORS.white,
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => SearchFilterBottomSheet(),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                        height: SizeConfig.blockHeight * 8,
                        width: SizeConfig.blockHeight * 8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockWidth * 2.5),
                            color: COLORS.neutralDarkTwo.withOpacity(0.6)),
                        child: Image.asset(
                          'assets/images/home/filter.png',
                          width: SizeConfig.blockWidth * 5.5,
                          height: SizeConfig.blockWidth * 5.5,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockHeight * 1.5),
                child: Divider(
                  height: SizeConfig.blockHeight,
                  color: COLORS.neutralDarkTwo,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Categories'.tr(),
                          style: TextStyle(
                            color: COLORS.neutralDark,
                            fontSize: SizeConfig.blockWidth * 4,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CategoriesScreen(
                                          categoriesData: categoriesData)),
                            );
                          },
                          child: Text(
                            'See All'.tr(),
                            style: TextStyle(
                              color: COLORS.accent,
                              fontSize: SizeConfig.blockWidth * 4,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: SizeConfig.blockHeight * 20,
                    child: ListView.builder(
                        itemCount: categoriesData.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockWidth * 5),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CategoriesItemScreen(
                                            categoriesItem:
                                            categoriesData[index])),
                              );
                            },
                            child: Padding(
                              padding:  EdgeInsets.all(SizeConfig.blockWidth*3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: SizeConfig.blockWidth * 20,
                                    height: SizeConfig.blockWidth * 20,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              categoriesData[index]['images']),
                                          fit: BoxFit.contain,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.blockWidth * 20),
                                        color:
                                            COLORS.primaryOne.withOpacity(0.5)),
                                  ),
                                  SizedBox(
                                    height: SizeConfig.blockHeight * 0.5,
                                  ),

                                  Text(
                                    categoriesData[index]['title'],
                                    style: TextStyle(
                                      color: COLORS.neutralDark,
                                      fontSize: SizeConfig.blockWidth * 3,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Poppins",
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 5,
                    ),
                    child: Text(
                      'Professionals'.tr(),
                      style: TextStyle(
                        color: COLORS.neutralDarkOne,
                        fontSize: SizeConfig.blockWidth * 4,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockHeight * 2.5,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 5,
                    ),
                    child: buildProfessionalCard(
                      name: 'Gilbert Hermann',
                      profession: 'Swimming Coach',
                      location: 'Siddhartha Layout, Mysuru',
                      languages: 'Kannada, Hindi, English',
                      gender: 'Male',
                      price: '₹ 50,000',
                      paymentType: 'Per Project',
                      contacted: true,
                      experience: 'Freshers',
                      experienceImage: 'assets/images/home/work.png',
                      genderImage: 'assets/images/home/gender.png',
                      jobTypeImage: 'assets/images/profile/prof.png',
                      language: 'Kannada, Hindi, English',
                      languageImage: 'assets/images/home/speak.png',
                      onShowInterest: () {},
                      jobType: 'Swimming Coach',
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }
}
