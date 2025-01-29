import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/ImagePickerComponent.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/models/friends/friends_search_list_modal.dart';
import 'package:works_app/ui/friends/component.dart';
import 'package:works_app/ui/friends/friends_details.dart';

import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../chat/addFriends.dart';
import '../chat/component.dart';

class FriendsSearchListScreen extends StatefulWidget {
  const FriendsSearchListScreen({super.key});

  @override
  State<FriendsSearchListScreen> createState() => _FriendsSearchListScreenState();
}

class _FriendsSearchListScreenState extends State<FriendsSearchListScreen> {
  late FriendsBloc friendsBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late  List<Friend> friends;
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
      friends.clear();
      currentPage = 1;
    }

    friendsBloc.add(FetchFriendsListEvent(
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
      appBar: const CustomAppBar(
        title: 'Friends',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(
          child: Stack(
            children: [
              Column(
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
                      if (state is FriendsListSuccess) {
                        setState(() {
                          friends = state.friendsSearchList;
                          print(state.friendsSearchList);
                          isFetchingMore = false;
                          maxPageNumber = state.maxPageNumber;
                        });
                      } else if (state is FriendsListFailed) {
                        setState(() {
                          isFetchingMore = false;
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is FriendsListLoading && currentPage == 1) {
                        return  friendsListLoading();
                      } else if (state is FriendsListSuccess) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockWidth * 4.5,
                            vertical: SizeConfig.blockHeight * 0.2,
                          ),
                          child: ListView.builder(
                              itemCount: state.friendsSearchList.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return friendSearchCards(
                                  image: state.friendsSearchList[index].friends.profilePic,
                                  name: state.friendsSearchList[index].friends.name,
                                  onTapCard: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                  create: (context) {
                                                    final bloc = FriendsBloc();
                                                    bloc.add(FetchFriendsSingleView(friendId: state.friendsSearchList[index].userId));
                                                    return bloc;
                                                  },
                                                ),
                                                BlocProvider(
                                                  create: (context) =>
                                                      ShowInterestedBloc(),
                                                ),
                                                BlocProvider(create:(context)=>ReportPostBloc() )
                                              ],
                                              child: FriendsDetailsScreen(
                                                refreshPageCallback: _refreshPageAfterEdit,
                                                id: state.friendsSearchList[index].userId,

                                              ),
                                            )));

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
                                  onTapMessage: () {},
                                );
                              }),
                        );
                      } else if (state is FriendsListFailed) {
                        return ErrorScreen(onRetry: () {
                          _fetchData();
                        });
                      }
                      return Container();

                    },
                  )
                ],
              ),
              Positioned(
                bottom: SizeConfig.blockHeight * 2.5,
                right: SizeConfig.blockHeight * 4,
                child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddFriendsScreen(header: 'Add Friend'),
                          ));
                    },
                    backgroundColor: COLORS.primary,
                    child: Image.asset(
                      'assets/images/chat/add_friend.png',
                      width: SizeConfig.blockWidth * 6.5,
                      height: SizeConfig.blockWidth * 6.5,
                      fit: BoxFit.contain,
                    )),
              )
            ],
          )),
    );
  }
}
