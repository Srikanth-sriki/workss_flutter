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
                ))
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
                if(notificationLength != 0){
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
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockHeight * 2,
                    horizontal: SizeConfig.blockWidth * 4.5),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        context
                            .read<NotificationBloc>()
                            .add(FetchNotificationSingleClear(notification.id));
                      },
                      background: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: SizeConfig.blockHeight),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(SizeConfig.blockWidth * 3)),
                            color: COLORS.semantic),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockWidth * 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Radius.circular(SizeConfig.blockWidth * 3)),
                            color: COLORS.primaryOne.withOpacity(0.3)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: TextStyle(
                                color: COLORS.neutralDark,
                                fontSize: SizeConfig.blockWidth * 3.6,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                              ),
                              softWrap: true,
                            ),
                            Text(
                              notification.description,
                              style: TextStyle(
                                color: COLORS.neutralDarkOne,
                                fontSize: SizeConfig.blockWidth * 3.25,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ));
                },
              );
            } else if (state is NotificationFetchFailure) {
              return ErrorScreen(onRetry: () {
                notificationBloc.add(const FetchNotificationList());
              });
            } else {
              return const Center(child: Text("No notifications to display"));
            }
          },),
          if(showHint)...[
          Positioned(
            top: SizeConfig.blockHeight*10,
            left: 0,right: 0,bottom: 0,
            child: Center(
              child: Container(
                height: SizeConfig.blockHeight*8,
                width: SizeConfig.blockWidth*50,

                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4,
                    vertical: SizeConfig.blockHeight * 2),
                decoration: BoxDecoration(
                  color: COLORS.primaryTwo.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                       Icon(
                        Icons.swipe_left,
                        color: COLORS.white,
                         size: SizeConfig.blockWidth*5,
                      ),
                      SizedBox(width: SizeConfig.blockWidth*2.5),
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
      ]
        )




    );
  }
}
