import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: 'Notifications',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
        actions: [
          TextButton(
              onPressed: () {
                context
                    .read<NotificationBloc>()
                    .add(const FetchNotificationClearAll());
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
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
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
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationFetchSuccess) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text("No notifications available"));
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
                            'Delete',
                            style: TextStyle(
                              color: COLORS.white,
                              fontSize: SizeConfig.blockWidth * 3.25,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                            softWrap: true,
                          ),
                           Icon(Icons.delete, color: Colors.white,size: SizeConfig.blockWidth*5,),
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
                    )
                    );
              },
            );
          } else if (state is NotificationFetchFailure) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text("No notifications to display"));
          }
        },
      ),
    );
  }
}
