import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/ImagePickerComponent.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/models/friends/friends_search_list_modal.dart';
import 'package:works_app/ui/friends/component.dart';
import 'package:works_app/ui/friends/friends_details.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../global_helper/report_post.dart';
import '../chat/addFriends.dart';
import '../chat/chat_view.dart';
import '../chat/component.dart';

class FriendsSearchListScreen extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  FriendsSearchListScreen({super.key,required this.refreshPageCallback,});

  @override
  State<FriendsSearchListScreen> createState() =>
      _FriendsSearchListScreenState();
}

class _FriendsSearchListScreenState extends State<FriendsSearchListScreen> {
  late FriendsBloc friendsBloc;
  late ChartBloc chartBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ReportPostBloc reportPostBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late List<Friend> friends;
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
    reportPostBloc =BlocProvider.of<ReportPostBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
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
    _fetchData(isNewFetch: true);
    widget.refreshPageCallback();
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
                            prefixIcon:  Padding(padding: EdgeInsets.all(SizeConfig.blockWidth*4),
                              child: Image.asset(
                                'assets/images/home/search.png',
                                width: SizeConfig.blockWidth * 3.5,
                                height: SizeConfig.blockWidth * 3.5,
                                fit: BoxFit.cover,
                              ),
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
                    return friendsListLoading();
                  } else if (state is FriendsListSuccess) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: SizeConfig.blockWidth * 4.5,
                        right: SizeConfig.blockWidth * 4.5,
                        top: SizeConfig.blockHeight * 0.2,
                        bottom: SizeConfig.blockHeight,
                      ),
                      child: ListView.builder(
                          itemCount: state.friendsSearchList.length +(isFetchingMore ? 1 : 0),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          controller: _scrollController,
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
                                                    bloc.add(
                                                        FetchFriendsSingleView(
                                                            friendId: state
                                                                .friendsSearchList[
                                                                    index]
                                                                .friendId));
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
                                                    .friendsSearchList[index]
                                                    .friendId,
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
                                      onTap: () => {
                                        chartBloc.add(StartMessageEvent(chatId: state.friendsSearchList[index].friends.id,
                                            onSuccess: (chatId){
                                         widget.refreshPageCallback();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MultiBlocProvider(
                                                        providers: [
                                                          BlocProvider(
                                                            create: (context) => ChartBloc()
                                                              ..add(FetchChartViewEvent(
                                                                  page: 1,
                                                                  pageSize: 10,
                                                                  chatId: chatId)),
                                                          ),
                                                          BlocProvider(
                                                              create: (context) =>
                                                                  InitialRegisterBloc()),
                                                          BlocProvider(
                                                              create: (context) =>
                                                                  ShowInterestedBloc()),
                                                        ],
                                                        child: ChatViewScreen(
                                                          refreshPageCallback:
                                                          _refreshPageAfterEdit,
                                                          chatId: chatId,
                                                          isGroup: false,
                                                          isRequest: false,
                                                        ),
                                                      )));

                                            }, onError: (message){
                                              showCustomSnackBar(
                                                  context: context,
                                                  message: message,
                                                  backgroundColor: COLORS.neutralDarkTwo);
                                            }))
                                      },
                                    ),
                                    BottomSheetItem(
                                      title: 'Unfriend',
                                      onTap: () => {
                                        showInterestedBloc.add(UnfriendsEvent(
                                            friendId: state
                                                .friendsSearchList[index]
                                                .friendId,
                                            onSuccess: (message) {
                                              setState(() {
                                                friends.removeWhere((friend) =>
                                                    friend.friendId ==
                                                    state
                                                        .friendsSearchList[
                                                            index]
                                                        .friendId);
                                              });
                                              Navigator.of(context).pop({});
                                              showCustomSnackBar(
                                                  context: context,
                                                  message:
                                                      "Successfully unfriended!",
                                                  backgroundColor:
                                                      COLORS.semanticTwo);
                                              widget.refreshPageCallback();
                                            },
                                            onError: (message) {
                                              showCustomSnackBar(
                                                context: context,
                                                message: message,
                                              );
                                            }))
                                      },
                                    ),
                                    BottomSheetItem(
                                      title: 'Report',
                                      onTap: () async {
                                        final result = await showMaterialModalBottomSheet(
                                            enableDrag: true,
                                            expand: false,
                                            isDismissible: true,
                                            backgroundColor: COLORS.white,
                                            closeProgressThreshold: 0,
                                            duration: const Duration(seconds: 0),
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(SizeConfig.blockWidth * 6)),
                                            ),
                                            builder: (context) => const ReportPostsBottomSheet(
                                              message: '',
                                            ));

                                        if (result != null) {
                                          setState(() {
                                            reportPostBloc.add(ReportProfessionalEvent(
                                              reason: result['message']!,
                                              userId: state.friendsSearchList[index].id!,
                                              onSuccess: (message) {
                                                Navigator.pop(context);
                                                showCustomSnackBar(
                                                    context: context,
                                                    message: message,backgroundColor: COLORS.neutralDarkOne
                                                );
                                              },
                                              onError: (message) {
                                                Navigator.pop(context);
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: message,
                                                );
                                              },
                                            ));
                                          });

                                        }
                                      },
                                    ),
                                    BottomSheetItem(
                                      title: 'Block',
                                      onTap: () => {},
                                    ),
                                  ],
                                );
                              },
                              onTapMessage: () {
                                chartBloc.add(StartMessageEvent(chatId: state.friendsSearchList[index].friends.id,
                                    onSuccess: (chatId){
                                      widget.refreshPageCallback();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MultiBlocProvider(
                                                    providers: [
                                                      BlocProvider(
                                                        create: (context) => ChartBloc()
                                                          ..add(FetchChartViewEvent(
                                                              page: 1,
                                                              pageSize: 10,
                                                              chatId: chatId)),
                                                      ),
                                                      BlocProvider(
                                                          create: (context) =>
                                                              InitialRegisterBloc()),
                                                      BlocProvider(
                                                          create: (context) =>
                                                              ShowInterestedBloc()),
                                                    ],
                                                    child: ChatViewScreen(
                                                      refreshPageCallback:
                                                      _refreshPageAfterEdit,
                                                      chatId: chatId,
                                                      isGroup: false,
                                                      isRequest: false,
                                                    ),
                                                  )));

                                    }, onError: (message){
                                      showCustomSnackBar(
                                          context: context,
                                          message: message,
                                          backgroundColor: COLORS.neutralDarkTwo);
                                    }));
                              },
                            );
                          }),
                    );
                  } else if (state is FriendsListFailed) {
                    return Padding(
                      padding: EdgeInsets.only(top: SizeConfig.blockHeight*15),
                      child: ErrorScreen(onRetry: () {
                        _fetchData();
                      }),
                    );
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
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => FriendsBloc()
                                  ..add(FetchFriendsAddListEvent(
                                      page: 1,
                                      pageSize: 10,
                                      keyWord: '')),
                              ),
                              BlocProvider(
                                  create: (context) =>
                                      ShowInterestedBloc()),
                              BlocProvider(
                                  create: (context) =>
                                      ChartBloc() ..add(FetchChartSearchListEvent(page: 1, pageSize: 10, keyWord: '')))
                            ],
                            child:  AddFriendsScreen(header: 'Add Friend',refreshPageCallback: _refreshPageAfterEdit),
                          )));
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
