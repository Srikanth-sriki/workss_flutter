import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../models/chat/charts_list_modal.dart';
import 'chat_view.dart';
import 'component.dart';

class ChatListSearch extends StatefulWidget {
  final List<ChatList> chatList;
  const ChatListSearch({super.key, required this.chatList});

  @override
  State<ChatListSearch> createState() => _ChatListSearchState();
}

class _ChatListSearchState extends State<ChatListSearch> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatList> chatList = [];

  @override
  void initState() {
    super.initState();
    chatList = widget.chatList;
  }

  void _onSearchChanged(String keyword) {
    setState(() {
      chatList = widget.chatList
          .where((chat) => chat.name!.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  void _refreshPageAfterEdit() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: COLORS.white,
      ),
      backgroundColor: COLORS.white,
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.blockWidth * 4.5,
                    top: SizeConfig.blockHeight * 2,
                    right: SizeConfig.blockWidth * 4.5,
                    bottom: SizeConfig.blockHeight),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.25,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  cursorColor: COLORS.black,
                  decoration: InputDecoration(
                    fillColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                    focusColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                    filled: true,
                    hintText: 'Search your chat'.tr(),
                    hintStyle: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.25,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                    prefixIcon:  Padding(padding: EdgeInsets.all(SizeConfig.blockWidth*4),
                      child: Image.asset(
                        'assets/images/home/search.png',
                        width: SizeConfig.blockWidth * 3.5,
                        height: SizeConfig.blockWidth * 3.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                      borderSide: BorderSide(
                          color: COLORS.neutralDarkTwo.withOpacity(0.6),
                          width: SizeConfig.blockWidth * 0.1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                      borderSide: BorderSide(
                          color: COLORS.neutralDarkTwo.withOpacity(0.6),
                          width: SizeConfig.blockWidth * 0.1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                      borderSide: BorderSide(
                          color: COLORS.neutralDarkTwo.withOpacity(0.6),
                          width: SizeConfig.blockWidth * 0.1),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const Divider(
                color: COLORS.neutralDarkTwo,
              ),
              if (chatList.isNotEmpty) ...[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 4.5,
                      vertical: SizeConfig.blockHeight * 0.2,
                    ),
                    child: ListView.builder(
                        itemCount: chatList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return chartSearchCards(
                              image: chatList[index].picture!,
                              name: chatList[index].name!,
                              onTapCard: () {
                                FocusScope.of(context).unfocus();
                                Future.delayed(const Duration(milliseconds: 300), () {
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
                                                chatId: chatList[index].chatId!,
                                              )),
                                          ),
                                          BlocProvider(create: (context) => InitialRegisterBloc()),
                                          BlocProvider(create: (context) => ShowInterestedBloc()),
                                        ],
                                        child: ChatViewScreen(
                                          refreshPageCallback: _refreshPageAfterEdit,
                                          chatId: chatList[index].chatId!,
                                          isGroup: chatList[index].isGroup!,
                                          isRequest: false,
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              },

                              message: chatList[index].latestMessage != null
                                  ? chatList[index].latestMessage!.content!
                                  : "",
                              count: chatList[index].unreadCount!,
                              isGroup: chatList[index].isGroup!,
                              date: formatChatDate(chatList[index].updatedAt!),
                              context: context,
                            heroTag: 'avatar_${chatList[index].chatId}_$index',
                            deletedForAll: chatList[index].latestMessage?.deletedforall,
                          );
                        }),
                  ),
                )
              ]
              else if (chatList.isEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 2.5,
                    vertical: SizeConfig.blockHeight * 4,),
                  child: emptyComponent(errorText: "No Chats Found"),
                )
              ]
            ],
          )),
    );
  }
}
