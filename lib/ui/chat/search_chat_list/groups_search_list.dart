import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/chart/chart_bloc.dart';
import 'package:works_app/bloc/friends/friends_bloc.dart';
import 'package:works_app/bloc/register_account/initial_register_bloc.dart';
import 'package:works_app/bloc/show_interested/show_interested_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/ImagePickerComponent.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/models/chat/chart_search_list.dart';
import 'package:works_app/models/friends/global_search_list_modal.dart';
import 'package:works_app/ui/chat/chat_view.dart';
import 'package:works_app/ui/chat/search_chat_list/chart_search_profile.dart';
import 'package:works_app/ui/friends/component.dart';

class GroupChartFriendsScreen extends StatefulWidget {
  final String searchText;
  final VoidCallback refreshPageCallback;

  const GroupChartFriendsScreen(
      {super.key, required this.refreshPageCallback, required this.searchText});

  @override
  State<GroupChartFriendsScreen> createState() =>
      _GroupChartFriendsScreenState();
}

class _GroupChartFriendsScreenState extends State<GroupChartFriendsScreen> {
  late FriendsBloc friendsBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ChartBloc chartBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late List<ChartSearchList> chartSearchList = [];
  Timer? _debounce;
  String searchKeyword = "";
  int currentChartPage = 1;
  bool isFetchingChartMore = false;
  int maxChartPageNumber = 1;
  int chartPageSize = 10;
  bool pageLoaded = true;

  @override
  void initState() {
    super.initState();
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
    searchKeyword = widget.searchText;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingChartMore &&
          currentChartPage < maxChartPageNumber) {
        _loadMoreData();
      }
    });
    _fetchChartData();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
        currentChartPage = 1;
      });
      _fetchChartData();
    });
  }

  void _fetchChartData({bool isNewFetch = false}) {
    if (isNewFetch) {
      chartSearchList.clear();
      currentChartPage = 1;
    }

    chartBloc.add(FetchChartSearchListEvent(
      page: currentChartPage,
      pageSize: chartPageSize,
      keyWord: searchKeyword,
    ));
  }

  void _loadMoreData() {
    setState(() {
      isFetchingChartMore = true;
      currentChartPage++;
    });
    _fetchChartData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _refreshPageAfterEdit() {
    _fetchChartData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChartBloc, ChartState>(
      listener: (context, state) {
        if (state is chartListSearchSuccess) {
          setState(() {
            if (currentChartPage == 1) {
              chartSearchList = state.chartSearchList;
            } else {
              chartSearchList.addAll(state.chartSearchList);
            }
            isFetchingChartMore = false;
            maxChartPageNumber = state.maxPageNumber;
            pageLoaded = false;
          });
        } else if (state is chartListSearchFailed) {
          setState(() {
            isFetchingChartMore = false;
          });
        }
      },
      builder: (context, state) {
        if (state is chartListSearchLoading && currentChartPage == 1 && pageLoaded) {
          return friendsListLoading();
        } else if (state is chartListSearchSuccess) {
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 4.5,
              vertical: SizeConfig.blockHeight,
            ),
            itemCount: chartSearchList.length + (isFetchingChartMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (chartSearchList.isEmpty) {
                return SizedBox(
                  width: SizeConfig.blockWidth * 100,
                  height: SizeConfig.blockHeight * 70,
                  child: emptyComponent(errorText: "No Chats Found"),
                );
              }
              if (index < chartSearchList.length) {
                final chart = chartSearchList[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    friendSearchDetailsCards(
                      image: chart.picture ?? '',
                      name: chart.name ?? '',
                      disc: chart.description ?? '',
                      bgFriend: true,
                      added: chart.isRequested != null || chart.isInvited != null,
                      buttonRequired: chart.participantsDetails == null,
                      sendMessageButtonRequired: chart.participantsDetails != null,
                      buttonText2: 'Join Group',
                      buttonText1: chart.isInvited != null ? 'Invited' : 'Request Sent',
                      isGroup: true,
                      onTapCard: () {
                        if (chart.participantsDetails != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(create: (_) => ChartBloc()
                                    ..add(FetchChartViewEvent(
                                      page: 1,
                                      pageSize: 10,
                                      chatId: chart.participantsDetails!.chatId!,
                                    ))),
                                  BlocProvider(create: (_) => InitialRegisterBloc()),
                                  BlocProvider(create: (_) => ShowInterestedBloc()),
                                ],
                                child: ChatViewScreen(
                                  refreshPageCallback: _refreshPageAfterEdit,
                                  chatId: chart.participantsDetails!.chatId!,
                                  isGroup: true,
                                ),
                              ),
                            ),
                          );
                        }
                        else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MultiBlocProvider(
                                          providers: [
                                            BlocProvider(
                                              create: (context) =>
                                              ChartBloc()
                                                ..add(
                                                    FetchChartViewProfileEvent(
                                                        chatId: chart.id!)),
                                            ),
                                            BlocProvider(
                                                create: (context) =>
                                                    ShowInterestedBloc())
                                          ],
                                          child: ChatProfileViewScreen(
                                            refreshPageCallback:
                                            _refreshPageAfterEdit,
                                            id: chart.id!, chart: chart,
                                          ))));
                        }
                      },
                      onTapButtonCard: () {
                        if (chart.participantsDetails != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(create: (_) => ChartBloc()
                                    ..add(FetchChartViewEvent(
                                      page: 1,
                                      pageSize: 10,
                                      chatId: chart.participantsDetails!.chatId!,
                                    ))),
                                  BlocProvider(create: (_) => InitialRegisterBloc()),
                                  BlocProvider(create: (_) => ShowInterestedBloc()),
                                ],
                                child: ChatViewScreen(
                                  refreshPageCallback: _refreshPageAfterEdit,
                                  chatId: chart.participantsDetails!.chatId!,
                                  isGroup: true,
                                ),
                              ),
                            ),
                          );
                        }
                        else if (chart.isInvited != null) {
                          showInterestedBloc.add(AcceptSendChatEvent(
                            chatId: chart.isInvited!.id!,
                            onSuccess: (message) {
                              setState(() {
                                chart.isInvited = null;
                                chart.participantsDetails = IsInvited(chatId: chart.id);
                              });
                              showCustomSnackBar(
                                context: context,
                                message: message,
                                backgroundColor: COLORS.neutralDarkTwo,
                              );
                            },
                            onError: (message) {
                              showCustomSnackBar(context: context, message: message);
                            },
                          ));
                        } else if (chart.isRequested != null) {
                          showInterestedBloc.add(CancelJoinRequestChatEvent(
                            chatId: chart.isRequested!.chatId!,
                            onSuccess: (message) {
                              setState(() {
                                chart.isRequested = null;
                              });
                              showCustomSnackBar(
                                context: context,
                                message: message,
                                backgroundColor: COLORS.neutralDarkTwo,
                              );
                            },
                            onError: (message) {
                              showCustomSnackBar(context: context, message: message);
                            },
                          ));
                        } else {
                          showInterestedBloc.add(SendJoinGroupChatEvent(
                            chatId: chart.id!,
                            onSuccess: (message) {
                              setState(() {
                                chart.isRequested = IsInvited(chatId: chart.id);
                              });
                              showCustomSnackBar(
                                context: context,
                                message: message,
                                backgroundColor: COLORS.neutralDarkTwo,
                              );
                            },
                            onError: (message) {
                              showCustomSnackBar(context: context, message: message);
                            },
                          ));
                        }
                      },
                    ),
                    SizedBox(height: SizeConfig.blockHeight * 1.25),
                  ],
                );
              } else {
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
              }
            },
          );
        } else if (state is chartListSearchFailed) {
          return ErrorScreen(onRetry: _fetchChartData);
        }
        return friendsListLoading();
      },
    );
  }
}
