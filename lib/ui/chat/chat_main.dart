import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/friends/friends_bloc.dart';
import 'package:works_app/bloc/register_account/initial_register_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/chat/archived_chats.dart';
import 'package:works_app/ui/chat/chat_list_search.dart';
import 'package:works_app/ui/chat/chat_view.dart';
import 'package:works_app/ui/chat/component.dart';
import 'package:works_app/ui/chat/create_chat_group.dart';
import 'package:works_app/ui/friends/friends_search.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../models/chat/charts_list_modal.dart';
import '../../models/friends/friends_search_list_modal.dart';
import '../friends/friends_details.dart';
import '../home/component.dart';
import '../profile/notification.dart';
import 'addFriends.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  late FriendsBloc friendsBloc;
  late ChartBloc chartBloc;
  List<Friend> friends = [];
  List<ChatList> chatList = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isFriendsListLoad = true;
  bool isChatListLoading = true;
  bool isError = false;
  Timer? _debounce;
  String searchKeyword = "";

  @override
  void initState() {
    super.initState();
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
  }

  void _onSearchChanged(String keyword) {}

  // void _onSearchChanged(String keyword) {
  //   if (_debounce?.isActive ?? false) _debounce?.cancel();
  //   _debounce = Timer(const Duration(milliseconds: 500), () {
  //     setState(() {
  //       searchKeyword = keyword.toLowerCase();
  //       chatList = chatList.where((chatList) {
  //         final name = chatList.name!.toLowerCase();
  //         return name.contains(searchKeyword) ;
  //       }).toList();
  //     });
  //   });
  // }

  void _refreshPageAfterEdit() {
    _fetchData();
  }

  void _fetchData() {
    // setState(() {
    //   isFriendsListLoad = true;
    //   isChatListLoading = true;
    // });
    friendsBloc.add(FetchFriendsListEvent(
      page: 1,
      pageSize: 10,
      keyWord: '',
    ));
    chartBloc.add(const ChartListEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: 'Chat',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert,
                color: COLORS.black, size: SizeConfig.blockWidth * 6.5),
            onPressed: () {
              showDynamicBottomSheet(
                context,
                'Chat Options',
                [
                  BottomSheetItem(
                    title: 'Create new group',
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (context) => ChartBloc(),
                                      ),
                                      BlocProvider(
                                          create: (context) =>
                                              InitialRegisterBloc()),
                                      BlocProvider(
                                          create: (context) => FriendsBloc()
                                            ..add(FetchFriendsListEvent(
                                                page: 1,
                                                pageSize: 10,
                                                keyWord: ''))),
                                    ],
                                    child: const CreateGroupScreen(),
                                  )))
                    },
                  ),
                  BottomSheetItem(
                    title: 'Archived Chats',
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (context) => ChartBloc()
                                          ..add(const ArchivedChartListEvent()),
                                      ),
                                    ],
                                    child: const ArchivedChatsScreen(),
                                  )))
                    },
                  ),
                  BottomSheetItem(
                    title: 'Turn-Off Notification',
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (context) => ProfileBloc()
                                          ..add(const FetchSettingEvent()),
                                      ),
                                    ],
                                    child: const NotificationScreen(),
                                  )))
                    },
                  ),
                  BottomSheetItem(
                    title: 'Add Friends',
                    onTap: () => {
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
                                          create: (context) => ChartBloc())
                                    ],
                                    child: const AddFriendsScreen(
                                        header: 'Add Friend'),
                                  )))
                    },
                  ),
                ],
              );
            },
          )
        ],
        showLeadingIcon: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FriendsBloc, FriendsState>(
            listener: (context, state) {
              if (state is FriendsListLoading) {
                setState(() {
                  isFriendsListLoad = true;
                });
              } else if (state is FriendsListSuccess) {
                setState(() {
                  friends = state.friendsSearchList;
                  isFriendsListLoad = false;
                });
              } else if (state is FriendsListFailed) {
                setState(() {
                  isFriendsListLoad = false;
                });
              }
            },
          ),
          BlocListener<ChartBloc, ChartState>(
            listener: (context, state) {
              if (state is ChartListLoading) {
                setState(() {
                  isChatListLoading = true;
                });
              } else if (state is ChartListSuccess) {
                setState(() {
                  chatList = state.chatList;
                  isChatListLoading = false;
                  isError = false;
                  print('-----------------111111111111-----------');
                });
              } else if (state is ChartListFailed) {
                setState(() {
                  isChatListLoading = false;
                  isError = true;
                });
              }
            },
          ),
        ],
        child: SafeArea(
            child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatListSearch(chatList: chatList),
                        ));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.blockWidth * 4.5,
                        top: SizeConfig.blockHeight * 2,
                        right: SizeConfig.blockWidth * 4.5,
                        bottom: SizeConfig.blockHeight),
                    child: Container(
                      height: SizeConfig.blockHeight * 7,
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 4.5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3),
                        color: COLORS.neutralDarkTwo.withOpacity(0.6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: COLORS.neutralDarkOne,
                            size: SizeConfig.blockWidth * 5,
                          ),
                          SizedBox(
                            width: SizeConfig.blockWidth * 4,
                          ),
                          Text(
                            'Search your chats'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 3.25,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: COLORS.neutralDarkTwo,
                ),
                if (isChatListLoading && isFriendsListLoad) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 2.5,
                      vertical: SizeConfig.blockHeight * 0.2,
                    ),
                    child: friendsListLoading(),
                  )
                ]
                else...[
                  Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: SizeConfig.blockHeight),
                            if (!isFriendsListLoad && friends.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 4.5,
                                ),
                                child: addFriendText(
                                    textOne: 'Friends',
                                    textTwo: 'View All',
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                    create: (context) =>
                                                    FriendsBloc()
                                                      ..add(
                                                          FetchFriendsListEvent(
                                                              page: 1,
                                                              pageSize: 10,
                                                              keyWord: '')),
                                                  ),
                                                  BlocProvider(
                                                      create: (context) =>
                                                          ReportPostBloc()),
                                                  BlocProvider(
                                                      create: (context) =>
                                                          ChartBloc()),
                                                  BlocProvider(
                                                      create: (context) =>
                                                          ShowInterestedBloc())
                                                ],
                                                child: FriendsSearchListScreen(
                                                  refreshPageCallback:
                                                  _refreshPageAfterEdit,
                                                ),
                                              )));
                                    }),
                              ),
                              SizedBox(
                                height: SizeConfig.blockHeight * 18,
                                child: ListView.builder(
                                    itemCount: min(friends.length, 8),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: SizeConfig.blockWidth * 2.5),
                                    itemBuilder: (context, index) {
                                      return friendViewCard(
                                          image: friends[index].friends.profilePic,
                                          name: friends[index].friends.name,
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MultiBlocProvider(
                                                          providers: [
                                                            BlocProvider(
                                                              create: (context) {
                                                                final bloc =
                                                                FriendsBloc();
                                                                bloc.add(
                                                                    FetchFriendsSingleView(
                                                                        friendId: friends[
                                                                        index]
                                                                            .friends
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
                                                            BlocProvider(
                                                                create: (context) =>
                                                                    ShowInterestedBloc()),
                                                            BlocProvider(
                                                                create: (context) =>
                                                                    ChartBloc())
                                                          ],
                                                          child: FriendsDetailsScreen(
                                                            refreshPageCallback:
                                                            _refreshPageAfterEdit,
                                                            id: friends[index]
                                                                .friends
                                                                .id,
                                                          ),
                                                        )));
                                          });
                                    }),
                              ),
                              const Divider(
                                color: COLORS.neutralDarkTwo,
                              ),
                            ],

                            if (!isChatListLoading && chatList.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 4.5,
                                  vertical: SizeConfig.blockHeight * 0.2,
                                ),
                                child: ListView.builder(
                                    itemCount: chatList.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, index) {
                                      return chartSearchCards(
                                          image: chatList[index].picture!,
                                          name: chatList[index].name!,
                                          onTapCard: () {
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
                                                                    chatId: chatList[
                                                                    index]
                                                                        .chatId!)),
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
                                                            chatId: chatList[index]
                                                                .chatId!,
                                                            isGroup: chatList[index]
                                                                .isGroup!,
                                                          ),
                                                        )));
                                          },
                                          message:
                                          chatList[index].latestMessage != null
                                              ? chatList[index]
                                              .latestMessage!
                                              .content!
                                              : "",
                                          count: chatList[index].unreadCount!,
                                          isGroup: chatList[index].isGroup!,
                                          date: formatChatDate(
                                              chatList[index].updatedAt!));
                                    }),
                              )
                            ] else if (!isChatListLoading && chatList.isEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 2.5,
                                  vertical: SizeConfig.blockHeight * 4,
                                ),
                                child: emptyComponent(errorText: "No Chats Found"),
                              )
                            ] else if (isError && !isChatListLoading) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 2.5,
                                  vertical: SizeConfig.blockHeight * 4,
                                ),
                                child: ErrorScreen(onRetry: () {
                                  _refreshPageAfterEdit();
                                }),
                              )
                            ]
                          ],
                        ),
                      ))
                ],
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
                                        create: (context) => ChartBloc())
                                  ],
                                  child: const AddFriendsScreen(
                                      header: 'Add Friend'),
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
      ),
    );
  }
}
