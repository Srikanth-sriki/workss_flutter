import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/category_list_modal.dart';
import 'category_item_list.dart';

class CategoriesItemScreen extends StatefulWidget {
  final CategorySub categoriesItem;
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
          title: widget.categoriesItem.name,
          backgroundColor: COLORS.primaryOne.withOpacity(0.15),
          borderColor: false,
          titleColors: COLORS.neutralDark),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: SizeConfig.blockWidth * 100, // Full width of the screen
            height: SizeConfig.blockHeight * 40, // Explicit height for the container
            decoration: BoxDecoration(
              color: COLORS.primaryOne.withOpacity(0.15), // Background color with opacity
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(SizeConfig.blockWidth * 8),
                bottomRight: Radius.circular(SizeConfig.blockWidth * 8),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(SizeConfig.blockWidth * 8),
                bottomRight: Radius.circular(SizeConfig.blockWidth * 8),
              ),
              child: Align(
                alignment: Alignment.center, // Center alignment
                child: Image.network(
                  widget.categoriesItem.image,width: SizeConfig.blockWidth * 90,
                  fit: BoxFit.contain, // Ensures the image fits within the container
                  alignment: Alignment.center, // Centers the image
                ),
              ),
            ),
          ),

          SizedBox(height: SizeConfig.blockHeight * 2),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 6.5,
                vertical: SizeConfig.blockHeight),
            child: Text(
              capitalizeEachWord(widget.categoriesItem.name),
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
                  itemCount:
                      widget.categoriesItem.professionalSubCategories.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 6,
                      vertical: SizeConfig.blockHeight * 2.5),
                  itemBuilder: (context, index) {
                    var item =
                        widget.categoriesItem.professionalSubCategories[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                            create: (context) =>
                                                ProfessionalBloc()
                                                  ..add(ProfessionalListEvent(
                                                      page: 1,
                                                      pageSize: 20,
                                                      profession: item.name,
                                                      keyWord: '',
                                                      city: '',
                                                      currentLongitude: '',
                                                      currentLatitude: '',
                                                      gender: ''))),
                                        BlocProvider(
                                          create: (context) =>
                                              ShowInterestedBloc(),
                                        )
                                      ],
                                      child: CategoryItemList(
                                        subCategory: item.name,
                                      ),
                                    )));
                      },
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
                          capitalizeEachWord(item.name),
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
