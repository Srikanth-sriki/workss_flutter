import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/ImagePickerComponent.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/friends/component.dart';
import 'package:works_app/ui/friends/friends_details.dart';

import '../chat/component.dart';

class FriendsSearchList extends StatefulWidget {
  const FriendsSearchList({super.key});

  @override
  State<FriendsSearchList> createState() => _FriendsSearchListState();
}

class _FriendsSearchListState extends State<FriendsSearchList> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String searchKeyword = "";

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
        title: 'Friends',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 4.5,
              vertical: SizeConfig.blockHeight * 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.25,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                    cursorColor: COLORS.black,
                    decoration: InputDecoration(
                      fillColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                      focusColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                      filled: true,
                      hintText: 'Ex: Search'.tr(),
                      hintStyle: TextStyle(
                        color: COLORS.neutralDarkOne,
                        fontSize: SizeConfig.blockWidth * 3.25,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: COLORS.neutralDarkOne,
                        size: SizeConfig.blockWidth * 5,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                        borderSide: BorderSide(
                            color: COLORS.neutralDarkTwo.withOpacity(0.6),
                            width: SizeConfig.blockWidth * 0.1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                        borderSide: BorderSide(
                            color: COLORS.neutralDarkTwo.withOpacity(0.6),
                            width: SizeConfig.blockWidth * 0.1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                        borderSide: BorderSide(
                            color: COLORS.neutralDarkTwo.withOpacity(0.6),
                            width: SizeConfig.blockWidth * 0.1),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: COLORS.neutralDarkTwo,height: SizeConfig.blockHeight,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 4.5,
                vertical: SizeConfig.blockHeight * 0.2,
              ),
              child: ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return friendSearchCards(
                      image: 'assets/images/home/dumy1.png',
                      name: 'Julia Vandervort-Will',
                      onTapCard: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendsDetailsScreen(),
                            ));
                      },
                      onTapIcon: () {
                        showDynamicBottomSheet(
                          context,
                          'More Options',
                          [
                            BottomSheetItem(
                              title: 'Send Message',
                              onTap: () => {},
                            ),
                            BottomSheetItem(
                              title: 'Unfriend',
                              onTap: () =>{},

                            ),
                            BottomSheetItem(
                              title: 'Report',
                              onTap: () => {},
                            ),
                            BottomSheetItem(
                              title: 'Block',
                              onTap: () => {},
                            ),
                          ],
                        );
                      },
                      onTapMessage: () {},
                    );
                  }),
            ),
          )
        ],
      )),
    );
  }
}
