import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/friends/friends_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/chat/archived_chats.dart';
import 'package:works_app/ui/chat/chat_view.dart';
import 'package:works_app/ui/chat/component.dart';
import 'package:works_app/ui/chat/create_chat_group.dart';
import 'package:works_app/ui/friends/friends_search.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../components/size_config.dart';
import '../friends/friends_details.dart';
import '../home/component.dart';
import '../profile/notification.dart';
import 'addFriends.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String searchKeyword = "";

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: 'Chat',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert,
                color: COLORS.black, size: SizeConfig.blockWidth * 6.5),
            onPressed: () {
              showDynamicBottomSheet(
                context,
                'Chat Options',
                [
                  BottomSheetItem(
                    title: 'Create new group',
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateGroupScreen(),
                          ))
                    },
                  ),
                  BottomSheetItem(
                    title: 'Archived Chats',
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArchivedChatsScreen(),
                          ))
                    },
                  ),
                  BottomSheetItem(
                    title: 'Turn-Off Notification',
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (context) => ProfileBloc()
                                          ..add(const FetchSettingEvent()),
                                      ),
                                    ],
                                    child: const NotificationScreen(),
                                  )))
                    },
                  ),
                  BottomSheetItem(
                    title: 'Add Friends',
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddFriendsScreen(header: 'Add Friend'),
                          ))
                    },
                  ),
                ],
              );
            },
          )
        ],
        showLeadingIcon: false,
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Column(
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
                    hintText: 'Search your friends'.tr(),
                    hintStyle: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.25,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: COLORS.neutralDarkOne,
                      size: SizeConfig.blockWidth * 5,
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
              Expanded(
                  child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConfig.blockHeight),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 4.5,
                      ),
                      child: addFriendText(
                          textOne: 'Friends',
                          textTwo: 'View All',
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiBlocProvider(
                                          providers: [
                                            BlocProvider(
                                              create: (context) => FriendsBloc()
                                                ..add(FetchFriendsListEvent(
                                                    page: 1,
                                                    pageSize: 10,
                                                    keyWord: '')),
                                            ),
                                          ],
                                          child: FriendsSearchListScreen(),
                                        )));
                          }),
                    ),
                    SizedBox(
                      height: SizeConfig.blockHeight * 18,
                      child: ListView.builder(
                          itemCount: 8,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockWidth * 2.5),
                          itemBuilder: (context, index) {
                            return friendViewCard(
                                image: 'assets/images/home/dumy1.png',
                                name: 'Julia Vandervort-Will');
                          }),
                    ),
                    const Divider(
                      color: COLORS.neutralDarkTwo,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 4.5,
                        vertical: SizeConfig.blockHeight * 0.2,
                      ),
                      child: ListView.builder(
                          itemCount: 5,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return chartSearchCards(
                                image: 'assets/images/home/dumy1.png',
                                name: 'Julia Vandervort-Will',
                                onTapCard: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatViewScreen(),
                                      ));
                                },
                                message: 'Lorem ipsum dolor sit',
                                count: '2',
                                date: '23 JUN 2024');
                          }),
                    )
                  ],
                ),
              )),
            ],
          ),
          Positioned(
            bottom: SizeConfig.blockHeight * 2.5,
            right: SizeConfig.blockHeight * 4,
            child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddFriendsScreen(header: 'Add Friend'),
                      ));
                },
                backgroundColor: COLORS.primary,
                child: Image.asset(
                  'assets/images/chat/add_friend.png',
                  width: SizeConfig.blockWidth * 6.5,
                  height: SizeConfig.blockWidth * 6.5,
                  fit: BoxFit.contain,
                )),
          )
        ],
      )),
    );
  }
}
