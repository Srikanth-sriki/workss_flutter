import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
import 'package:works_app/ui/home/component.dart';

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
import '../onboarding/select_user_type.dart';
import '../profile/notification.dart';
import 'addFriends.dart';
import 'blocked_chat_list.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen>
    with AutomaticKeepAliveClientMixin {
  late FriendsBloc friendsBloc;
  late ChartBloc chartBloc;

  // last good data caches (no flicker)
  List<Friend> _friends = [];
  int _friendCount = 0;

  List<ChatList> _allChats = [];
  List<ChatList> _requests = [];

  // overlay = local, optimistic updates from socket
  final Map<String, _ChatOverlay> _overlay = {};

  String _selectedTab = 'All';
  final ScrollController _scrollController = ScrollController();

  // first load gate + background indicator
  bool _hasLoadedOnce = false;   // ✅ controls the big spinner only once
  bool _bgLoading = false;       // slim top bar for background refresh

  // socket
  late io.Socket socket;
  bool _mounted = false;
  Timer? _refreshThrottle;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mounted = true;

    Config.chatHasNewMessage.value = false;

    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);

    // socket
    socket = io.io(Config.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionDelay': 500,
      'reconnectionDelayMax': 5000,
    });

    _connectToSocket();

    // initial fetch once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  @override
  void dispose() {
    _mounted = false;
    _refreshThrottle?.cancel();
    socket
      ..off('connect')
      ..off('connect_error')
      ..off('reconnect')
      ..off('disconnect')
      ..off('new_message')
      ..disconnect();

    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // leave empty to avoid duplicate fetches
  }

  // ========== SOCKET ==========

  void _connectToSocket() {

    socket.connect();

    // socket.on('connect', (_) {
    //   debugPrint('[socket] connected: ${socket.id}');
    //   socket.emit('join', {'userId': Config.id}); // adjust if your backend needs different key
    // });
    //
    // socket.on('connect_error', (e) => debugPrint('[socket] connect_error: $e'));
    // socket.on('reconnect', (attempt) {
    //   debugPrint('[socket] reconnect: $attempt');
    //   socket.emit('join', {'userId': Config.id});
    // });
    // socket.on('disconnect', (reason) => debugPrint('[socket] disconnected: $reason'));

    socket.on('new_message', (data) {
      print(data);
      _fetchData(background: true);
      if (!_mounted) return;
      // 1) apply locally → instant UI
      _applyIncomingMessage(data);
      // 2) reconcile in background (no big loader)
      _refreshThrottle?.cancel();
      _refreshThrottle = Timer(const Duration(milliseconds: 800), () {
        _fetchData(background: true);
      });
    });
  }

  /// Expected payload (adjust names if needed):
  /// {
  ///   "chat_id": "...",
  ///   "name": "...",
  ///   "picture": "...",
  ///   "content": "Hi",
  ///   "updatedAt": "2025-08-16T12:53:26.659Z",
  ///   "unread_inc": 1
  /// }
  void _applyIncomingMessage(dynamic raw) {
    try {
      final map = Map<String, dynamic>.from(raw as Map);
      final String chatId = map['chat_id'] as String;
      final String? name = map['name'] as String?;
      final String? picture = map['picture'] as String?;
      final String? content = map['content'] as String?;
      final DateTime updatedAt =
          DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now();
      final int inc = (map['unread_inc'] is int) ? map['unread_inc'] as int : 1;

      final idx = _allChats.indexWhere((c) => c.chatId == chatId);
      if (idx >= 0) {
        final item = _allChats[idx];
        setState(() {
          final prevDelta = _overlay[chatId]?.unreadDelta ?? 0;
          _overlay[chatId] = _ChatOverlay(
            latestPreview: content ?? _overlay[chatId]?.latestPreview,
            updatedAt: updatedAt,
            unreadDelta: prevDelta + inc,
            nameOverride: name,
            pictureOverride: picture,
          );

          // move to top
          _allChats.removeAt(idx);
          _allChats.insert(0, item);

          // show slim bar only (no big spinner)
          if (!_bgLoading) _bgLoading = true;
        });
      } else {
        // chat missing → keep overlay preview; full data will arrive with background fetch
        setState(() {
          _overlay[chatId] = _ChatOverlay(
            latestPreview: content,
            updatedAt: updatedAt,
            unreadDelta: inc,
            nameOverride: name,
            pictureOverride: picture,
          );
          if (!_bgLoading) _bgLoading = true;
        });
      }
    } catch (e) {
      debugPrint('[socket] new_message parse error: $e');
    }
  }

  // ========== FETCHING ==========

  void _fetchData({bool background = false}) {
    // show slim bar only for subsequent loads
    if ((_hasLoadedOnce || background) && !_bgLoading) {
      setState(() => _bgLoading = true);
    }
    friendsBloc.add(FetchFriendsListEvent(page: 1, pageSize: 10, keyWord: ''));
    chartBloc.add(const ChartListEvent());
    chartBloc.add(const RequestedChartListEvent());
  }

  // ========== FILTER ==========

  List<ChatList> _applyFilter() {
    switch (_selectedTab) {
      case 'Chat':
        return _allChats.where((c) => c.isGroup == false).toList();
      case 'Groups':
        return _allChats.where((c) => c.isGroup == true).toList();
      case 'Requests':
        return _requests;
      default:
        return _allChats;
    }
  }

  // ========== UI ==========

  Widget _tab(String label) {
    final sel = _selectedTab == label;
    return InkWell(
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.25),
      onTap: () {
        if (sel) return;
        setState(() => _selectedTab = label);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.blockHeight * 1,
          horizontal: SizeConfig.blockWidth * 3,
        ),
        decoration: BoxDecoration(
          color: sel ? COLORS.primary : COLORS.neutralDarkTwo,
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.25),
        ),
        child: Text(
          label.tr(),
          style: TextStyle(
            color: sel ? COLORS.white : COLORS.neutralDark,
            fontSize: SizeConfig.blockWidth * 3.2,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!Config.profileCompleted) {
      return _registerGate(context);
    }

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
            onPressed: _showOptions,
          ),
        ],
        showLeadingIcon: false,
      ),
      body: MultiBlocListener(
        listeners: [
          // FRIENDS
          BlocListener<FriendsBloc, FriendsState>(
            listener: (context, state) {
              if (state is FriendsListSuccess) {
                setState(() {
                  _friends = state.friendsSearchList;
                  _friendCount = state.friendsSearchList.length ?? 0;
                });
              }
            },
          ),
          // CHATS
          BlocListener<ChartBloc, ChartState>(
            listener: (context, state) {
              if (state is ChartListSuccess) {
                setState(() {
                  _allChats = state.chatList;
                  _bgLoading = false;
                  _hasLoadedOnce = true;
                });
              } else if (state is RequestedChartListSuccess) {
                setState(() {
                  _requests = state.chatList;
                  _bgLoading = false;
                  _hasLoadedOnce = true;
                });
              } else if (state is ChartListFailed ||
                  state is RequestedChartListFailed) {
                if (_bgLoading) setState(() => _bgLoading = false);
                _hasLoadedOnce = true;
              }
            },
          ),
        ],
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // search
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: COLORS.neutralDarkTwo,
                          width: SizeConfig.blockWidth * 0.15,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: SizeConfig.blockWidth * 4.5,
                        top: SizeConfig.blockHeight * 2,
                        right: SizeConfig.blockWidth * 4.5,
                        bottom: SizeConfig.blockHeight,
                      ),
                      child: InkWell(
                        splashColor: Colors.white.withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(SizeConfig.blockWidth * 3.5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatListSearch(chatList: _allChats),
                            ),
                          );
                        },
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
                              Image.asset(
                                'assets/images/home/search.png',
                                width: SizeConfig.blockWidth * 5.5,
                                height: SizeConfig.blockWidth * 5.5,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: SizeConfig.blockWidth * 4),
                              Text(
                                'Search your chats'.tr(),
                                style: TextStyle(
                                  color: COLORS.neutralDarkOne,
                                  fontSize: SizeConfig.blockWidth * 3.25,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FRIENDS STRIP
                          if (_friends.isNotEmpty) ...[
                            SizedBox(height: SizeConfig.blockHeight),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockWidth * 4.5,
                              ),
                              child: addFriendText(
                                textOne: 'Friends',
                                textTwo: '${'View All'.tr()}(${_friends.length})',
                                onTap: _openFriendsViewAll,
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.blockHeight * 18,
                              child: ListView.builder(
                                itemCount: min(_friends.length, 8),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.blockWidth * 2.5),
                                itemBuilder: (context, index) {
                                  final f = _friends[index].friends;
                                  return friendViewCard(
                                    image: f.profilePic,
                                    name: f.name,
                                    onTap: () => _startDirectChat(f.id),
                                  );
                                },
                              ),
                            ),
                          ],

                          // CHATS
                          if (!_hasLoadedOnce)
                          // ✅ full-screen loader ONLY on first time
                            SizedBox(
                              height: SizeConfig.blockHeight * 60,
                              child: Center(
                                child: LoadingAnimationWidget.hexagonDots(
                                  color: COLORS.primary,
                                  size: SizeConfig.blockHeight * 7,
                                ),
                              ),
                            )
                          else ...[
                            Container(
                              decoration: BoxDecoration(
                                color: COLORS.primaryOne.withOpacity(0.1),
                                border: Border(
                                  top: BorderSide(
                                    color: COLORS.neutralDarkTwo,
                                    width: SizeConfig.blockWidth * 0.3,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockWidth * 4.5,
                                vertical: SizeConfig.blockHeight * 1,
                              ),
                              child: Row(
                                children: [
                                  _tab('All'),
                                  SizedBox(width: SizeConfig.blockWidth * 2),
                                  _tab('Chat'),
                                  SizedBox(width: SizeConfig.blockWidth * 2),
                                  _tab('Groups'),
                                  SizedBox(width: SizeConfig.blockWidth * 2),
                                  _tab('Requests'),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockWidth * 4.5,
                                vertical: SizeConfig.blockHeight * 0.2,
                              ),
                              child: Builder(
                                builder: (_) {
                                  final list = _applyFilter();
                                  if (list.isEmpty) {
                                    return SizedBox(
                                      width: SizeConfig.blockWidth * 100,
                                      height: SizeConfig.blockHeight * 50,
                                      child: Center(
                                        child: emptyComponent(
                                            errorText: "No Chats Found"),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: list.length,
                                    shrinkWrap: true,
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final chat = list[index];
                                      final o = _overlay[chat.chatId];

                                      final preview =
                                          o?.latestPreview ?? chat.latestMessage?.content ?? "";
                                      final ts =
                                          o?.updatedAt ?? chat.updatedAt!;

                                      // ✅ safe unread cast (fixes Object + int)
                                      final baseUnread = int.tryParse(
                                        chat.unreadCount?.toString() ?? '0',
                                      ) ??
                                          0;
                                      final unread = baseUnread + (o?.unreadDelta ?? 0);

                                      final picture = o?.pictureOverride ?? chat.picture!;
                                      final name = o?.nameOverride ?? chat.name!;

                                      return GestureDetector(
                                        onLongPress: () =>{
                                          if(chat.isGroup! == false){
                                            _confirmDelete(chat.chatId!,chat.isGroup!),
                                          }
                                        },
                                        child: chartSearchCards(
                                          image: picture,
                                          name: name,
                                          onTapCard: () => _openChat(chat),
                                          message: preview,
                                          count: unread.toString(),
                                          isGroup: chat.isGroup!,
                                          date: formatChatDate(ts),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ slim top bar only for background fetches after first load
              if (_bgLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: COLORS.primary,
                    backgroundColor: COLORS.neutralDarkTwo,
                  ),
                ),

              // FAB
              Positioned(
                bottom: SizeConfig.blockHeight * 2.5,
                right: SizeConfig.blockHeight * 4,
                child: FloatingActionButton(
                  onPressed: _openAddFriends,
                  backgroundColor: COLORS.primary,
                  child: Image.asset(
                    'assets/images/chat/add_friend.png',
                    width: SizeConfig.blockWidth * 6.5,
                    height: SizeConfig.blockWidth * 6.5,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==== helpers (navigation/actions) ====

  void _openFriendsViewAll() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => FriendsBloc()
              ..add(FetchFriendsListEvent(page: 1, pageSize: 10, keyWord: ''))),
            BlocProvider(create: (_) => ReportPostBloc()),
            BlocProvider(create: (_) => ChartBloc()),
            BlocProvider(create: (_) => ShowInterestedBloc()),
          ],
          child: FriendsSearchListScreen(
            refreshPageCallback: () {
              _selectedTab = 'All';
              _fetchData(background: true);
            },
          ),
        ),
      ),
    );
  }

  void _startDirectChat(String userId) {
    chartBloc.add(StartMessageEvent(
      chatId: userId,
      onSuccess: (chatId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ChartBloc()
                  ..add(FetchChartViewEvent(page: 1, pageSize: 10, chatId: chatId))),
                BlocProvider(create: (_) => InitialRegisterBloc()),
                BlocProvider(create: (_) => ShowInterestedBloc()),
              ],
              child: ChatViewScreen(
                refreshPageCallback: () {
                  _selectedTab = 'All';
                  _fetchData(background: true);
                },
                chatId: chatId,
                isGroup: false,
                isRequest: false,
              ),
            ),
          ),
        );
      },
      onError: (msg) => showCustomSnackBar(
        context: context,
        message: msg,
        backgroundColor: COLORS.neutralDarkTwo,
      ),
    ));
  }

  void _openChat(ChatList chat) {
    socket.emit('open_chat', {'userId': Config.id, 'chatId': chat.chatId!});

    // opening chat resets local unread overlay for that chat
    setState(() {
      final o = _overlay[chat.chatId!];
      if (o != null) _overlay[chat.chatId!] = o.copyWith(unreadDelta: 0);
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ChartBloc()
              ..add(FetchChartViewEvent(page: 1, pageSize: 10, chatId: chat.chatId!))),
            BlocProvider(create: (_) => InitialRegisterBloc()),
            BlocProvider(create: (_) => ShowInterestedBloc()),
          ],
          child: ChatViewScreen(
            refreshPageCallback: () {
              _selectedTab = 'All';
              _fetchData(background: true);
            },
            chatId: chat.chatId!,
            isGroup: chat.isGroup!,
            isRequest: chat.isRequest! && (Config.id != chat.requestedBy),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String chatId, bool isGroup) {
    showCustomAlertDialog(
      context: context,
      title: 'Delete Chat',
      message: 'Are you sure you want to delete this chat?',
      positiveButtonText: 'Delete',
      negativeButtonText: 'Cancel',
      onPositivePressed: () {
        if (isGroup) {
          chartBloc.add(DeleteGroupEvent(
            chatId: chatId,
            onSuccess: (message) {
              Navigator.of(context).pop();
              showCustomSnackBar(
                context: context,
                message: message,
                backgroundColor: COLORS.neutralDarkTwo,
              );
              _fetchData(background: true); // background refresh only
            },
            onError: (message) {
              showCustomSnackBar(context: context, message: message);
            },
          ));
        }
        else{
          chartBloc.add(DeleteChartEvent(
            chatId: chatId,
            onSuccess: (message) {
              Navigator.of(context).pop();
              showCustomSnackBar(
                context: context,
                message: message,
                backgroundColor: COLORS.neutralDarkTwo,
              );
              _fetchData(background: true); // background refresh only
            },
            onError: (message) {
              showCustomSnackBar(context: context, message: message);
            },
          ));
        }

      },
      onNegativePressed: () => Navigator.of(context).pop(),
    );
  }

  void _openAddFriends() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => FriendsBloc()
              ..add(FetchFriendsAddListEvent(page: 1, pageSize: 10, keyWord: ''))),
            BlocProvider(create: (_) => ShowInterestedBloc()),
            BlocProvider(create: (_) => ChartBloc()
              ..add(FetchChartSearchListEvent(page: 1, pageSize: 10, keyWord: ''))),
          ],
          child: AddFriendsScreen(
            header: 'Add Friend',
            refreshPageCallback: () {
              _selectedTab = 'All';
              _fetchData(background: true);
            },
          ),
        ),
      ),
    );
  }

  void _showOptions() {
    showDynamicBottomSheet(
      context,
      'Chat Options',
      [
        if (_friendCount != 0)
          BottomSheetItem(
            title: '${'Friends'.tr()}($_friendCount)',
            onTap: () {
              Navigator.pop(context);
              _openFriendsViewAll();
            },
          ),
        BottomSheetItem(
          title: 'Create new group',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => ChartBloc()),
                    BlocProvider(create: (_) => InitialRegisterBloc()),
                    BlocProvider(create: (_) => FriendsBloc()
                      ..add(FetchFriendsListEvent(page: 1, pageSize: 10, keyWord: ''))),
                  ],
                  child: const CreateGroupScreen(),
                ),
              ),
            );
          },
        ),
        BottomSheetItem(
          title: 'Archived Chats',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => ChartBloc()
                      ..add(const ArchivedChartListEvent())),
                  ],
                  child: const ArchivedChatsScreen(),
                ),
              ),
            );
          },
        ),
        BottomSheetItem(
          title: 'Turn-Off Notification',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => ProfileBloc()
                      ..add(const FetchSettingEvent())),
                  ],
                  child: const NotificationScreen(),
                ),
              ),
            );
          },
        ),
        BottomSheetItem(
          title: 'Add Friends',
          onTap: () {
            Navigator.pop(context);
            _openAddFriends();
          },
        ),
        BottomSheetItem(
          title: 'Blocked Chats/Friends',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => ChartBloc()
                      ..add(const BlockedChatList())),
                  ],
                  child: BlockedChatsScreen(
                    refreshPageCallback: () {
                      _selectedTab = 'All';
                      _fetchData(background: true);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _registerGate(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: COLORS.white, elevation: 0),
      body: SafeArea(
        child: SizedBox(
          width: SizeConfig.screenWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  'Register now to unlock full access and personalized features.'.tr(),
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
                      MaterialPageRoute(builder: (_) => const SelectUserType()),
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

// ===== overlay VM =====

class _ChatOverlay {
  final String? latestPreview;
  final DateTime? updatedAt;
  final int unreadDelta;
  final String? nameOverride;
  final String? pictureOverride;

  _ChatOverlay({
    this.latestPreview,
    this.updatedAt,
    this.unreadDelta = 0,
    this.nameOverride,
    this.pictureOverride,
  });

  _ChatOverlay copyWith({
    String? latestPreview,
    DateTime? updatedAt,
    int? unreadDelta,
    String? nameOverride,
    String? pictureOverride,
  }) {
    return _ChatOverlay(
      latestPreview: latestPreview ?? this.latestPreview,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadDelta: unreadDelta ?? this.unreadDelta,
      nameOverride: nameOverride ?? this.nameOverride,
      pictureOverride: pictureOverride ?? this.pictureOverride,
    );
  }
}