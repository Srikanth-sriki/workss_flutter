import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';

import '../../global_helper/reuse_widget.dart';
import '../../models/friends/friends_view_modal.dart';
import 'component.dart';
import 'friends_details.dart';

class FullScreenSearchModal extends StatefulWidget {
  List<FriendDataList> friendList = [];
  final VoidCallback refreshPageCallback;

   FullScreenSearchModal({
    Key? key,
    required this.friendList,
    required this.refreshPageCallback,
  }) : super(key: key);

  @override
  _FullScreenSearchModalState createState() => _FullScreenSearchModalState();
}

class _FullScreenSearchModalState extends State<FullScreenSearchModal> {
  late ShowInterestedBloc showInterestedBloc;
  late ReportPostBloc reportPostBloc;
  TextEditingController _searchController = TextEditingController();
  List<FriendDataList> filteredFriendList = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    filteredFriendList = widget.friendList;
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        filteredFriendList = widget.friendList.where((friend) {
          final name = friend.user?.name?.toLowerCase() ?? '';
          final profession = friend.user?.professionType?.toLowerCase() ?? '';
          return name.contains(keyword.toLowerCase()) || profession.contains(keyword.toLowerCase());
        }).toList();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
      toolbarHeight: 0,
        backgroundColor: COLORS.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 5,
              vertical: SizeConfig.blockHeight*2.5
            ),
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
                hintText: 'Ex: Search'.tr(),
                prefixIcon: const Icon(
                  Icons.search,
                  color: COLORS.neutralDarkOne,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                ),
              ),
              onChanged: (value) => _onSearchChanged(value),
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 2),
          Divider(
            color: COLORS.neutralDarkTwo,
            height: SizeConfig.blockHeight,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 5,
                  vertical: SizeConfig.blockHeight*0.8
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredFriendList.length,
                padding: EdgeInsets.symmetric( vertical: SizeConfig.blockHeight*0.8),
                itemBuilder: (context, index) {
                  return filteredFriendList[index].user != null ?

                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: SizeConfig.blockHeight*0.8),
                    child: friendSearchDetailsCards(
                        image: filteredFriendList[index].user!.profilePic,
                        name: filteredFriendList[index].user!.name,
                        onTapCard: () {
                          Navigator.pop(context); // Close the search modal
                          Future.delayed(Duration(milliseconds: 100), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) {
                                        final bloc = FriendsBloc();
                                        bloc.add(FetchFriendsSingleView(
                                            friendId: filteredFriendList[index].friendId!));
                                        return bloc;
                                      },
                                    ),
                                    BlocProvider(create: (context) => ShowInterestedBloc()),
                                    BlocProvider(create: (context) => ReportPostBloc()),
                                    BlocProvider(create: (context) => ShowInterestedBloc()),
                                    BlocProvider(create: (context) => ChartBloc()),
                                  ],
                                  child: FriendsDetailsScreen(
                                    refreshPageCallback: widget.refreshPageCallback,
                                    id: filteredFriendList[index].friendId!,
                                  ),
                                ),
                              ),
                            );
                          });
                        },

                        onTapButtonCard: () {},
                        added: filteredFriendList[index].user!.friendRequestSent != null
                            ? true
                            : false,
                        disc: filteredFriendList[index].user!.professionType,
                        buttonRequired: false,
                        widgetButtonRequired: true,
                        widgetButton:  customIconButton(
                            text:  filteredFriendList[index].user!.isFriend != null
                                ? 'UNFRIEND'.tr():
                            filteredFriendList[index].user!.friendRequestSent != null?'REQUEST SENT'.tr()
                                : 'ADD FRIEND'.tr(),
                            onPressed: (){
                              if(filteredFriendList[index].user!.isFriend != null ){
                                showInterestedBloc.add(UnfriendsEvent(
                                    friendId: filteredFriendList[index].user!.id,
                                    onSuccess: (message) {
                                      setState(() {
                                        filteredFriendList[index].user!.isFriend = null;
                                        filteredFriendList[index].user!.friendRequestSent = null;
                                        widget.refreshPageCallback();
                                        widget.refreshPageCallback();
                                      });
                                      showCustomSnackBar(
                                          context: context,
                                          message:
                                          "Successfully unfriended!",
                                          backgroundColor:
                                          COLORS.semanticTwo);
                                    },
                                    onError: (message) {
                                      showCustomSnackBar(
                                        context: context,
                                        message: message,
                                      );
                                    }));
                              }
                              else if(filteredFriendList[index].user!.friendRequestSent != null) {
                                showInterestedBloc.add(UnSendFriendEvent(
                                    userId: filteredFriendList[index].user!.id,
                                    onSuccess: (message) {
                                      setState(() {
                                        filteredFriendList[index].user!.isFriend = null;
                                        filteredFriendList[index].user!.friendRequestSent = null;
                                        widget.refreshPageCallback();
                                        // _refreshPageAfterEdit();
                                      });
                                      showCustomSnackBar(
                                          context: context,
                                          message:message,
                                          backgroundColor:
                                          COLORS.semanticTwo);
                                    },
                                    onError: (message) {
                                      showCustomSnackBar(
                                        context: context,
                                        message: message,
                                      );
                                    }));
                              }

                              else{
                                showInterestedBloc.add(AddFriendEvent(
                                    userId: filteredFriendList[index].user!.id,
                                    onSuccess: (message) {
                                      setState(() {
                                        filteredFriendList[index].user!.friendRequestSent = FriendRequestSent(
                                          id:  filteredFriendList[index].user!.id,
                                        );
                                      });

                                      widget.refreshPageCallback();
                                    },
                                    onError: (message) {
                                      showCustomSnackBar(
                                        context: context,
                                        message: message,
                                      );

                                    }));
                              }
                            },
                            width: SizeConfig.blockWidth * 32,
                            height: SizeConfig.blockHeight * 6,
                            textFontSize: 3.2,
                            verticalSpaceButton: 1.5,
                            backgroundColor: (filteredFriendList[index].user!.isFriend != null || filteredFriendList[index].user!.friendRequestSent != null)
                                ? COLORS.neutralDarkTwo : COLORS.primary,
                            textColor:  (filteredFriendList[index].user!.isFriend != null || filteredFriendList[index].user!.friendRequestSent != null)
                                ? COLORS.neutralDark : COLORS.white,
                            showIcon: false)
                    ),
                  ):const SizedBox(); ;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
