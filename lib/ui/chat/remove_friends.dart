import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/chat/chat_view_pro_modal.dart';
import '../friends/component.dart';

class RemoveFriendsChat extends StatefulWidget {
  final ChatViewGroupInfo chatViewGroupInfo;
  RemoveFriendsChat({super.key, required this.chatViewGroupInfo});

  @override
  State<RemoveFriendsChat> createState() => _RemoveFriendsChatState();
}

class _RemoveFriendsChatState extends State<RemoveFriendsChat> {
  final TextEditingController _searchController = TextEditingController();
  late ChartBloc chartBloc;
  ChatViewGroupInfo chatViewGroupInfo = ChatViewGroupInfo();
  Timer? _debounce;
  String searchKeyword = "";
  bool showSearchBar = false;
  bool selectAll = false;
  bool isMemberLoading = true;
  bool isError = false;
  List<Map<String, dynamic>> selectedItems = [];
  List<Participant> filteredParticipants = [];

  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);
    _fetchData();
  }

  void _fetchData() {
    chartBloc
        .add(FetchChartViewProfileEvent(chatId: widget.chatViewGroupInfo.id!));
  }

  void _updateSelectedItemsList() {
    selectedItems = chatViewGroupInfo.participants!
        .map((friend) => {"id": friend.user!.id!, "selected": false})
        .toList();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
      });
    });
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      for (var item in selectedItems) {
        item["selected"] = value;
      }
    });
  }

  void checkSelectedId() {
    List<String> selectedUserIds = selectedItems
        .where((user) => user["selected"] == true) // Filter only selected users
        .map((user) => user["id"] as String) // Extract only the IDs
        .toList();
    if (selectedUserIds.isEmpty) {
      setState(() {
        selectAll = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Remove Members',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChartBloc, ChartState>(listener: (context, state) {
            if (state is ChatViewProfileLoading) {
              setState(() {
                isMemberLoading = true;
                isError = false;
              });
            } else if (state is ChatViewProfileSuccess) {
              setState(() {
                isMemberLoading = false;
                isError = false;
                chatViewGroupInfo = state.chatViewGroupInfo;
                _updateSelectedItemsList();
                filteredParticipants = state.chatViewGroupInfo.participants!
                    .where((p) =>
                        p.isAdmin != true &&
                        p.user!.name!
                            .toLowerCase()
                            .contains(searchKeyword.toLowerCase()))
                    .toList();
              });
            } else if (state is ChatViewProfileFailed) {
              setState(() {
                isMemberLoading = false;
                isError = true;
                showCustomSnackBar(
                  context: context,
                  message: state.message,
                );
              });
            } else if (state is SendRemoveMemberSuccess) {
              showCustomSnackBar(
                  context: context,
                  message: state.message,
                  backgroundColor: COLORS.neutralDarkTwo);
            } else if (state is SendRemoveMemberFailed) {
              showCustomSnackBar(
                context: context,
                message: state.message,
              );
            }
          })
        ],
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isMemberLoading && filteredParticipants.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 3.5,
                      vertical: SizeConfig.blockHeight),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            side: BorderSide(
                                color: COLORS.neutralDarkOne,
                                width: SizeConfig.blockWidth * 0.5),
                            checkColor: COLORS.white,
                            activeColor: COLORS.primary,
                            value: selectAll,
                            onChanged: (value) =>
                                _toggleSelectAll(value ?? false),
                          ),
                          Text(
                            'Select All',
                            style: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 3.5,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          showSearchBar ? Icons.close : Icons.search,
                          color: COLORS.neutralDarkOne,
                          size: SizeConfig.blockHeight * 4,
                        ),
                        onPressed: () {
                          setState(() {
                            showSearchBar = !showSearchBar;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Search Bar
                if (showSearchBar)
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 5.5,
                    ),
                    child: Expanded(
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
                          hintText: 'Ex: Search'.tr(),
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
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockWidth * 3.25),
                            borderSide: BorderSide(
                                color: COLORS.neutralDarkTwo.withOpacity(0.6),
                                width: SizeConfig.blockWidth * 0.1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockWidth * 3.25),
                            borderSide: BorderSide(
                                color: COLORS.neutralDarkTwo.withOpacity(0.6),
                                width: SizeConfig.blockWidth * 0.1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockWidth * 3.25),
                            borderSide: BorderSide(
                                color: COLORS.neutralDarkTwo.withOpacity(0.6),
                                width: SizeConfig.blockWidth * 0.1),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
              ],
              if (isMemberLoading == true) ...[
                friendsListLoading()
              ] else if (!isMemberLoading &&
                  filteredParticipants.isNotEmpty) ...[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 4.5,
                    ),
                    child: ListView.builder(
                        itemCount: filteredParticipants.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          Participant participant = filteredParticipants[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (selectAll) ...[
                                    Checkbox(
                                      side: BorderSide(
                                          color: COLORS.neutralDarkOne,
                                          width: SizeConfig.blockWidth * 0.5),
                                      checkColor: COLORS.white,
                                      activeColor: COLORS.primary,
                                      value: selectedItems[index]["selected"],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          selectedItems[index]["selected"] =
                                              value ?? false;
                                          checkSelectedId();
                                        });
                                      },
                                    ),
                                  ] else ...[
                                    SizedBox(
                                      width: SizeConfig.blockWidth,
                                    )
                                  ],
                                  friendChatRemoveSearchDetailsCards(
                                      image: participant.user!.profilePic!,
                                      name: participant.user!.name!,
                                      disc: participant.user!.professionType!,
                                      onTapCard: () {
                                        setState(() {
                                          selectedItems[index]["selected"] =
                                              !selectedItems[index]["selected"];
                                          checkSelectedId();
                                        });
                                      },
                                      onTapButton: () {
                                        chartBloc.add(SendRemoveMemberEvent(
                                          chatId: participant.chatId!,
                                          removeMember: [participant.userId!],
                                        ));
                                      },
                                      width: selectAll
                                          ? SizeConfig.blockWidth * 76
                                          : SizeConfig.blockWidth * 85),
                                ],
                              ),
                              Divider(
                                color: COLORS.neutralDarkTwo,
                                height: SizeConfig.blockHeight,
                                thickness: SizeConfig.blockWidth * 0.15,
                              ),
                            ],
                          );
                        }),
                  ),
                ),
              ] else if (filteredParticipants.isEmpty) ...[
                SizedBox(
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.blockHeight * 80,
                    child: emptyComponent())
              ] else if (isMemberLoading == false && isError) ...[
                ErrorScreen(onRetry: () {
                  _fetchData();
                }),
              ]
            ],
          ),
        ),
      ),
      bottomNavigationBar: selectAll
          ? Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 6.5,
                  vertical: SizeConfig.blockHeight),
              child: customButton(
                text: 'REMOVE'.tr(),
                onPressed: () {
                  setState(() {
                    List<String> selectedUserIds = selectedItems
                        .where((user) =>
                            user["selected"] ==
                            true) // Filter only selected users
                        .map((user) =>
                            user["id"] as String) // Extract only the IDs
                        .toList();
                    chartBloc.add(SendRemoveMemberEvent(
                        chatId: widget.chatViewGroupInfo.id!,
                        removeMember: selectedUserIds,
                        onSuccess: (message) {
                          _fetchData();
                          selectAll = false;
                        }));
                  });
                },
                backgroundColor: COLORS.neutralDarkTwo,
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.semantic,
              ),
            )
          : null,
    );
  }
}
