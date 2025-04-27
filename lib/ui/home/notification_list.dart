import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/chart/chart_bloc.dart';
import 'package:works_app/models/friends/friendsRequestList.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/popup.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/friends/friends_search_list_modal.dart';
import '../../models/notification_list_model.dart';
import '../friends/component.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late NotificationBloc notificationBloc;
  late FriendsBloc friendsBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ChartBloc chartBloc;
  late List<RequestFriendsList> friends;
  int notificationLength = 0;
  bool showHint = false;
  double getWidth(NotificationModel notification) {
    bool hasProfilePic = notification.content?.profilePic?.isNotEmpty ?? false;
    bool isRead = notification.isRead ?? false;

    return hasProfilePic
        ? (isRead ? SizeConfig.blockWidth * 65 : SizeConfig.blockWidth * 33)
        : (isRead ? SizeConfig.blockWidth * 53 : SizeConfig.blockWidth * 45);
  }

  bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: COLORS.white,
        appBar: CustomAppBar(
          title: 'Notifications',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark,
          actions: [
            if (notificationLength >= 1) ...[
              TextButton(
                  onPressed: () {
                    showCustomAlertDialog(
                      context: context,
                      title: 'Do you want to Clear?',
                      message: 'Do you want to Clear all Notifications?',
                      positiveButtonText: 'CLEAR',
                      negativeButtonText: 'CANCEL',
                      onPositivePressed: () {
                        notificationBloc
                            .add(const FetchNotificationClearAll());
                        Navigator.of(context).pop();
                      },
                      onNegativePressed: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                  child: Padding(
                    padding:
                    EdgeInsets.only(right: SizeConfig.blockWidth * 2),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: COLORS.accent,
                        fontSize: SizeConfig.blockWidth * 3.8,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ))
            ]
          ],
        ),
        body: Stack(children: [
          BlocConsumer<NotificationBloc, NotificationState>(
            listener: (context, state) {
              if (state is NotificationFetchSuccess) {
                setState(() {
                  notificationLength = state.notifications.length;
                  if (notificationLength != 0) {
                    setState(() {
                      showHint = true;
                    });
                    Future.delayed(Duration(seconds: 3), () {
                      setState(() {
                        showHint = false;
                      });
                    });
                  }
                });
              }
              if (state is NotificationClearSuccess) {
                showCustomSnackBar(
                    context: context,
                    message: state.message,
                    backgroundColor: COLORS.semanticTwo);
              } else if (state is NotificationClearAllSuccess) {
                showCustomSnackBar(
                    context: context,
                    message: state.message,
                    backgroundColor: COLORS.semanticTwo);
              } else if (state is NotificationFetchFailure) {
                showCustomSnackBar(
                  context: context,
                  message: state.message,
                );
              }
            },
            builder: (context, state) {
              if (state is FetchNotificationListLoading) {
                return globalLoadingWidget();
              } else if (state is NotificationFetchSuccess) {
                if (state.notifications.isEmpty) {
                  return SizedBox(
                      width: SizeConfig.screenWidth,
                      height: SizeConfig.blockHeight * 80,
                      child: emptyComponent());
                }
                final Map<String, List<NotificationModel>> grouped = {};
                for (var notification in state.notifications) {
                  String key = formatChatDate(notification.createdAt!);
                  grouped.putIfAbsent(key, () => []).add(notification);
                }



                final List<GroupedNotificationItem> displayList = [];
                grouped.forEach((key, value) {
                  displayList.add(GroupedNotificationItem.header(key));
                  for (var notif in value) {
                    displayList.add(GroupedNotificationItem.item(notif));
                  }
                });
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockHeight * 2,
                      horizontal: SizeConfig.blockWidth * 4.5),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final item = displayList[index];
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
                    }else{
                      final notification = item.notification!;
                      return Dismissible(
                          key: Key(notification.id!),
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) {
                            context.read<NotificationBloc>().add(
                                FetchNotificationSingleClear(
                                    notification.id!));
                          },
                          background: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockHeight),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        SizeConfig.blockWidth * 3)),
                                color: COLORS.semantic),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockWidth * 4),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Swipe to delete',
                                  style: TextStyle(
                                    color: COLORS.white,
                                    fontSize: SizeConfig.blockWidth * 3.25,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Poppins",
                                  ),
                                  softWrap: true,
                                ),
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: SizeConfig.blockWidth * 5,
                                ),
                              ],
                            ),
                          ),
                          child: Container(
                            width: SizeConfig.blockWidth * 100,
                            margin: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockHeight),
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockHeight * 2,
                                horizontal: SizeConfig.blockWidth * 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        SizeConfig.blockWidth * 3)),
                                color: COLORS.primaryOne.withOpacity(0.3)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (notification.type == 'friend_request' ||
                                    notification.type == 'group_invite') ...[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          if (notification!.content!
                                              .profilePic!.isNotEmpty)
                                            Container(
                                              width: SizeConfig.blockWidth * 12,
                                              height: SizeConfig.blockWidth * 12,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(notification.content!.profilePic!),
                                                    fit: BoxFit.fill,
                                                  ),
                                                  borderRadius: BorderRadius.all(Radius.circular(SizeConfig.blockWidth * 3))),
                                            ),
                                          SizedBox(width: SizeConfig.blockWidth * 2,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: getWidth(notification),
                                                child: Text(
                                                  notification.content!.body!,
                                                  style: TextStyle(
                                                    color: COLORS.neutralDark,
                                                    fontSize: SizeConfig.blockWidth * 3,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Poppins",
                                                  ),
                                                  softWrap: true,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: isToday(notification.createdAt!) ? 1 : 4,
                                                ),
                                              ),
                                              if (isToday(notification.createdAt!))
                                              Text(
                                                DateFormat('h:mm a').format(notification.createdAt!),
                                                style: TextStyle(
                                                  color: COLORS.neutralDarkOne,
                                                  fontSize: SizeConfig.blockWidth * 3,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: "Poppins",
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      if(notification.isRead! == false)...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                if(notification.type == 'friend_request'){
                                                  showInterestedBloc.add(RejectRequestFriendsEvent(
                                                      id: notification.content!.requestId!,
                                                      onSuccess: (message) {
                                                        showCustomSnackBar(
                                                            context: context,
                                                            message: message,
                                                            backgroundColor: COLORS.neutralDarkTwo);
                                                        notificationBloc..add(FetchNotificationViewEvent(id: notification.id!));
                                                      },
                                                      onError: (message) {
                                                        showCustomSnackBar(
                                                          context: context,
                                                          message: message,
                                                        );
                                                      })
                                                  );
                                                }
                                                if(notification.type == 'group_invite'){
                                                  chartBloc.add(RejectGroupChatEvent(chatId: notification.content!.inviteId!,
                                                      onSuccess: (message) {
                                                        showCustomSnackBar(
                                                            context: context,
                                                            message: message,
                                                            backgroundColor: COLORS.neutralDarkTwo);
                                                        notificationBloc..add(FetchNotificationViewEvent(id: notification.id!));
                                                      },
                                                      onError: (message) {
                                                        showCustomSnackBar(
                                                          context: context,
                                                          message: message,
                                                        );
                                                      }
                                                  ));
                                                }
                                              },
                                              child: Container(
                                                height: SizeConfig.blockHeight * 5,
                                                width: SizeConfig.blockWidth * 10,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(SizeConfig
                                                        .blockWidth *
                                                        2),
                                                    color:
                                                    COLORS.neutralDarkTwo),
                                                child: Icon(
                                                  Icons.clear,
                                                  size:
                                                  SizeConfig.blockWidth * 6,
                                                  color: COLORS.neutralDark,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width:
                                              SizeConfig.blockWidth * 2,
                                            ),
                                            customIconButton(
                                                text: notification.type == 'friend_request'?'Accept':notification.type == 'group_invite'?'Join':'',
                                                onPressed: () {
                                                  if(notification.type == 'friend_request'){
                                                    showInterestedBloc.add(AcceptRequestFriendsEvent(
                                                        id: notification.content!.requestId!,
                                                        onSuccess: (message) {
                                                          showCustomSnackBar(
                                                              context: context,
                                                              message: message,
                                                              backgroundColor: COLORS.neutralDarkTwo);
                                                          notificationBloc.add(FetchNotificationViewEvent(id: notification.id!));
                                                        },
                                                        onError: (message) {
                                                          showCustomSnackBar(
                                                            context: context,
                                                            message: message,
                                                          );
                                                        }
                                                    )
                                                    );
                                                  }
                                                  if(notification.type == 'group_invite'){
                                                    chartBloc.add(AcceptChatEvent(chatId: notification.content!.inviteId!,
                                                        onSuccess: (message) {
                                                          showCustomSnackBar(
                                                              context: context,
                                                              message: message,
                                                              backgroundColor: COLORS.neutralDarkTwo);
                                                          notificationBloc.add(FetchNotificationViewEvent(id: notification.id!));
                                                        },
                                                        onError: (message) {
                                                          showCustomSnackBar(
                                                            context: context,
                                                            message: message,
                                                          );
                                                        }
                                                    ));
                                                  }
                                                },
                                                width: SizeConfig.blockWidth * 23,
                                                height: SizeConfig.blockHeight * 6.5,
                                                backgroundColor: COLORS.primary,
                                                textColor: COLORS.white,

                                                showIcon: false)
                                          ],
                                        )
                                      ]
                                    ],
                                  )
                                ] else ...[
                                  Text(
                                    notification.description!,
                                    style: TextStyle(
                                      color: COLORS.neutralDark,
                                      fontSize: SizeConfig.blockWidth * 3.15,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                    ),
                                    softWrap: true,
                                  ),
                                ]
                              ],
                            ),
                          ));
                    }
                  },
                );
              } else if (state is NotificationFetchFailure) {
                return ErrorScreen(onRetry: () {
                  notificationBloc.add(const FetchNotificationList());
                });
              } else {
                return const Center(
                    child: Text("No notifications to display"));
              }
            },
          ),
          if (showHint) ...[
            Positioned(
              top: SizeConfig.blockHeight * 10,
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  height: SizeConfig.blockHeight * 8,
                  width: SizeConfig.blockWidth * 50,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 4,
                      vertical: SizeConfig.blockHeight * 2),
                  decoration: BoxDecoration(
                    color: COLORS.primaryTwo.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Icon(
                          Icons.swipe_left,
                          color: COLORS.white,
                          size: SizeConfig.blockWidth * 5,
                        ),
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
            ),
          ]
        ]),);
  }
}

class GroupedNotificationItem {
  final String? header;
  final NotificationModel? notification;
  final bool isHeader;

  GroupedNotificationItem.header(this.header)
      : notification = null,
        isHeader = true;

  GroupedNotificationItem.item(this.notification)
      : header = null,
        isHeader = false;
}

