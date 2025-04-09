import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:works_app/bloc/friends/friends_bloc.dart';
import 'package:works_app/bloc/register_account/initial_register_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/config.dart';
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
import '../../helper/socket_service.dart';
import '../../models/chat/charts_list_modal.dart';
import '../../models/friends/friends_search_list_modal.dart';
import '../friends/friends_details.dart';
import '../home/component.dart';
import '../onboarding/select_user_type.dart';
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
  int friendListCount = 0;

  @override
  void initState() {
    super.initState();
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
    SocketService().reconnect();
  }

  void _refreshPageAfterEdit() {
    _fetchData();
  }

  void _fetchData() {
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
    return Config.profileCompleted
        ? Scaffold(
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
                        if(friendListCount != 0)...[
                          BottomSheetItem(
                            title: 'Friends(${friendListCount})',
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (context) => FriendsBloc()
                                              ..add(FetchFriendsListEvent(
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
                                      )))
                            },
                          ),
                        ],
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
                                                create: (context) =>
                                                    FriendsBloc()
                                                      ..add(
                                                          FetchFriendsListEvent(
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
                                                ..add(
                                                    const ArchivedChartListEvent()),
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
                                                ..add(
                                                    const FetchSettingEvent()),
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
                                                create: (context) =>
                                                    ChartBloc())
                                          ],
                                          child: AddFriendsScreen(
                                            header: 'Add Friend',
                                            refreshPageCallback:
                                                _refreshPageAfterEdit,
                                          ),
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
                        friendListCount = state.friendsSearchList.length!;
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
                      Padding(
                        padding: EdgeInsets.only(
                            left: SizeConfig.blockWidth * 4.5,
                            top: SizeConfig.blockHeight * 2,
                            right: SizeConfig.blockWidth * 4.5,
                            bottom: SizeConfig.blockHeight),
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              SizeConfig.blockWidth * 3.5),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatListSearch(chatList: chatList),
                                ));
                          },
                          child: Container(
                            height: SizeConfig.blockHeight * 7,
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockWidth * 4.5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3),
                              color: COLORS.neutralDarkTwo.withOpacity(0.6),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/home/search.png',
                                  width: SizeConfig.blockWidth * 5.5,
                                  height: SizeConfig.blockWidth * 5.5,
                                  fit: BoxFit.contain,
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
                      Expanded(
                          child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: SizeConfig.blockHeight),
                            if (isChatListLoading && isFriendsListLoad) ...[
                              SizedBox(
                                height: SizeConfig.blockHeight * 60,
                                child: Center(
                                  child: Container(
                                    height: SizeConfig.screenHeight,
                                    width: SizeConfig.screenWidth,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: SizeConfig.blockWidth * 4),
                                    child: Center(
                                      child: LoadingAnimationWidget.hexagonDots(
                                        color: COLORS.primary,
                                        size: SizeConfig.blockHeight * 7,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
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
                                              builder: (context) =>
                                                  MultiBlocProvider(
                                                    providers: [
                                                      BlocProvider(
                                                        create: (context) =>
                                                            FriendsBloc()
                                                              ..add(
                                                                  FetchFriendsListEvent(
                                                                      page: 1,
                                                                      pageSize:
                                                                          10,
                                                                      keyWord:
                                                                          '')),
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
                                                    child:
                                                        FriendsSearchListScreen(
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
                                        horizontal:
                                            SizeConfig.blockWidth * 2.5),
                                    itemBuilder: (context, index) {
                                      return friendViewCard(
                                          image:
                                              friends[index].friends.profilePic,
                                          name: friends[index].friends.name,
                                          onTap: () {
                                            chartBloc.add(StartMessageEvent(
                                                chatId:
                                                    friends[index].friends!.id,
                                                onSuccess: (chatId) {
                                                  print(chatId);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MultiBlocProvider(
                                                                providers: [
                                                                  BlocProvider(
                                                                    create: (context) => ChartBloc()
                                                                      ..add(FetchChartViewEvent(
                                                                          page:
                                                                              1,
                                                                          pageSize:
                                                                              10,
                                                                          chatId:
                                                                              chatId)),
                                                                  ),
                                                                  BlocProvider(
                                                                      create: (context) =>
                                                                          InitialRegisterBloc()),
                                                                  BlocProvider(
                                                                      create: (context) =>
                                                                          ShowInterestedBloc()),
                                                                ],
                                                                child:
                                                                    ChatViewScreen(
                                                                  refreshPageCallback:
                                                                      _refreshPageAfterEdit,
                                                                  chatId:
                                                                      chatId,
                                                                  isGroup:
                                                                      false,
                                                                ),
                                                              )));
                                                },
                                                onError: (message) {
                                                  showCustomSnackBar(
                                                      context: context,
                                                      message: message,
                                                      backgroundColor: COLORS
                                                          .neutralDarkTwo);
                                                }));
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
                                                                    pageSize:
                                                                        10,
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
                                                            chatId:
                                                                chatList[index]
                                                                    .chatId!,
                                                            isGroup:
                                                                chatList[index]
                                                                    .isGroup!,
                                                          ),
                                                        )));
                                          },
                                          message:
                                              chatList[index].latestMessage !=
                                                      null
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
                            ],
                            if (!isChatListLoading && chatList.isEmpty) ...[
                              Container(
                                width: SizeConfig.blockWidth*100,
                                height: SizeConfig.blockHeight*70,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    emptyComponent(errorText: "No Chats Found"),
                                  ],
                                ),
                              )
                            ] else if (isError && !isChatListLoading) ...[
                              Container(
                                width: SizeConfig.blockWidth*100,
                                height: SizeConfig.blockHeight*70,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ErrorScreen(onRetry: () {
                                      _refreshPageAfterEdit();
                                    }),
                                  ],
                                ),
                              )
                            ]
                          ],
                        ),
                      ))
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
                                        child: AddFriendsScreen(
                                            header: 'Add Friend',
                                            refreshPageCallback:
                                                _refreshPageAfterEdit),
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
          )
        : Scaffold(
            backgroundColor: COLORS.white,
            appBar: AppBar(
              toolbarHeight: 0,
              backgroundColor: COLORS.white,
              elevation: 0,
            ),
            body: SafeArea(
              child: SizedBox(
                width: SizeConfig.screenWidth,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/chat/user_register.png',
                        width: SizeConfig.blockWidth * 60,
                        height: SizeConfig.blockWidth * 60,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: SizeConfig.blockHeight * 3),
                      Text(
                        'Create an Account'.tr(),
                        style: TextStyle(
                          color: COLORS.neutralDark,
                          fontSize: SizeConfig.blockWidth * 5,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: SizeConfig.blockHeight * 1.5),
                      Text(
                        'Register now to unlock full access and personalized features.'
                            .tr(),
                        style: TextStyle(
                          color: COLORS.neutralDark,
                          fontSize: SizeConfig.blockWidth * 3.6,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: SizeConfig.blockHeight * 5),
                      customButton(
                        text: 'REGISTER NOW'.tr(),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const SelectUserType(),
                            ),
                          );
                        },
                        backgroundColor: COLORS.primary,
                        showIcon: false,
                        width: SizeConfig.blockWidth * 55,
                        height: SizeConfig.blockHeight * 7.5,
                        textColor: COLORS.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
