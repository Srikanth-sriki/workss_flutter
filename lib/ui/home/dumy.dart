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
  int notificationLength = 0;
  bool showHint = false;

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
                    notificationBloc.add(const FetchNotificationClearAll());
                    Navigator.of(context).pop();
                  },
                  onNegativePressed: () {
                    Navigator.of(context).pop();
                  },
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
          ]
        ],
      ),
      body: Stack(
        children: [
          BlocConsumer<NotificationBloc, NotificationState>(
            listener: (context, state) {
              if (state is NotificationFetchSuccess) {
                setState(() {
                  notificationLength = state.notifications.length;
                  if (notificationLength != 0) {
                    setState(() {
                      showHint = true;
                    });
                    Future.delayed(const Duration(seconds: 3), () {
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
              if (state is FetchNotificationListLoading) {
                return globalLoadingWidget();
              } else if (state is NotificationFetchSuccess) {
                if (state.notifications.isEmpty) {
                  return SizedBox(
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.blockHeight * 80,
                    child: emptyComponent(),
                  );
                }

                // Grouping logic
                final Map<String, List<NotificationModel>> grouped = {};
                for (var notification in state.notifications) {
                  String key = formatChatDate(notification.createdAt!);
                  grouped.putIfAbsent(key, () => []).add(notification);
                }

                // Flattening into a list
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
                    horizontal: SizeConfig.blockWidth * 4.5,
                  ),
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
                    } else {
                      final notification = item.notification!;
                      return Dismissible(
                        key: Key(notification.id!),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          context.read<NotificationBloc>().add(
                            FetchNotificationSingleClear(notification.id!),
                          );
                        },
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.description ?? '',
                                style: TextStyle(
                                  color: COLORS.neutralDark,
                                  fontSize: SizeConfig.blockWidth * 3.15,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              } else if (state is NotificationFetchFailure) {
                return ErrorScreen(onRetry: () {
                  notificationBloc.add(const FetchNotificationList());
                });
              } else {
                return const Center(child: Text("No notifications to display"));
              }
            },
          ),
        ],
      ),
    );
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

