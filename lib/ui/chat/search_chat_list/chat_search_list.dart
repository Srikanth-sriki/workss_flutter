import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/bloc/chart/chart_bloc.dart';
import 'package:works_app/bloc/friends/friends_bloc.dart';
import 'package:works_app/bloc/register_account/initial_register_bloc.dart';
import 'package:works_app/bloc/report_post_bloc.dart';
import 'package:works_app/bloc/show_interested/show_interested_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/ImagePickerComponent.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/models/chat/chart_search_list.dart';
import 'package:works_app/models/friends/global_search_list_modal.dart';
import 'package:works_app/ui/chat/chat_view.dart';
import 'package:works_app/ui/chat/modal/filter_search_modal.dart';
import 'package:works_app/ui/friends/component.dart';
import 'package:works_app/ui/friends/friends_details.dart';


import 'package:buttons_tabbar/buttons_tabbar.dart';

class ChartFriendsScreen extends StatefulWidget {
  final String searchText;
  final VoidCallback refreshPageCallback;
  final String city;
  final String gender;


  const ChartFriendsScreen(
      {super.key, required this.refreshPageCallback,required this.searchText,
      required this.city,required this.gender
      });

  @override
  State<ChartFriendsScreen> createState() => _ChartFriendsScreenState();
}

class _ChartFriendsScreenState extends State<ChartFriendsScreen> {
  late FriendsBloc friendsBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ChartBloc chartBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late List<SearchFriendLists> searchFriendLists;
  late List<ChartSearchList> chartSearchList = [];
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
    chartBloc = BlocProvider.of<ChartBloc>(context);
    searchFriendLists = [];
    searchKeyword = widget.searchText;
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
      city: widget.city,
      gender: widget.gender
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
    return BlocConsumer<FriendsBloc, FriendsState>(
      listener: (context, state) {
        if (state is FriendsAddListSuccess) {
          setState(() {
            if (currentPage == 1) {
              searchFriendLists = state.searchFriendLists;
            } else {
              searchFriendLists.addAll(state.searchFriendLists);
            }
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
          return SizedBox(
              width: SizeConfig.screenWidth,
              height: SizeConfig.blockHeight*90,
              child: globalLoadingWidget());
        } else if (state is FriendsAddListSuccess) {
          if (searchFriendLists.isEmpty) {
            return SizedBox(
              width: SizeConfig.blockWidth * 100,
              height: SizeConfig.blockHeight * 70,
              child: emptyComponent(errorText: "No People Found"),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 4.5,
              vertical: SizeConfig.blockHeight,
            ),
            itemCount: searchFriendLists.length + (isFetchingMore ? 1 : 0),
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (index < searchFriendLists.length) {
                final friend = searchFriendLists[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    friendSearchDetailsCards(
                      itemID: friend.id,
                      context: context,
                      image: friend.profilePic,
                      name: friend.name,
                      onTapCard: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(create: (context) {
                                  final bloc = FriendsBloc();
                                  bloc.add(FetchFriendsSingleView(friendId: friend.id));
                                  return bloc;
                                }),
                                BlocProvider(create: (context) => ShowInterestedBloc()),
                                BlocProvider(create: (context) => ReportPostBloc()),
                                BlocProvider(create: (context) => ShowInterestedBloc()),
                                BlocProvider(create: (context) => ChartBloc()),
                              ],
                              child: FriendsDetailsScreen(
                                refreshPageCallback: _refreshPageAfterEdit,
                                id: friend.id,
                              ),
                            ),
                          ),
                        );
                      },
                      added: friend.friendRequestSent != null,
                      disc: friend.professionType ?? '',
                      bgFriend: true,
                      onTapButtonCard: () {
                        if (friend.isFriend != null) {
                          chartBloc.add(
                            StartMessageEvent(
                              chatId: friend.isFriend!.friendId!,
                              onSuccess: (chatId) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(create: (context) => ChartBloc()..add(FetchChartViewEvent(page: 1, pageSize: 10, chatId: chatId))),
                                        BlocProvider(create: (context) => InitialRegisterBloc()),
                                        BlocProvider(create: (context) => ShowInterestedBloc()),
                                      ],
                                      child: ChatViewScreen(
                                        refreshPageCallback: _refreshPageAfterEdit,
                                        chatId: chatId,
                                        isGroup: false,
                                        isRequest: false,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              onError: (message) {
                                showCustomSnackBar(context: context, message: message, backgroundColor: COLORS.neutralDarkTwo);
                              },
                            ),
                          );
                        } else if (friend.friendRequestSent != null) {
                          showInterestedBloc.add(UnSendFriendEvent(
                            userId: friend.id,
                            onSuccess: (message) {
                              setState(() {
                                searchFriendLists[index].friendRequestSent = null;
                              });
                            },
                            onError: (message) {
                              showCustomSnackBar(context: context, message: message);
                            },
                          ));
                        } else {
                          showInterestedBloc.add(AddFriendEvent(
                            userId: friend.id,
                            onSuccess: (message) {
                              setState(() {
                                searchFriendLists[index].friendRequestSent = FriendRequestSent(userId: friend.id);
                              });
                            },
                            onError: (message) {
                              showCustomSnackBar(context: context, message: message);
                            },
                          ));
                        }
                      },
                      buttonRequired: friend.isFriend == null,
                      sendMessageButtonRequired: friend.isFriend != null,
                    ),
                    SizedBox(height: SizeConfig.blockHeight * 1.25),
                  ],
                );
              } else if (isFetchingMore) {
                return Center(
                  child: SizedBox(
                    height: SizeConfig.blockHeight * 3,
                    width: SizeConfig.blockHeight * 3,
                    child: CircularProgressIndicator(
                      color: COLORS.primary,
                      strokeWidth: SizeConfig.blockWidth * 0.8,
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },

          );
        } else if (state is FriendsAddListFailed) {
          return ErrorScreen(onRetry: () {
            _fetchData();
          });
        }
        return Container();
      },
    );
  }
}
