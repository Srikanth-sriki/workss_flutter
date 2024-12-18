import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/size_config.dart';

import '../../components/colors.dart';
import '../../global_helper/reuse_widget.dart';
import '../friends/component.dart';

class InviteFriendsList extends StatefulWidget {
  const InviteFriendsList({super.key});

  @override
  State<InviteFriendsList> createState() => _InviteFriendsListState();
}

class _InviteFriendsListState extends State<InviteFriendsList> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String searchKeyword = "";
  bool showSearchBar = false;
  bool selectAll = false;
  List<bool> selectedItems = List.generate(10, (_) => false);

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
      });
    });
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      for (int i = 0; i < selectedItems.length; i++) {
        selectedItems[i] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Invite Friends',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 3.5,
                  vertical: SizeConfig.blockHeight),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        side: BorderSide(
                            color: COLORS.neutralDarkOne,
                            width: SizeConfig.blockWidth * 0.5),
                        checkColor: COLORS.white,
                        activeColor: COLORS.primary,
                        value: selectAll,
                        onChanged: (value) => _toggleSelectAll(value ?? false),
                      ),
                      Text(
                        'Select All',
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.5,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      showSearchBar ? Icons.close : Icons.search,
                      color: COLORS.neutralDarkOne,
                      size: SizeConfig.blockHeight * 4,
                    ),
                    onPressed: () {
                      setState(() {
                        showSearchBar = !showSearchBar;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Search Bar
            if (showSearchBar)
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 5.5,
                ),
                child: Expanded(
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
              ),
            // Divider(
            //   color: COLORS.neutralDarkTwo,height: SizeConfig.blockHeight,
            // ),
            if (selectAll == false) ...[
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
                        return Column(
                          children: [
                            friendSearchDetailsCards(
                                image: 'assets/images/home/dumy1.png',
                                name: 'Julia Vandervort-Will',
                                onTapCard: () {},
                                added: index % 2 == 0 ? true : false,
                                disc: 'Mathematics Tutor',
                                buttonText1: 'Cancel',
                                buttonText2: 'Invite',
                                bgFriend: false),
                            Divider(
                              color: COLORS.neutralDarkTwo,
                              height: SizeConfig.blockHeight,
                              thickness: SizeConfig.blockWidth * 0.15,
                            ),
                          ],
                        );
                      }),
                ),
              )
            ],
            if (selectAll == true) ...[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4.5,
                  ),
                  child: ListView.builder(
                      itemCount: selectedItems.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  side: BorderSide(
                                      color: COLORS.neutralDarkOne,
                                      width: SizeConfig.blockWidth * 0.5),
                                  checkColor: COLORS.white,
                                  activeColor: COLORS.primary,
                                  value: selectedItems[index],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedItems[index] = value ?? false;
                                    });
                                  },
                                ),
                                friendSearchDetailsCards(
                                    image: 'assets/images/home/dumy1.png',
                                    name: 'Julia Vandervort-Will',
                                    onTapCard: () {},
                                    added: index % 2 == 0 ? true : false,
                                    disc: 'Mathematics Tutor',
                                    buttonText1: 'Cancel',
                                    buttonText2: 'Invite',
                                    bgFriend: false,
                                    buttonRequired: false),
                              ],
                            ),
                            Divider(
                              color: COLORS.neutralDarkTwo,
                              height: SizeConfig.blockHeight,
                              thickness: SizeConfig.blockWidth * 0.15,
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: selectAll?Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 6.5,
            vertical: SizeConfig.blockHeight),
        child: customButton(
          text: 'INVITE'.tr(),
          onPressed: () {
            setState(() {});
            Navigator.pop(context);
          },
          backgroundColor: COLORS.primary,
          showIcon: false,
          width: SizeConfig.blockWidth * 42,
          height: SizeConfig.blockHeight * 8,
          textColor: COLORS.white,
        ),
      ):null,
    );
  }
}
