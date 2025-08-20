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

  // ids currently being removed (avoid reinsert + avoid assert)
  final Set<String> _pendingRemovalIds = {};

  // hint banner
  bool _showHint = false;
  bool _showHintDone = false;
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


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Config.notificationReceiveMessage.value = false;
    });
  }


  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  bool _isToday(DateTime dateTime) {
    final local = dateTime.toLocal();      // <-- convert
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }


  // Build a flat list while preserving DESC by createdAt
  void _rebuildDisplayList(List<NotificationModel> notifs) {
    final sorted = [...notifs]..sort((a, b) {
      final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });

    final List<GroupedNotificationItem> flat = [];
    String? lastHeader;
    for (final n in sorted) {
      final header = formatChatDate(n.createdAt!);
      if (header != lastHeader) {
        flat.add(GroupedNotificationItem.header(header));
        lastHeader = header;
      }
      flat.add(GroupedNotificationItem.item(n));
    }

    _displayList = flat;
    _notificationLength = notifs.length;
  }

  /// Remove a notification (and its header if it becomes empty) from the flat list
  void _removeNotificationById(String id) {
    final idx =
    _displayList.indexWhere((e) => !e.isHeader && e.notification!.id == id);
    if (idx == -1) return;

    // Header just above the item, if any
    String? headerToCheck;
    if (idx > 0 && _displayList[idx - 1].isHeader) {
      headerToCheck = _displayList[idx - 1].header;
    }

    setState(() {
      final updated = List<GroupedNotificationItem>.from(_displayList);
      updated.removeAt(idx);

      // If header has no more items below it, remove the header too
      if (headerToCheck != null) {
        final stillHasItemsUnderHeader = updated.any((e) =>
        !e.isHeader &&
            formatChatDate(e.notification!.createdAt!) == headerToCheck);
        if (!stillHasItemsUnderHeader) {
          final headerIndex =
          updated.indexWhere((e) => e.isHeader && e.header == headerToCheck);
          if (headerIndex != -1) {
            updated.removeAt(headerIndex);
          }
        }
      }

      _displayList = updated;
      _notificationLength =
          updated.where((e) => !e.isHeader).length; // keep AppBar "Clear" logic right
    });
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
                // Filter out ids currently being removed so they don't pop back in
                final serverList = state.notifications;
                final filtered = serverList
                    .where((m) => !_pendingRemovalIds.contains(m.id))
                    .toList();

                _rebuildDisplayList(filtered);

                // If server truly no longer has an id, drop it from pending
                _pendingRemovalIds.removeWhere(
                      (id) => !serverList.any((m) => m.id == id),
                );

                if (_notificationLength > 0) {
                  _hintTimer?.cancel();
                  if(!_showHintDone) {
                    setState(() {
                      _showHint = true;
                      _showHintDone = true;
                    });
                    _hintTimer = Timer(const Duration(seconds: 3), () {
                      if (!mounted) return;
                      setState(() => _showHint = false);
                    });
                  }
                } else {
                  setState(() => _showHint = false);
                }
              } else if (state is NotificationClearSuccess) {
                // Optionally clear pending if your state represents a single-item success
                // _pendingRemovalIds.clear(); // or remove a specific id if available on state
                showCustomSnackBar(
                  context: context,
                  message: state.message,
                  backgroundColor: COLORS.semanticTwo,
                );
              } else if (state is NotificationClearAllSuccess) {
                _pendingRemovalIds.clear();
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
              // Only show loader when there is nothing cached to render
              if (state is FetchNotificationListLoading && _displayList.isEmpty) {
                return globalLoadingWidget();
              }

              if ((state is NotificationFetchSuccess ||
                  state is NotificationFetchFailure) &&
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
                  final bool isActionableType =
                  (n.type == 'friend_request' || n.type == 'group_invite');
                  final bool showActions =
                      isActionableType && (n.isRead == false);
                  final bool hasPic =
                      isActionableType && (n.content?.profilePic?.isNotEmpty ?? false);

                  // choose the main text like original behavior
                  final String mainText = isActionableType
                      ? (n.content?.body ?? n.description ?? '')
                      : (n.description ?? n.content?.body ?? '');

                  return Dismissible(
                    key: ValueKey(n.id),
                    direction: DismissDirection.horizontal,

                    // Only decide whether to allow dismissal (no state change here)
                    confirmDismiss: (direction) async => true,

                    // REMOVE the item now, then notify bloc *after the frame*
                    onDismissed: (direction) {
                      _pendingRemovalIds.add(n.id!);
                      _removeNotificationById(n.id!);

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        context
                            .read<NotificationBloc>()
                            .add(FetchNotificationSingleClear(n.id!));
                      });
                    },

                    // // prevents background flashing back in
                    // resizeDuration: Duration.zero,

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
                                      width: SizeConfig.blockWidth * 12,
                                      height: SizeConfig.blockWidth * 12,
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

                              // text area
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mainText,
                                      maxLines: _isToday(n.createdAt!) ? 1 : 4,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: TextStyle(
                                        color: COLORS.neutralDark,
                                        fontSize: SizeConfig.blockWidth * 3,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                    if (_isToday(n.createdAt!))
                                      Text(
                  DateFormat('h:mm a').format(n.createdAt!.toLocal()),
                                        style: TextStyle(
                                          color: COLORS.neutralDarkOne,
                                          fontSize: SizeConfig.blockWidth * 3,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // actions for friend/group
                              if (showActions) ...[
                                SizedBox(width: SizeConfig.blockWidth * 2),

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
                                          onError: (msg) => showCustomSnackBar(
                                            context: context,
                                            message: msg,
                                          ),
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
                                          onError: (msg) => showCustomSnackBar(
                                            context: context,
                                            message: msg,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icons.clear,
                                ),

                                SizedBox(width: SizeConfig.blockWidth * 2),

                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: SizeConfig.blockWidth * 26,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: customIconButton(
                                      text: n.type == 'friend_request'
                                          ? 'Accept'
                                          : (n.type == 'group_invite' ? 'Join' : ''),
                                      onPressed: () {
                                        if (n.type == 'friend_request') {
                                          showInterestedBloc.add(
                                            AcceptRequestFriendsEvent(
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
                                              onError: (msg) => showCustomSnackBar(
                                                context: context,
                                                message: msg,
                                              ),
                                            ),
                                          );
                                        } else if (n.type == 'group_invite') {
                                          chartBloc.add(
                                            AcceptChatEvent(
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
                                              onError: (msg) => showCustomSnackBar(
                                                context: context,
                                                message: msg,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      width: SizeConfig.blockWidth * 23,
                                      height: SizeConfig.blockHeight * 6.5,
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
              top: SizeConfig.blockHeight * 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: SizeConfig.blockHeight * 6.5,
                  width: SizeConfig.blockWidth * 40,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4,
                    vertical: SizeConfig.blockHeight * 2,
                  ),
                  decoration: BoxDecoration(
                    color: COLORS.primaryTwo.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(SizeConfig.blockWidth*3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swipe_left,
                          color: COLORS.white, size: SizeConfig.blockWidth * 4),
                      SizedBox(width: SizeConfig.blockWidth * 2.5),
                      Text(
                        'Swipe to delete',
                        style: TextStyle(
                          color: COLORS.white,
                          fontSize: SizeConfig.blockWidth * 3.2,
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
                color: Colors.white, size: SizeConfig.blockWidth * 4),
            SizedBox(width: SizeConfig.blockWidth * 2),
          ],
          Text(
            'Swipe to delete',
            style: TextStyle(
              color: COLORS.white,
              fontSize: SizeConfig.blockWidth * 3,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
            ),
          ),
          if (isEnd) ...[
            SizedBox(width: SizeConfig.blockWidth * 2),
            Icon(Icons.delete,
                color: Colors.white, size: SizeConfig.blockWidth * 4),
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
