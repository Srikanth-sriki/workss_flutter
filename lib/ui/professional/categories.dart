import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/ui/professional/categories_item.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

class CategoriesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> categoriesData;
  const CategoriesScreen({super.key, required this.categoriesData});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Categories',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Expanded(
                child: ListView.builder(
                    itemCount: widget.categoriesData.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 5,
                        vertical: SizeConfig.blockHeight * 2.5),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CategoriesItemScreen(
                                        categoriesItem:
                                            widget.categoriesData[index])),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockHeight * 2.5,
                              horizontal: SizeConfig.blockWidth * 5),
                          margin: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockHeight),
                          width: SizeConfig.blockWidth * 100,
                          color: COLORS.primaryOne.withOpacity(0.2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: SizeConfig.blockWidth * 20,
                                height: SizeConfig.blockWidth * 20,
                                margin: EdgeInsets.only(
                                    right: SizeConfig.blockWidth * 4),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(widget
                                          .categoriesData[index]['images']),
                                      fit: BoxFit.contain,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.blockWidth * 20),
                                    color: COLORS.primaryOne.withOpacity(0.5)),
                              ),
                              SizedBox(
                                height: SizeConfig.blockHeight * 0.5,
                              ),
                              Text(
                                widget.categoriesData[index]['title'],
                                style: TextStyle(
                                  color: COLORS.neutralDark,
                                  fontSize: SizeConfig.blockWidth * 3.6,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }))
          ])),
    );
  }
}
