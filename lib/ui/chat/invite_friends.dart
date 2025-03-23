import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/size_config.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../components/colors.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/chat/invite_friend_modal.dart';
import '../friends/component.dart';

class InviteFriendsList extends StatefulWidget {
  String groupId;
  InviteFriendsList({super.key, required this.groupId});

  @override
  State<InviteFriendsList> createState() => _InviteFriendsListState();
}

class _InviteFriendsListState extends State<InviteFriendsList> {
  late ChartBloc chartBloc;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String searchKeyword = "";
  bool isFetchingMore = false;
  bool isInviteMemberLoading = true;
  bool isError = false;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  bool showSearchBar = false;
  bool selectAll = false;
  List<InviteFriend> inviteFriendsList = [];
  List<Map<String, dynamic>> selectedItems = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          currentPage < maxPageNumber) {
        _loadMoreData();
      }
    });
  }

  void _updateSelectedItemsList() {
    selectedItems = inviteFriendsList
        .map((friend) => {"id": friend.user!.id!, "selected": false})
        .toList();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
        currentPage = 1;
      });
      _fetchData(isNewFetch: true);
    });
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      for (var item in selectedItems) {
        item["selected"] = value;
      }
    });
  }

  // void _toggleItemSelection(int index, bool value) {
  //   setState(() {
  //     selectedItems[index]["selected"] = value;
  //
  //     // Check if all items are selected
  //     bool allSelected = selectedItems.every((item) => item["selected"]);
  //     selectAll = allSelected;
  //   });
  // }

  void _fetchData({bool isNewFetch = false}) {
    if (isNewFetch) {
      inviteFriendsList.clear();
      currentPage = 1;
    }

    chartBloc.add(InviteMemberChartEvent(
      groupId: widget.groupId,
      page: currentPage,
      pageSize: pageSize,
      keyWord: searchKeyword,
    ));
  }

  void _loadMoreData() {
    setState(() {
      isFetchingMore = true;
      currentPage++;
    });
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _refreshPageAfterEdit() {
    _fetchData();
  }

  void checkSelectedId() {
    List<String> selectedUserIds = selectedItems
        .where((user) => user["selected"] == true) // Filter only selected users
        .map((user) => user["id"] as String) // Extract only the IDs
        .toList();
    if (selectedUserIds.isEmpty) {
      setState(() {
        selectAll = false;
      });
    }
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
        child: MultiBlocListener(
          listeners: [
            BlocListener<ChartBloc, ChartState>(listener: (context, state) {
              if (state is InviteMemberLoading && currentPage == 1) {
                setState(() {
                  isInviteMemberLoading = true;
                  isFetchingMore = true;
                  isError = false;
                });
              } else if (state is InviteMemberSuccess) {
                setState(() {
                  isInviteMemberLoading = false;
                  isFetchingMore = false;
                  isError = false;
                  maxPageNumber = state.maxPageNumber;

                  if (currentPage == 1) {
                    inviteFriendsList = state.inviteFriend;
                  } else {
                    final newItems = state.inviteFriend.where(
                      (newItem) => !inviteFriendsList.any(
                        (existingItem) => existingItem.id == newItem.id,
                      ),
                    );
                    inviteFriendsList.addAll(newItems);
                  }

                  _updateSelectedItemsList();
                });
              } else if (state is InviteMemberFailed) {
                setState(() {
                  isInviteMemberLoading = false;
                  isFetchingMore = false;
                  isError = true;
                  showCustomSnackBar(
                    context: context,
                    message: state.message,
                  );
                });
              } else if (state is SendInviteMemberSuccess) {
                showCustomSnackBar(
                    context: context,
                    message: state.message,
                    backgroundColor: COLORS.neutralDarkTwo);
              } else if (state is SendInviteMemberFailed) {
                showCustomSnackBar(
                  context: context,
                  message: state.message,
                );
              }
            })
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          onChanged: (value) =>
                              _toggleSelectAll(value ?? false),
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
                          _searchController.clear();
                          showSearchBar = !showSearchBar;
                          if (!showSearchBar) {
                            setState(() {
                              searchKeyword = '';
                              currentPage = 1;
                              _fetchData(isNewFetch: true);
                            });
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
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
                          borderRadius: BorderRadius.circular(
                              SizeConfig.blockWidth * 3.25),
                          borderSide: BorderSide(
                              color: COLORS.neutralDarkTwo.withOpacity(0.6),
                              width: SizeConfig.blockWidth * 0.1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              SizeConfig.blockWidth * 3.25),
                          borderSide: BorderSide(
                              color: COLORS.neutralDarkTwo.withOpacity(0.6),
                              width: SizeConfig.blockWidth * 0.1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              SizeConfig.blockWidth * 3.25),
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

              if (isInviteMemberLoading == true && currentPage == 1) ...[
                friendsListLoading()
              ] else if (inviteFriendsList.isNotEmpty &&
                  !isInviteMemberLoading) ...[
                if (selectAll == false) ...[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 4.5,
                        vertical: SizeConfig.blockHeight * 0.2,
                      ),
                      child: ListView.builder(
                        itemCount: inviteFriendsList.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          InviteFriend inviteList = inviteFriendsList![index];
                          return Column(
                            children: [
                              friendSearchDetailsCards(
                                  image: inviteList.user!.profilePic!,
                                  name: inviteList.user!.name!,
                                  onTapCard: () {},
                                  added: inviteList.user!.isInvited != null
                                      ? true
                                      : false,
                                  disc: inviteList.user!.bio!,
                                  buttonText1: 'Cancel',
                                  buttonText2: 'Invite',
                                  onTapButtonCard: () {
                                    chartBloc.add(SendInviteMemberEvent(
                                        chatId: widget.groupId,
                                        invitedUsers: [
                                          inviteList.user!.id!,
                                        ],
                                        onSuccess: (message) {
                                          _fetchData();
                                        }));
                                  },
                                  bgFriend: false),
                              Divider(
                                color: COLORS.neutralDarkTwo,
                                height: SizeConfig.blockHeight,
                                thickness: SizeConfig.blockWidth * 0.15,
                              ),
                            ],
                          );
                        },
                      ),
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
                        itemCount: inviteFriendsList
                            .length, // Use inviteFriendsList length
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          InviteFriend inviteList = inviteFriendsList[
                              index]; // Get the correct object

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    side: BorderSide(
                                      color: COLORS.neutralDarkOne,
                                      width: SizeConfig.blockWidth * 0.5,
                                    ),
                                    checkColor: COLORS.white,
                                    activeColor: COLORS.primary,
                                    value: selectedItems[index]["selected"],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        selectedItems[index]["selected"] =
                                            value ?? false;
                                        checkSelectedId();
                                      });
                                    },
                                  ),
                                  friendSearchDetailsCards(
                                    image: inviteList.user!.profilePic!, //
                                    name: inviteList.user!
                                        .name!, // Use data from InviteFriend
                                    onTapCard: () {
                                      setState(() {
                                        selectedItems[index]["selected"] =
                                            !selectedItems[index]["selected"];
                                        checkSelectedId();
                                      });
                                    },
                                    added: inviteList.user!.isInvited != null
                                        ? false
                                        : true,
                                    disc: inviteList.user!
                                        .bio!, // Assuming InviteFriend has occupation
                                    buttonText1: 'Cancel',
                                    buttonText2: 'Invite',
                                    bgFriend: false,
                                    onTapButtonCard: () {},
                                    buttonRequired: false,
                                  ),
                                ],
                              ),
                              Divider(
                                color: COLORS.neutralDarkTwo,
                                height: SizeConfig.blockHeight,
                                thickness: SizeConfig.blockWidth * 0.15,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ]
              ] else if (inviteFriendsList.isEmpty) ...[
                SizedBox(
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.blockHeight * 80,
                    child: emptyComponent())
              ] else if (isInviteMemberLoading == false && isError) ...[
                ErrorScreen(onRetry: () {
                  _fetchData();
                })
              ]
            ],
          ),
        ),
      ),
      bottomNavigationBar: selectAll
          ? Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 6.5,
                  vertical: SizeConfig.blockHeight),
              child: customButton(
                text: 'INVITE'.tr(),
                onPressed: () {
                  setState(() {
                    print(selectedItems);
                    List<String> selectedUserIds = selectedItems
                        .where((user) =>
                            user["selected"] ==
                            true) // Filter only selected users
                        .map((user) =>
                            user["id"] as String) // Extract only the IDs
                        .toList();
                    print(selectedUserIds.length);

                    chartBloc.add(SendInviteMemberEvent(
                        chatId: widget.groupId,
                        invitedUsers: selectedUserIds,
                        onSuccess: (message) {
                          _fetchData();
                          selectAll = false;
                        }));
                  });
                },
                backgroundColor: COLORS.primary,
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
              ),
            )
          : null,
    );
  }
}
