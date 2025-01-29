import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/models/category_list_modal.dart';
import 'package:works_app/ui/professional/categories_item.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/reuse_widget.dart';

class CategoriesScreen extends StatefulWidget {
  final List<CategorySub> categoriesData;
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(SizeConfig.blockWidth * 4)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockHeight * 2,
                              horizontal: SizeConfig.blockWidth * 5),
                          decoration: BoxDecoration(
                              color: COLORS.primaryOne.withOpacity(0.2),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(SizeConfig.blockWidth * 4))),
                          margin: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockHeight),
                          width: SizeConfig.blockWidth * 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: SizeConfig.blockWidth * 18,
                                height: SizeConfig.blockWidth * 18,
                                margin: EdgeInsets.only(
                                    right: SizeConfig.blockWidth * 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: COLORS.primaryOne.withOpacity(0.5),
                                ),
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 1 / 1.5,
                                    child: Image.network(
                                      widget.categoriesData[index].image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.blockHeight * 0.5,
                              ),
                              SizedBox(
                                width: SizeConfig.blockWidth * 55,
                                child: Text(
                                  capitalizeEachWord(
                                      widget.categoriesData[index].name),
                                  softWrap: true,
                                  style: TextStyle(
                                    color: COLORS.neutralDark,
                                    fontSize: SizeConfig.blockWidth * 3.6,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Poppins",
                                  ),
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
