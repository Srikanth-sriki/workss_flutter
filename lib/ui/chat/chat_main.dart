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
import '../../global_helper/popup.dart';
import '../../helper/socket_service.dart';
import '../../models/chat/charts_list_modal.dart';
import '../../models/friends/friends_search_list_modal.dart';
import '../friends/friends_details.dart';
import '../home/component.dart';
import '../onboarding/select_user_type.dart';
import '../profile/notification.dart';
import 'addFriends.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'blocked_chat_list.dart';

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
  List<ChatList> requestChatList = [];
  List<ChatList> filteredChatList = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isFriendsListLoad = true;
  bool isChatListLoading = true;
  bool isError = false;
  Timer? _debounce;
  String searchKeyword = "";
  int friendListCount = 0;
  late io.Socket socket;
  String selectedTab = 'All';
  bool _isMounted = false;
  bool screenReload = true;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    setState(() {
      Config.chatHasNewMessage.value = false;
    });
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
    socket = io.io(Config.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    if (!socket.connected) {
      SocketService().reconnect();
    }
    connectToSocket();
  }

  void connectToSocket() {
    socket.on('new_message', (data) {
      if (_isMounted) {
        setState(() {
          setState(() {
            screenReload = false;
          });
          _fetchData();

          print(data);
        });
      }
    });
  }

  void _refreshPageAfterEdit() {
    setState(() {
      screenReload = true;
      selectedTab = 'All';
    });
    _fetchData();

  }

  void _fetchData() {
    friendsBloc.add(FetchFriendsListEvent(
      page: 1,
      pageSize: 10,
      keyWord: '',
    ));
    chartBloc.add(const ChartListEvent());
    chartBloc.add(const RequestedChartListEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      screenReload = true;
    });
    _fetchData();
  }

  @override
  void dispose() {
    _isMounted = false;

    socket.off('new_message');
    socket.disconnect();
    _scrollController.dispose();
    super.dispose();
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
                        if (friendListCount != 0) ...[
                          BottomSheetItem(
                            title: '${'Friends'.tr()}($friendListCount)',
                            onTap: () => {
                              Navigator.pop(context),
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
                                          )))
                            },
                          ),
                        ],
                        BottomSheetItem(
                          title: 'Create new group',
                          onTap: () => {
                            Navigator.pop(context),
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
                            Navigator.pop(context),
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
                            Navigator.pop(context),
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
                            Navigator.pop(context),
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
                                                create: (context) => ChartBloc()
                                                  ..add(
                                                      FetchChartSearchListEvent(
                                                          page: 1,
                                                          pageSize: 10,
                                                          keyWord: '')))
                                          ],
                                          child: AddFriendsScreen(
                                            header: 'Add Friend',
                                            refreshPageCallback:
                                                _refreshPageAfterEdit,
                                          ),
                                        )))
                          },
                        ),
                        BottomSheetItem(
                          title: 'Blocked Chats/Friends',
                          onTap: () => {
                            Navigator.pop(context),
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiBlocProvider(
                                          providers: [
                                            BlocProvider(
                                              create: (context) => ChartBloc()
                                                ..add(const BlockedChatList()),
                                            ),
                                          ],
                                          child: BlockedChatsScreen(
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
                        if (screenReload) {
                          isChatListLoading = true;
                        }
                      });
                    } else if (state is ChartListSuccess) {
                      setState(() {
                        chatList = state.chatList;
                        filteredChatList = state.chatList;
                        isChatListLoading = false;
                        isError = false;
                      });
                    } else if (state is ChartListFailed) {
                      setState(() {
                        isChatListLoading = false;
                        isError = true;
                      });
                    } else if (state is RequestedChartListLoading) {
                      setState(() {
                        if (screenReload) {
                          isChatListLoading = true;
                        }
                      });
                    } else if (state is RequestedChartListSuccess) {
                      setState(() {
                        requestChatList = state.chatList;
                        isChatListLoading = false;
                        isError = false;
                      });
                    } else if (state is RequestedChartListFailed) {
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
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: COLORS.neutralDarkTwo,
                                    width: SizeConfig.blockWidth * 0.15))),
                        child: Padding(
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
                      ),
                      // const Divider(
                      //   color: COLORS.neutralDarkTwo,
                      // ),
                      Expanded(
                          child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              SizedBox(height: SizeConfig.blockHeight),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 4.5,
                                ),
                                child: addFriendText(
                                    textOne: 'Friends',
                                    textTwo: '${'View All'.tr()}(${friends.length})',
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
                                                                  chatId: chatId,
                                                                  isGroup: false, isRequest: false,
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
                              // const Divider(
                              //   color: COLORS.neutralDarkTwo,
                              // ),
                            ],
                            if (!isChatListLoading && chatList.isNotEmpty) ...[
                              Container(
                                decoration: BoxDecoration(
                                    color: COLORS.primaryOne.withOpacity(0.1),
                                    border: Border(
                                        top: BorderSide(
                                            color: COLORS.neutralDarkTwo,
                                            width:
                                                SizeConfig.blockWidth * 0.3))),
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 4.5,
                                  vertical: SizeConfig.blockHeight * 1,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildTabButton('All'),
                                    SizedBox(
                                      width: SizeConfig.blockWidth * 2,
                                    ),
                                    _buildTabButton('Chat'),
                                    SizedBox(
                                      width: SizeConfig.blockWidth * 2,
                                    ),
                                    _buildTabButton('Groups'),
                                    SizedBox(
                                      width: SizeConfig.blockWidth * 2,
                                    ),
                                    _buildTabButton('Requests')
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 4.5,
                                  vertical: SizeConfig.blockHeight * 0.2,
                                ),
                                child: ListView.builder(
                                    itemCount: filteredChatList.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, index) {
                                      final chat = filteredChatList[index];

                                      return GestureDetector(
                                        onLongPress: () {
                                          showCustomAlertDialog(
                                            context: context,
                                            title: 'Delete Chat',
                                            message:
                                                'Are you sure you want to delete this chat?',
                                            positiveButtonText: 'Delete',
                                            negativeButtonText: 'Cancel',
                                            onPositivePressed: () {
                                              chartBloc.add(DeleteChartEvent(
                                                  chatId: chat.chatId!,
                                                  onSuccess: (message) {
                                                    Navigator.of(context).pop();
                                                    showCustomSnackBar(
                                                        context: context,
                                                        message: message,
                                                        backgroundColor: COLORS
                                                            .neutralDarkTwo);
                                                    setState(() {
                                                      screenReload = false;
                                                    });
                                                    _fetchData();
                                                  },
                                                  onError: (message) {
                                                    showCustomSnackBar(
                                                      context: context,
                                                      message: message,
                                                    );
                                                  }));
                                            },
                                            onNegativePressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        },
                                        child: chartSearchCards(
                                          image: chat.picture!,
                                          name: chat.name!,
                                          onTapCard: () {
                                            socket.emit("open_chat",
                                                {Config.id, chat.chatId!});
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
                                                                FetchChartViewEvent(
                                                              page: 1,
                                                              pageSize: 10,
                                                              chatId:
                                                                  chat.chatId!,
                                                            )),
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
                                                    chatId: chat.chatId!,
                                                    isGroup: chat.isGroup!,
                                                    isRequest: chat.isRequest! && (Config.id != chat.requestedBy),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          message:
                                              chat.latestMessage?.content ?? "",
                                          count: chat.unreadCount!,
                                          isGroup: chat.isGroup!,
                                          date: formatChatDate(chat.updatedAt!),
                                        ),
                                      );
                                    }),
                              )
                            ],
                            if (!isChatListLoading && chatList.isEmpty) ...[
                              Container(
                                width: SizeConfig.blockWidth * 100,
                                height: SizeConfig.blockHeight * 70,
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
                                width: SizeConfig.blockWidth * 100,
                                height: SizeConfig.blockHeight * 70,
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
                                              create: (context) => ChartBloc()
                                                ..add(FetchChartSearchListEvent(
                                                    page: 1,
                                                    pageSize: 10,
                                                    keyWord: '')))
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

  // Widget _buildTabButton(String label) {
  //   final isSelected = selectedTab == label;
  //   return ElevatedButton(
  //     onPressed: () {
  //       setState(() {
  //         selectedTab = label;
  //         if (selectedTab == 'Chart') {
  //           filteredChatList = chatList
  //               .where((item) => item.isGroup == false)
  //               .toList();
  //         } else if (selectedTab == 'Group') {
  //           filteredChatList = chatList
  //               .where((item) => item.isGroup == true)
  //               .toList();
  //         } else {
  //           filteredChatList = chatList;
  //         }
  //       });
  //     },
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
  //       foregroundColor: isSelected ? Colors.white : Colors.black,
  //     ),
  //     child: Text(label),
  //   );
  // }

  Widget _buildTabButton(String label) {
    final isSelected = selectedTab == label;
    return InkWell(
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.25),
      splashColor: Colors.white.withOpacity(0.1),
      onTap: () {
        setState(() {
          selectedTab = label;
          if (selectedTab == 'Chat') {
            filteredChatList =
                chatList.where((item) => item.isGroup == false).toList();
          } else if (selectedTab == 'Groups') {
            filteredChatList = chatList.where((item) => item.isGroup == true).toList();
          } else if(selectedTab == 'Requests'){
              filteredChatList = requestChatList;
          } else {
            filteredChatList = chatList;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: SizeConfig.blockHeight * 1,
            horizontal: SizeConfig.blockWidth * 3),
        decoration: BoxDecoration(
            color: isSelected ? COLORS.primary : COLORS.neutralDarkTwo,
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.25)),
        child: Text(
          label.tr(),
          style: TextStyle(
            color: isSelected ? COLORS.white : COLORS.neutralDark,
            fontSize: SizeConfig.blockWidth * 3.2,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),
        ),
      ),
    );
  }
}
