import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/chat/charts_list_modal.dart';
import 'chat_view.dart';
import 'component.dart';

class ArchivedChatsScreen extends StatefulWidget {
  const ArchivedChatsScreen({super.key});

  @override
  State<ArchivedChatsScreen> createState() => _ArchivedChatsScreenState();
}

class _ArchivedChatsScreenState extends State<ArchivedChatsScreen> {
  late ChartBloc chartBloc;
  List<ChatList> chatList = [];
  bool isChatListLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);
  }

  void _refreshPageAfterEdit() {
    chartBloc.add(ArchivedChartListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Archived Chats',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: BlocListener<ChartBloc, ChartState>(
        listener: (context, state) {
          if (state is ArchivedChartListLoading) {
            setState(() {
              isChatListLoading = true;
              isError = false;
            });
          } else if (state is ArchivedChartListSuccess) {
            setState(() {
              isChatListLoading = false;
              isError = false;
              chatList = state.chatList;
            });
          } else if (state is ArchivedChartListFailed) {
            setState(() {
              isChatListLoading = false;
              isError = true;
            });
          }
        },
        child: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              if (isChatListLoading) ...[
                friendsListLoading()
              ] else if (!isChatListLoading && chatList.isNotEmpty) ...[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 5.5,
                        vertical: SizeConfig.blockHeight * 2),
                    child: ListView.builder(
                        itemCount: chatList.length,
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return chartSearchCards(
                            image: chatList[index].picture!,
                            name: chatList[index].name!,
                            onTapCard: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                create: (context) => ChartBloc()
                                                  ..add(FetchChartViewEvent(
                                                      page: 1,
                                                      pageSize: 10,
                                                      chatId: chatList[index]
                                                          .chatId!)),
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
                                              chatId: chatList[index].chatId!,
                                              isGroup: chatList[index].isGroup!,
                                              isRequest: false,
                                            ),
                                          )));
                            },
                            message: chatList[index].latestMessage != null
                                ? chatList[index].latestMessage!.content!
                                : "",
                            count: chatList[index].unreadCount!,
                            isGroup: chatList[index].isGroup!,
                            date: formatChatDate(chatList[index].updatedAt!),
                            context: context,
                            heroTag: 'avatar_${chatList[index].chatId}_$index',
                            deletedForAll:
                                chatList[index].latestMessage?.deletedforall,
                          );
                        }),
                  ),
                ),
              ] else if (!isChatListLoading && chatList.isEmpty) ...[
                Expanded(child: emptyComponent(errorText: "No Chats Found"))
              ] else if (isError && !isChatListLoading) ...[
                ErrorScreen(onRetry: () {
                  _refreshPageAfterEdit();
                })
              ]
            ])),
      ),
    );
  }
}
