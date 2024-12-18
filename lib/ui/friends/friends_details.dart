import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/profile/component.dart';

import '../../global_helper/helper_function.dart';
import '../../global_helper/readmore_text.dart';
import '../chat/component.dart';
import '../professional/component/grid_image_card.dart';
import 'component.dart';

class FriendsDetailsScreen extends StatefulWidget {
  const FriendsDetailsScreen({super.key});

  @override
  State<FriendsDetailsScreen> createState() => _FriendsDetailsScreenState();
}

class _FriendsDetailsScreenState extends State<FriendsDetailsScreen> {
  String usertype = "Professional";
  bool verified = true;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();
  bool clickOnSearch = false;
  double contentHeight = 0.0;

  @override
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Delay the scroll action to ensure that the keyboard is shown first
        Future.delayed(Duration(milliseconds: 100), () {
          _scrollToFocusedTextField();
        });
      }
    });
  }

  // Function to scroll the TextField into view
  void _scrollToFocusedTextField() {
    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero).dy;
      _scrollController.animateTo(
        _scrollController.offset + position - 150.0, // Adjust offset as needed
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
      appBar: AppBar(
        toolbarHeight: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: COLORS.white,
      ),
      body: SafeArea(
          child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        shrinkWrap: true,
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: false,
            backgroundColor: COLORS.white,
            forceMaterialTransparency: true,
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
            elevation: 0,
            expandedHeight: SizeConfig.blockHeight * 80,
            flexibleSpace: FlexibleSpaceBar(
              // collapseMode: CollapseMode.pin,
              background: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 2.5,
                      vertical: SizeConfig.blockHeight,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: COLORS.black,
                                size: SizeConfig.blockWidth * 4.5,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: SizeConfig.blockWidth * 12,
                                  height: SizeConfig.blockWidth * 12,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: COLORS.primary,
                                      width: SizeConfig.blockWidth * 0.2,
                                    ),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://via.placeholder.com/150', // Replace with actual profilePic
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      SizeConfig.blockWidth * 2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: SizeConfig.blockWidth * 2),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: verified
                                              ? SizeConfig.blockWidth * 15
                                              : SizeConfig.blockWidth * 45,
                                          child: Text(
                                            'John Doe', // Replace with dynamic professional name
                                            style: TextStyle(
                                              color: COLORS.neutralDark,
                                              fontSize:
                                                  SizeConfig.blockWidth * 4,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: "Poppins",
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                        if (verified)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  SizeConfig.blockWidth * 1.5,
                                              vertical:
                                                  SizeConfig.blockHeight * 0.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: COLORS.semanticTwo,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                SizeConfig.blockWidth * 3.8,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.verified,
                                                  color: COLORS.white,
                                                  size: SizeConfig.blockWidth *
                                                      3.5,
                                                ),
                                                SizedBox(
                                                  width: SizeConfig.blockWidth *
                                                      1.5,
                                                ),
                                                Text(
                                                  'Verified'.tr(),
                                                  style: TextStyle(
                                                    color: COLORS.white,
                                                    fontSize:
                                                        SizeConfig.blockWidth *
                                                            3,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Poppins",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: COLORS.accent,
                                          size: SizeConfig.blockWidth * 3.5,
                                        ),
                                        SizedBox(
                                            width: SizeConfig.blockWidth * 1),
                                        SizedBox(
                                          width: SizeConfig.blockWidth * 40,
                                          child: Text(
                                            'New York City', // Replace with dynamic city
                                            style: TextStyle(
                                              color: COLORS.neutralDarkOne,
                                              fontSize:
                                                  SizeConfig.blockWidth * 3,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Poppins",
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Image.asset(
                                'assets/images/profile/bookmark.png',
                                width: SizeConfig.blockWidth * 4.25,
                                height: SizeConfig.blockHeight * 4.25,
                                fit: BoxFit.contain,
                                color: COLORS.neutralDarkOne,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: COLORS.black,
                                size: SizeConfig.blockWidth * 6.5,
                              ),
                              onPressed: () {
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: COLORS.neutralDarkTwo,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 5,
                      vertical: SizeConfig.blockHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        registerTextCard(
                            text: 'professional.professionType!',
                            image: 'assets/images/home/home.png',
                            color: COLORS.neutralDark,
                            textColor: COLORS.neutralDarkOne),
                        registerTextCard(
                            text: 'professional.experiencedYears!',
                            image: 'assets/images/home/work_select.png',
                            color: COLORS.neutralDark,
                            textColor: COLORS.neutralDarkOne),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: SizeConfig.blockWidth * 55,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  registerTextCard(
                                      text:
                                          'professional.knownLanguages!.join(", ")',
                                      image: 'assets/images/home/speak.png',
                                      color: COLORS.neutralDark,
                                      textColor: COLORS.neutralDarkOne),
                                  registerTextCard(
                                      text: 'professional.gender!',
                                      image: 'assets/images/home/gender.png',
                                      color: COLORS.neutralDark,
                                      textColor: COLORS.neutralDarkOne),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  formatPrice('1000'),
                                  style: TextStyle(
                                      color: COLORS.neutralDark,
                                      fontSize: SizeConfig.blockWidth * 4.8,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Poppins",
                                      height: SizeConfig.blockHeight * 0.2),
                                ),
                                Text(
                                  capitalizeEachWord('Per Day'),
                                  style: TextStyle(
                                    color: COLORS.neutralDarkOne,
                                    fontSize: SizeConfig.blockWidth * 2.8,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: SizeConfig.blockHeight * 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TouchRippleEffect(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 2.5),
                              rippleColor: Colors.white60,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 2.5),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: SizeConfig.blockWidth * 42,
                                  height: SizeConfig.blockHeight * 7.25,
                                  decoration: BoxDecoration(
                                    color: COLORS.white,
                                    border: Border.all(color: COLORS.primary),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.blockWidth * 2.5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: SizeConfig.blockHeight * 2,
                                    horizontal: SizeConfig.blockWidth * 4,
                                  ),
                                  child: Text(
                                    'UNFRIEND'.tr(),
                                    style: TextStyle(
                                      color: COLORS.primary,
                                      fontSize: SizeConfig.blockWidth * 3.8,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Poppins",
                                    ),
                                    overflow: TextOverflow.clip,
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            ),
                            customButton(
                              text: 'CONTACT'.tr(),
                              onPressed: () {},
                              backgroundColor: COLORS.primary,
                              showIcon: false,
                              width: SizeConfig.blockWidth * 42,
                              height: SizeConfig.blockHeight * 8,
                              textColor: COLORS.white,
                            )
                          ],
                        ),
                        SizedBox(height: SizeConfig.blockHeight * 2),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: SizeConfig.blockHeight * 0.5),
                          child: Text(
                            'Bio'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 3.4,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                        const ReadMoreText(
                          text: ' professional.bio!',
                        ),
                        const Divider(
                          color: COLORS.neutralDarkTwo,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: SizeConfig.blockHeight * 0.5),
                          child: Text(
                            'Gallery'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 3.6,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                        SizedBox(height: SizeConfig.blockHeight),
                        const DynamicGridExample(
                          imageUrls: [
                            'https://via.placeholder.com/150',
                            'https://via.placeholder.com/150'
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

        SliverPersistentHeader(
          pinned: true,
          delegate: SearchBarDelegate(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: COLORS.white,
              padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 5,
                ),
                child: clickOnSearch
                    ? TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  key: _textFieldKey,
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.25,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  cursorColor: COLORS.black,
                  decoration: InputDecoration(
                    hintText: 'Ex: Search'.tr(),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: COLORS.neutralDarkOne,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          SizeConfig.blockWidth * 3.25),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Friends',
                      style: TextStyle(
                        color: COLORS.neutralDarkOne,
                        fontSize: SizeConfig.blockWidth * 3.8,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          clickOnSearch = true;
                        });
                      },
                      child: Icon(
                        Icons.search,
                        color: COLORS.neutralDarkOne,
                        size: SizeConfig.blockWidth * 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

          //  const SliverToBoxAdapter(
          //   child: Divider(
          //     color: COLORS.neutralDarkTwo,
          //   ),
          // ),

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 5,

                ),
                child: friendSearchDetailsCards(
                  image: 'assets/images/home/dumy1.png',
                  name: 'Julia Vandervort-Will',
                  onTapCard: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendsDetailsScreen(),
                      ),
                    );
                  },
                    added: index % 2 == 0 ? true : false,
                    disc: 'Mathematics Tutor'
                ),
              );
            },
                childCount: 15,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                addSemanticIndexes: true),
          ),
        ],
      )),
    );
  }
}

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  SearchBarDelegate({required this.child});

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 80.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

