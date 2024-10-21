import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
          title: 'Notifications',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark,
        actions: [
          TextButton( onPressed: () {
    context.read<NotificationBloc>().add(const FetchNotificationClearAll());
    }, child: Padding(
      padding: EdgeInsets.only(right: SizeConfig.blockWidth*2),
      child: Text('Clear',
              style: TextStyle(
                color: COLORS.accent,
                fontSize: SizeConfig.blockWidth * 3.8,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
    ))

        ],
      ),

      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationClearSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is NotificationClearAllSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is NotificationFetchFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
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
              padding: const EdgeInsets.all(8),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    context.read<NotificationBloc>().add(FetchNotificationSingleClear(notification.id));
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.notifications, color: Colors.white),
                      ),
                      title: Text(notification.title),
                      subtitle: Text(notification.description),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
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
