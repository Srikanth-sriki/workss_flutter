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
import '../../models/chat/blocked_chat_list.dart';
import '../../models/chat/charts_list_modal.dart';
import 'chat_view.dart';
import 'component.dart';

class BlockedChatsScreen extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  const BlockedChatsScreen({super.key,required this.refreshPageCallback});

  @override
  State<BlockedChatsScreen> createState() => _BlockedChatsScreenState();
}

class _BlockedChatsScreenState extends State<BlockedChatsScreen> {
  late ChartBloc chartBloc;
  List<ChatList> chatBlockedList = [];
  bool isChatListLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);
  }

  void _refreshPageAfterEdit() {
    chartBloc.add(const BlockedChatList());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.refreshPageCallback();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: "Blocked Chats",
            backgroundColor: COLORS.white,
            titleColors: COLORS.neutralDark,
            onBackPress:(){
              widget.refreshPageCallback();
              Navigator.of(context).pop();
            }
        ),
        body: BlocListener<ChartBloc, ChartState>(
          listener: (context, state) {
            if (state is GroupUnBlocChatLoading) {
              setState(() {
                isChatListLoading = true;
                isError = false;
              });
            } else if (state is ChatBlockedListSuccess) {
              setState(() {

                isChatListLoading = false;
                isError = false;
                chatBlockedList = state.chatBlockedList;
              });
            } else if (state is ChatBlockedListFalied) {
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
                    ] else if (!isChatListLoading && chatBlockedList.isNotEmpty) ...[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockWidth * 5.5,
                              vertical: SizeConfig.blockHeight * 2),
                          child: ListView.builder(
                              itemCount: chatBlockedList.length,
                              shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return BlockedChartCards(
                                  image: chatBlockedList[index].picture!,
                                  name: chatBlockedList[index].name!,
                                  isGroup: chatBlockedList[index].isGroup!,
                                  onPressed: (){
                                    final chatId = chatBlockedList[index].chatId!;
                                    chartBloc.add(UnBlocChartGroupEvent(
                                      chatId: chatId,
                                      onSuccess: (message) {
                                        setState(() {
                                          chatBlockedList.removeWhere((chat) => chat.chatId == chatId);
                                        });
                                        showCustomSnackBar(
                                          context: context,
                                          message: message,
                                          backgroundColor: COLORS.neutralDarkOne,
                                        );
                                        widget.refreshPageCallback();
                                      },
                                      onError: (message) {
                                        showCustomSnackBar(
                                          context: context,
                                          message: message,
                                        );
                                      },
                                    ));

                                  }
                                );
                              }),
                        ),
                      )
                    ] else if (!isChatListLoading && chatBlockedList.isEmpty) ...[
                      Expanded(child: emptyComponent(errorText: "No Chats Found"))
                    ] else if (isError && !isChatListLoading) ...[
                      ErrorScreen(onRetry: () {
                        _refreshPageAfterEdit();
                      })
                    ]
                  ])),
        ),
      ),
    );
  }
}
