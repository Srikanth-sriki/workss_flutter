import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:works_app/bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/config.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/popup.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/notification_list_model.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen>
    with AutomaticKeepAliveClientMixin {
  late NotificationBloc notificationBloc;
  late FriendsBloc friendsBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ChartBloc chartBloc;

  // cached, flattened list for fast rebuilds
  List<GroupedNotificationItem> _displayList = const [];
  int _notificationLength = 0;

  // hint banner
  bool _showHint = false;
  Timer? _hintTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);

    // just flip the notifier; no setState needed
    Config.notificationReceiveMessage.value = false;
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  // build once per new payload
  void _rebuildDisplayList(List<NotificationModel> notifs) {
    final Map<String, List<NotificationModel>> grouped = {};
    for (final n in notifs) {
      final key = formatChatDate(n.createdAt!);
      (grouped[key] ??= <NotificationModel>[]).add(n);
    }

    final List<GroupedNotificationItem> flat = [];
    grouped.forEach((key, items) {
      flat.add(GroupedNotificationItem.header(key));
      for (final notif in items) {
        flat.add(GroupedNotificationItem.item(notif));
      }
    });

    _displayList = flat;
    _notificationLength = notifs.length;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: 'Notifications',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
        actions: [
          if (_notificationLength >= 1)
            TextButton(
              onPressed: () {
                showCustomAlertDialog(
                  context: context,
                  title: 'Do you want to Clear?',
                  message: 'Do you want to Clear all Notifications?',
                  positiveButtonText: 'CLEAR',
                  negativeButtonText: 'CANCEL',
                  onPositivePressed: () {
                    notificationBloc.add(const FetchNotificationClearAll());
                    Navigator.of(context).pop();
                  },
                  onNegativePressed: () => Navigator.of(context).pop(),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(right: SizeConfig.blockWidth * 2),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: COLORS.accent,
                    fontSize: SizeConfig.blockWidth * 3.8,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          BlocConsumer<NotificationBloc, NotificationState>(
            listenWhen: (prev, curr) =>
            curr is NotificationFetchSuccess ||
                curr is NotificationClearSuccess ||
                curr is NotificationClearAllSuccess ||
                curr is NotificationFetchFailure,
            listener: (context, state) {
              if (state is NotificationFetchSuccess) {
                _rebuildDisplayList(state.notifications);

                if (_notificationLength > 0) {
                  _hintTimer?.cancel();
                  setState(() => _showHint = true);
                  _hintTimer = Timer(const Duration(seconds: 3), () {
                    if (!mounted) return;
                    setState(() => _showHint = false);
                  });
                } else {
                  setState(() => _showHint = false);
                }
              } else if (state is NotificationClearSuccess) {
                showCustomSnackBar(
                  context: context,
                  message: state.message,
                  backgroundColor: COLORS.semanticTwo,
                );
              } else if (state is NotificationClearAllSuccess) {
                showCustomSnackBar(
                  context: context,
                  message: state.message,
                  backgroundColor: COLORS.semanticTwo,
                );
              } else if (state is NotificationFetchFailure) {
                showCustomSnackBar(
                  context: context,
                  message: state.message,
                );
              }
            },
            builder: (context, state) {
              if (state is FetchNotificationListLoading &&
                  _displayList.isEmpty) {
                return globalLoadingWidget();
              }

              if (state is NotificationFetchSuccess &&
                  _displayList.isEmpty) {
                return SizedBox(
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.blockHeight * 80,
                  child: emptyComponent(),
                );
              }

              return ListView.builder(
                key: const PageStorageKey('notifications_list'),
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockHeight * 2,
                  horizontal: SizeConfig.blockWidth * 4.5,
                ),
                itemCount: _displayList.length,
                cacheExtent: 800,
                itemBuilder: (context, index) {
                  final item = _displayList[index];
                  if (item.isHeader) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: SizeConfig.blockHeight,
                        top: SizeConfig.blockHeight,
                      ),
                      child: Text(
                        item.header!,
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.25,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    );
                  }

                  final n = item.notification!;
                  final showActions = (n.isRead == false);
                  final bool hasPic =
                  (n.content?.profilePic?.isNotEmpty ?? false);

                  return Dismissible(
                    key: ValueKey(n.id),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      // let the animation proceed; then clear via bloc
                      context
                          .read<NotificationBloc>()
                          .add(FetchNotificationSingleClear(n.id!));
                      return true;
                    },
                    background: _dismissBg(),
                    secondaryBackground: _dismissBg(isEnd: true),
                    child: RepaintBoundary(
                      child: Container(
                        width: SizeConfig.blockWidth * 100,
                        margin: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockHeight,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockHeight * 2,
                          horizontal: SizeConfig.blockWidth * 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(SizeConfig.blockWidth * 3),
                          ),
                          color: COLORS.primaryOne.withOpacity(0.3),
                        ),
                        child: MediaQuery(
                          // tame extreme text scales inside the tile
                          data: MediaQuery.of(context).copyWith(
                            textScaler: const TextScaler.linear(1.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (hasPic)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockWidth * 3),
                                  child: Image.network(
                                    n.content!.profilePic!,
                                    width: SizeConfig.blockWidth * 12,
                                    height: SizeConfig.blockWidth * 12,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (c, child, p) =>
                                    p == null
                                        ? child
                                        : Container(
                                      width:
                                      SizeConfig.blockWidth * 12,
                                      height:
                                      SizeConfig.blockWidth * 12,
                                      color: COLORS.neutralDarkTwo,
                                    ),
                                    errorBuilder: (c, e, s) => Container(
                                      width: SizeConfig.blockWidth * 12,
                                      height: SizeConfig.blockWidth * 12,
                                      color: COLORS.neutralDarkTwo,
                                    ),
                                  ),
                                ),

                              if (hasPic)
                                SizedBox(width: SizeConfig.blockWidth * 2),

                              // 🟢 Text area takes remaining space safely
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.content?.body ?? '',
                                      maxLines:
                                      _isToday(n.createdAt!) ? 1 : 3,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: TextStyle(
                                        color: COLORS.neutralDark,
                                        fontSize:
                                        SizeConfig.blockWidth * 3,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                    if (_isToday(n.createdAt!))
                                      Text(
                                        DateFormat('h:mm a')
                                            .format(n.createdAt!),
                                        style: TextStyle(
                                          color: COLORS.neutralDarkOne,
                                          fontSize:
                                          SizeConfig.blockWidth * 3,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // 🔵 Actions occupy only what they need (no overflow)
                              if (showActions) ...[
                                SizedBox(
                                    width: SizeConfig.blockWidth * 2),

                                _CircleIconButton(
                                  onTap: () {
                                    if (n.type == 'friend_request') {
                                      showInterestedBloc.add(
                                        RejectRequestFriendsEvent(
                                          id: n.content!.requestId!,
                                          onSuccess: (msg) {
                                            showCustomSnackBar(
                                              context: context,
                                              message: msg,
                                              backgroundColor:
                                              COLORS.neutralDarkTwo,
                                            );
                                            notificationBloc.add(
                                              FetchNotificationViewEvent(
                                                  id: n.id!),
                                            );
                                          },
                                          onError: (msg) =>
                                              showCustomSnackBar(
                                                  context: context,
                                                  message: msg),
                                        ),
                                      );
                                    } else if (n.type == 'group_invite') {
                                      chartBloc.add(
                                        RejectGroupChatEvent(
                                          chatId: n.content!.inviteId!,
                                          onSuccess: (msg) {
                                            showCustomSnackBar(
                                              context: context,
                                              message: msg,
                                              backgroundColor:
                                              COLORS.neutralDarkTwo,
                                            );
                                            notificationBloc.add(
                                              FetchNotificationViewEvent(
                                                  id: n.id!),
                                            );
                                          },
                                          onError: (msg) =>
                                              showCustomSnackBar(
                                                  context: context,
                                                  message: msg),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icons.clear,
                                ),

                                SizedBox(
                                    width: SizeConfig.blockWidth * 2),

                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                    SizeConfig.blockWidth * 26,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: customIconButton(
                                      text: n.type == 'friend_request'
                                          ? 'Accept'
                                          : (n.type == 'group_invite'
                                          ? 'Join'
                                          : ''),
                                      onPressed: () {
                                        if (n.type ==
                                            'friend_request') {
                                          showInterestedBloc.add(
                                            AcceptRequestFriendsEvent(
                                              id: n.content!.requestId!,
                                              onSuccess: (msg) {
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: msg,
                                                  backgroundColor: COLORS
                                                      .neutralDarkTwo,
                                                );
                                                notificationBloc.add(
                                                  FetchNotificationViewEvent(
                                                      id: n.id!),
                                                );
                                              },
                                              onError: (msg) =>
                                                  showCustomSnackBar(
                                                      context: context,
                                                      message: msg),
                                            ),
                                          );
                                        } else if (n.type ==
                                            'group_invite') {
                                          chartBloc.add(
                                            AcceptChatEvent(
                                              chatId:
                                              n.content!.inviteId!,
                                              onSuccess: (msg) {
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: msg,
                                                  backgroundColor: COLORS
                                                      .neutralDarkTwo,
                                                );
                                                notificationBloc.add(
                                                  FetchNotificationViewEvent(
                                                      id: n.id!),
                                                );
                                              },
                                              onError: (msg) =>
                                                  showCustomSnackBar(
                                                      context: context,
                                                      message: msg),
                                            ),
                                          );
                                        }
                                      },
                                      width: SizeConfig.blockWidth * 23,
                                      height:
                                      SizeConfig.blockHeight * 6.5,
                                      backgroundColor: COLORS.primary,
                                      textColor: COLORS.white,
                                      showIcon: false,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          if (_showHint)
            Positioned(
              top: SizeConfig.blockHeight * 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: SizeConfig.blockHeight * 8,
                  width: SizeConfig.blockWidth * 50,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4,
                    vertical: SizeConfig.blockHeight * 2,
                  ),
                  decoration: BoxDecoration(
                    color: COLORS.primaryTwo.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swipe_left,
                          color: COLORS.white,
                          size: SizeConfig.blockWidth * 5),
                      SizedBox(width: SizeConfig.blockWidth * 2.5),
                      Text(
                        'Swipe to delete',
                        style: TextStyle(
                          color: COLORS.white,
                          fontSize: SizeConfig.blockWidth * 3.8,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dismissBg({bool isEnd = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.all(Radius.circular(SizeConfig.blockWidth * 3)),
        color: COLORS.semantic,
      ),
      alignment: isEnd ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 4),
      child: Row(
        mainAxisAlignment:
        isEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isEnd) ...[
            Icon(Icons.delete,
                color: Colors.white, size: SizeConfig.blockWidth * 5),
            SizedBox(width: SizeConfig.blockWidth * 2),
          ],
          Text(
            'Swipe to delete',
            style: TextStyle(
              color: COLORS.white,
              fontSize: SizeConfig.blockWidth * 3.25,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
            ),
          ),
          if (isEnd) ...[
            SizedBox(width: SizeConfig.blockWidth * 2),
            Icon(Icons.delete,
                color: Colors.white, size: SizeConfig.blockWidth * 5),
          ],
        ],
      ),
    );
  }
}

class GroupedNotificationItem {
  final String? header;
  final NotificationModel? notification;
  final bool isHeader;

  const GroupedNotificationItem.header(this.header)
      : notification = null,
        isHeader = true;

  const GroupedNotificationItem.item(this.notification)
      : header = null,
        isHeader = false;
}

class _CircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _CircleIconButton({
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
      child: Container(
        height: SizeConfig.blockHeight * 5,
        width: SizeConfig.blockWidth * 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
          color: COLORS.neutralDarkTwo,
        ),
        child: Icon(
          icon,
          size: SizeConfig.blockWidth * 6,
          color: COLORS.neutralDark,
        ),
      ),
    );
  }
}
