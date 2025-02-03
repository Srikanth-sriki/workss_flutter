import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:works_app/bloc/friends/friends_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/models/friends/friends_view_modal.dart';
import 'package:works_app/ui/profile/component.dart';

import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/readmore_text.dart';

import '../chat/component.dart';
import '../professional/component/grid_image_card.dart';
import 'component.dart';

class FriendsDetailsScreen extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  final String id;
  const FriendsDetailsScreen(
      {super.key, required this.refreshPageCallback, required this.id});

  @override
  State<FriendsDetailsScreen> createState() => _FriendsDetailsScreenState();
}

class _FriendsDetailsScreenState extends State<FriendsDetailsScreen> {
  late FriendsBloc friendsBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ReportPostBloc reportPostBloc;
  late FriendData friendData;
  late User friendView;
  late List<FriendDataList> friendList;
  List<FriendDataList> filteredFriendList = [];
  final bool saved = false;
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
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    reportPostBloc = BlocProvider.of<ReportPostBloc>(context);
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
        searchKeyword = keyword.toLowerCase(); // Store lowercase keyword for comparison
        filteredFriendList = friendList.where((friend) {
          final name = friend.user.name.toLowerCase();
          final profession = friend.user.professionType.toLowerCase();
          return name.contains(searchKeyword) || profession.contains(searchKeyword);
        }).toList();
      });
    });
  }


  void _openSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: SizeConfig.blockWidth * 100,
        minWidth: SizeConfig.blockWidth * 100,
        minHeight: SizeConfig.blockHeight * 98,
        maxHeight: SizeConfig.blockHeight*98,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.blockWidth * 5),
        ),
      ),
      backgroundColor: COLORS.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: SizeConfig.blockHeight * 75, // Ensure height is applied
              padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockWidth * 12.5,
                horizontal: SizeConfig.blockWidth * 6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
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
                        borderRadius:
                        BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 2),
                  Divider(
                    color: COLORS.neutralDarkTwo,
                    height: SizeConfig.blockHeight,
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredFriendList.length,
                      itemBuilder: (context, index) {
                        return friendSearchDetailsCards(
                          image: filteredFriendList[index].user.profilePic,
                          name: filteredFriendList[index].user.name,
                          onTapCard: () {},
                          onTapButtonCard: () {},
                          added: filteredFriendList[index].user.friendRequestSent != null,
                          disc: filteredFriendList[index].user.professionType,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
      body: BlocConsumer<FriendsBloc, FriendsState>(
        listener: (context, state) {
          if (state is FetchFriendsViewSuccess) {
            setState(() {
              friendView = state.friendData.user;
              friendList = state.friendData.friends;
              filteredFriendList = state.friendData.friends;
            });
          }
        },
        builder: (context, state) {
          if (state is FetchFriendsViewLoading || state is FriendsInitial) {
            return globalLoadingWidget();
          } else if (state is FetchFriendsViewSuccess) {
            friendView = state.friendData.user;
            friendList = state.friendData.friends;
            return SafeArea(
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
                  expandedHeight: SizeConfig.blockHeight * 90,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: SizeConfig.blockWidth * 12,
                                        height: SizeConfig.blockWidth * 12,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: COLORS.primary,
                                            width: SizeConfig.blockWidth * 0.2,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              friendView
                                                  .profilePic, // Replace with actual profilePic
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            SizeConfig.blockWidth * 2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: SizeConfig.blockWidth * 2),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: friendView.isVerified
                                                    ? SizeConfig.blockWidth * 15
                                                    : SizeConfig.blockWidth *
                                                        45,
                                                child: Text(
                                                  friendView.name,
                                                  style: TextStyle(
                                                    color: COLORS.neutralDark,
                                                    fontSize:
                                                        SizeConfig.blockWidth *
                                                            4,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "Poppins",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              if (friendView.isVerified)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        SizeConfig.blockWidth *
                                                            1.5,
                                                    vertical:
                                                        SizeConfig.blockHeight *
                                                            0.5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: COLORS.semanticTwo,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      SizeConfig.blockWidth *
                                                          3.8,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.verified,
                                                        color: COLORS.white,
                                                        size: SizeConfig
                                                                .blockWidth *
                                                            3.5,
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig
                                                                .blockWidth *
                                                            1.5,
                                                      ),
                                                      Text(
                                                        'Verified'.tr(),
                                                        style: TextStyle(
                                                          color: COLORS.white,
                                                          fontSize: SizeConfig
                                                                  .blockWidth *
                                                              3,
                                                          fontWeight:
                                                              FontWeight.w400,
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
                                                size:
                                                    SizeConfig.blockWidth * 3.5,
                                              ),
                                              SizedBox(
                                                  width: SizeConfig.blockWidth *
                                                      1),
                                              SizedBox(
                                                width:
                                                    SizeConfig.blockWidth * 40,
                                                child: Text(
                                                  friendView.city,
                                                  style: TextStyle(
                                                    color:
                                                        COLORS.neutralDarkOne,
                                                    fontSize:
                                                        SizeConfig.blockWidth *
                                                            3,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Poppins",
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                    onTap: () {
                                      if (friendView.isSaved == null) {
                                        showInterestedBloc
                                            .add(ProfessionalSavedUs(
                                          PropId: friendView.id!,
                                          onSuccess: () {
                                            setState(() {
                                              friendView.isSaved =
                                                  IsContacted(id: '');
                                            });
                                            widget.refreshPageCallback();
                                          },
                                          onError: () {},
                                        ));
                                      } else {
                                        showInterestedBloc
                                            .add(ProfessionalSavedUs(
                                          PropId: friendView.id!,
                                          onSuccess: () {
                                            setState(() {
                                              friendView.isSaved = null;
                                            });
                                          },
                                          onError: () {
                                            showCustomSnackBar(
                                              context: context,
                                              message: "Something Went wrong",
                                            );
                                          },
                                        ));
                                      }
                                    },
                                    child: Image.asset(
                                      friendView.isSaved != null
                                          ? 'assets/images/professions/bookmarked.png'
                                          : 'assets/images/profile/bookmark.png',
                                      width: friendView.isSaved != null
                                          ? SizeConfig.blockWidth * 5.25
                                          : SizeConfig.blockWidth * 4.25,
                                      height: friendView.isSaved != null
                                          ? SizeConfig.blockHeight * 5.25
                                          : SizeConfig.blockHeight * 4.25,
                                      fit: BoxFit.contain,
                                      color: friendView.isSaved != null
                                          ? COLORS.accent
                                          : COLORS.neutralDarkOne,
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
                                            onTap: () => {},
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
                                  text: friendView.professionType,
                                  image: 'assets/images/home/home.png',
                                  color: COLORS.neutralDark,
                                  textColor: COLORS.neutralDarkOne),
                              registerTextCard(
                                  text: friendView.experiencedYears,
                                  image: 'assets/images/home/work_select.png',
                                  color: COLORS.neutralDark,
                                  textColor: COLORS.neutralDarkOne),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: SizeConfig.blockWidth * 55,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        registerTextCard(
                                            text: friendView.knownLanguages!
                                                .join(", "),
                                            image:
                                                'assets/images/home/speak.png',
                                            color: COLORS.neutralDark,
                                            textColor: COLORS.neutralDarkOne),
                                        registerTextCard(
                                            text: friendView.gender,
                                            image:
                                                'assets/images/home/gender.png',
                                            color: COLORS.neutralDark,
                                            textColor: COLORS.neutralDarkOne),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        formatPrice(friendView.charges),
                                        style: TextStyle(
                                            color: COLORS.neutralDark,
                                            fontSize:
                                                SizeConfig.blockWidth * 4.8,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Poppins",
                                            height:
                                                SizeConfig.blockHeight * 0.2),
                                      ),
                                      Text(
                                        capitalizeEachWord(
                                            friendView.chargeType),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TouchRippleEffect(
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.blockWidth * 2.5),
                                    rippleColor: Colors.white60,
                                    child: InkWell(
                                      onTap: () {
                                        showInterestedBloc.add(UnfriendsEvent(
                                            friendId: friendView.id,
                                            onSuccess: (message) {
                                              setState(() {
                                                friendView.isFriend = null;
                                                widget.refreshPageCallback();
                                              });
                                              showCustomSnackBar(
                                                  context: context,
                                                  message:
                                                      "Successfully unfriended!",
                                                  backgroundColor:
                                                      COLORS.semanticTwo);
                                            },
                                            onError: (message) {
                                              showCustomSnackBar(
                                                context: context,
                                                message: message,
                                              );
                                            }));
                                      },
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.blockWidth * 2.5),
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: SizeConfig.blockWidth * 42,
                                        height: SizeConfig.blockHeight * 7.25,
                                        decoration: BoxDecoration(
                                          color: COLORS.white,
                                          border:
                                              Border.all(color: COLORS.primary),
                                          borderRadius: BorderRadius.circular(
                                              SizeConfig.blockWidth * 2.5),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: SizeConfig.blockHeight * 2,
                                          horizontal: SizeConfig.blockWidth * 4,
                                        ),
                                        child: Text(
                                          friendView.isFriend != null
                                              ? 'UNFRIEND'.tr()
                                              : 'ADD FRIEND',
                                          style: TextStyle(
                                            color: COLORS.primary,
                                            fontSize:
                                                SizeConfig.blockWidth * 3.8,
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
                                    text: friendView.isContacted == null
                                        ? 'CONTACT'.tr()
                                        : 'CONTACTED'.tr(),
                                    onPressed: () {
                                      if (friendView.isContacted == null) {
                                        // showInterestedBloc
                                        //     .add(ProfessionalContactUs(
                                        //   PropId: professionalData.id!,
                                        //   onSuccess: () {
                                        //     setState(() {
                                        //       professionalData
                                        //           .isContacted =
                                        //           IsContacted(id: '');
                                        //       makePhoneCall(
                                        //           professionalData
                                        //               .mobile!);
                                        //     });
                                        //   },
                                        //   onError: () {},
                                        // ));
                                      } else {
                                        makePhoneCall(friendView.mobile!);
                                      }
                                    },
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
                              ReadMoreText(
                                text: friendView.bio,
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
                              DynamicGridExample(
                                imageUrls: friendView.workImages,
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
                        child: Row(
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
                                  _openSearchModal(context);
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
                        image: friendList[index].user.profilePic,
                        name: friendList[index].user.name,
                        onTapCard: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => FriendsDetailsScreen(),
                          //   ),
                          // );
                        },
                        onTapButtonCard: () {},
                        added: friendList[index].user.friendRequestSent != null
                            ? true
                            : false,
                        disc: friendList[index].user.professionType,
                      ),
                    );
                  },
                      childCount: friendList.length,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      addSemanticIndexes: true),
                ),
              ],
            ));
          } else if (state is FetchFriendsViewError) {
            return Scaffold(
              backgroundColor: COLORS.white,
              appBar: AppBar(
                toolbarHeight: 0,
                scrolledUnderElevation: 0,
              ),
              body: ErrorScreen(onRetry: () {
                friendsBloc.add(FetchFriendsSingleView(friendId: widget.id));
              }),
            );
          }
          return Container();
        },
      ),
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
