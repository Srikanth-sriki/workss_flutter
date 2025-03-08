import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/popup.dart';
import '../../global_helper/reuse_widget.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late NotificationBloc notificationBloc;
  int notificationLength = 0;
  bool showHint = false;

  @override
  void initState() {
    super.initState();
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        backgroundColor: COLORS.white,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyle(color: COLORS.neutralDark),
          ),
          backgroundColor: COLORS.white,
          bottom: TabBar(
            labelColor: COLORS.primaryOne,
            unselectedLabelColor: COLORS.neutralDark,
            indicatorColor: COLORS.primaryOne,
            tabs: [
              Tab(text: "All Notifications"),
              Tab(text: "Read Notifications"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            /// **Tab 1 - All Notifications**
            BlocConsumer<NotificationBloc, NotificationState>(
              listener: (context, state) {
                if (state is NotificationFetchSuccess) {
                  setState(() {
                    notificationLength = state.notifications.length;
                    if (notificationLength != 0) {
                      showHint = true;
                      Future.delayed(const Duration(seconds: 3), () {
                        setState(() {
                          showHint = false;
                        });
                      });
                    }
                  });
                }
                if (state is NotificationClearAllSuccess) {
                  showCustomSnackBar(
                      context: context,
                      message: state.message,
                      backgroundColor: COLORS.semanticTwo);
                }
              },
              builder: (context, state) {
                if (state is FetchNotificationListLoading) {
                  return globalLoadingWidget();
                } else if (state is NotificationFetchSuccess) {
                  if (state.notifications.isEmpty) {
                    return emptyComponent();
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockHeight * 2,
                        horizontal: SizeConfig.blockWidth * 4.5),
                    itemCount: state.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = state.notifications[index];
                      return notificationItem(notification);
                    },
                  );
                } else {
                  return ErrorScreen(onRetry: () {
                    notificationBloc.add(const FetchNotificationList());
                  });
                }
              },
            ),

            /// **Tab 2 - Read Notifications**
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationFetchSuccess) {
                  final readNotifications = state.notifications
                      .where((notification) => notification.isRead)
                      .toList();
                  if (readNotifications.isEmpty) {
                    return emptyComponent();
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockHeight * 2,
                        horizontal: SizeConfig.blockWidth * 4.5),
                    itemCount: readNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = readNotifications[index];
                      return notificationItem(notification);
                    },
                  );
                } else {
                  return const Center(child: Text("No read notifications"));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// **Notification Item Widget**
  Widget notificationItem(notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        context
            .read<NotificationBloc>()
            .add(FetchNotificationSingleClear(notification.id));
      },
      background: Container(
        margin: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(SizeConfig.blockWidth * 3)),
          color: COLORS.semantic,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Swipe to delete',
              style: TextStyle(
                color: COLORS.white,
                fontSize: SizeConfig.blockWidth * 3.25,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.delete, color: Colors.white, size: SizeConfig.blockWidth * 5),
          ],
        ),
      ),
      child: Container(
        width: SizeConfig.blockWidth * 100,
        margin: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight),
        padding: EdgeInsets.symmetric(
            vertical: SizeConfig.blockHeight * 2,
            horizontal: SizeConfig.blockWidth * 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(SizeConfig.blockWidth * 3)),
          color: COLORS.primaryOne.withOpacity(0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 3.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              notification.description,
              style: TextStyle(
                color: COLORS.neutralDarkOne,
                fontSize: SizeConfig.blockWidth * 3.25,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
