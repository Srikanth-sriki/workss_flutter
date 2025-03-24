import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/ImagePickerComponent.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/friends/component.dart';
import 'package:works_app/ui/friends/friends_details.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../models/friends/global_search_list_modal.dart';

class AddFriendsScreen extends StatefulWidget {
  final String header;

  const AddFriendsScreen({super.key, required this.header});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  late FriendsBloc friendsBloc;
  late ShowInterestedBloc showInterestedBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late List<SearchFriendLists> searchFriendLists;
  Timer? _debounce;
  String searchKeyword = "";
  bool isFetchingMore = false;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;

  @override
  void initState() {
    super.initState();
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          currentPage < maxPageNumber) {
        _loadMoreData();
      }
    });

    _fetchData();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
        currentPage = 1;
      });
      _fetchData();
    });
  }

  void _fetchData({bool isNewFetch = false}) {
    if (isNewFetch) {
      searchFriendLists.clear();
      currentPage = 1;
    }

    friendsBloc.add(FetchFriendsAddListEvent(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: widget.header,
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
            color: COLORS.neutralDarkTwo,
            height: SizeConfig.blockHeight,
          ),
          BlocConsumer<FriendsBloc, FriendsState>(
            listener: (context, state) {
              if (state is FriendsAddListSuccess) {
                setState(() {
                  searchFriendLists = state.searchFriendLists;
                  isFetchingMore = false;
                  maxPageNumber = state.maxPageNumber;
                });
              } else if (state is FriendsAddListFailed) {
                setState(() {
                  isFetchingMore = false;
                });
              }
            },
            builder: (context, state) {
              if (state is FriendsListLoading && currentPage == 1) {
                return friendsListLoading();
              } else if (state is FriendsAddListSuccess) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 4.5,
                      vertical: SizeConfig.blockHeight * 0.2,
                    ),
                    child: ListView.builder(
                        itemCount: searchFriendLists.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return friendSearchDetailsCards(
                            image: searchFriendLists[index].profilePic,
                            name: searchFriendLists[index].name,
                            onTapCard: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (context) {
                                              final bloc = FriendsBloc();
                                              bloc.add(
                                                  FetchFriendsSingleView(
                                                      friendId: state
                                                          .searchFriendLists[
                                                      index]
                                                          .id));
                                              return bloc;
                                            },
                                          ),
                                          BlocProvider(
                                            create: (context) =>
                                                ShowInterestedBloc(),
                                          ),
                                          BlocProvider(
                                              create: (context) =>
                                                  ReportPostBloc()),
                                          BlocProvider(create: (context)=>ShowInterestedBloc()),
                                          BlocProvider(create: (context)=>ChartBloc())

                                        ],
                                        child: FriendsDetailsScreen(
                                          refreshPageCallback:
                                          _refreshPageAfterEdit,
                                          id: state
                                              .searchFriendLists[index]
                                              .id,
                                        ),
                                      )));
                            },
                            added: searchFriendLists[index].friendRequestSent !=
                                    null
                                ? true
                                : false,
                            disc: searchFriendLists[index].professionType!,
                            bgFriend: true,
                            onTapButtonCard: () {
                              if (searchFriendLists[index].friendRequestSent == null) {
                                showInterestedBloc.add(AddFriendEvent(
                                    userId: searchFriendLists[index].id,
                                    onSuccess: (message) {
                                      setState(() {
                                        searchFriendLists[index].friendRequestSent =
                                            FriendRequestSent(
                                                 userId: searchFriendLists[index].id,);
                                      });
                                    },
                                    onError: (message) {
                                      showCustomSnackBar(
                                        context: context,
                                        message: message,
                                      );
                                    }));
                              }
                            },
                            buttonRequired: searchFriendLists[index].isFriend == null,
                            sendMessageButtonRequired: searchFriendLists[index].isFriend != null,
                          );
                        }),
                  ),
                );
              } else if (state is FriendsAddListFailed) {
                return ErrorScreen(onRetry: () {
                  _fetchData();
                });
              }
              return Container();
            },
          )
        ],
      )),
    );
  }
}
