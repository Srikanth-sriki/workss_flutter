import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

class CategoriesItemScreen extends StatefulWidget {
  final Map<String, dynamic> categoriesItem;
  const CategoriesItemScreen({super.key, required this.categoriesItem});

  @override
  State<CategoriesItemScreen> createState() => _CategoriesItemScreenState();
}

class _CategoriesItemScreenState extends State<CategoriesItemScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
          title: widget.categoriesItem['title'],
          backgroundColor: COLORS.primaryOne.withOpacity(0.15),
          borderColor: false,
          titleColors: COLORS.neutralDark),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: SizeConfig.blockWidth * 100,
            decoration: BoxDecoration(
                color: COLORS.primaryOne.withOpacity(0.15),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(SizeConfig.blockWidth * 8),
                    bottomRight: Radius.circular(SizeConfig.blockWidth * 8))),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                widget.categoriesItem['images'],
                width: SizeConfig.blockWidth * 100,
                height: SizeConfig.blockHeight * 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 2),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 6.5,
                vertical: SizeConfig.blockHeight),
            child: Text(
              widget.categoriesItem['title'],
              style: TextStyle(
                color: COLORS.primary,
                fontSize: SizeConfig.blockWidth * 4.5,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: widget.categoriesItem['pro'].length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 6,
                      vertical: SizeConfig.blockHeight * 2.5),
                  itemBuilder: (context, index) {
                    var item = widget.categoriesItem['pro'];
                    return InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.blockHeight * 2.5,
                           ),
                        margin: EdgeInsets.symmetric(
                            vertical: SizeConfig.blockHeight),
                        width: SizeConfig.blockWidth * 100,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: COLORS.neutralDarkTwo,
                                    width: SizeConfig.blockWidth * 0.15))),
                        child: Text(
                          item[index],
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: COLORS.neutralDark,
                            fontSize: SizeConfig.blockWidth * 3.6,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    );
                  }))
        ],
      )),
    );
  }
}
