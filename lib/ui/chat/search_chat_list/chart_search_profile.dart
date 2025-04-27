import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/chat/addFriends.dart';
import 'package:works_app/ui/chat/component.dart';
import 'package:works_app/ui/chat/groupmemeber_list.dart';
import 'package:works_app/ui/chat/modal/editGroupDescripation.dart';
import 'package:works_app/ui/chat/modal/editGroupName.dart';
import 'package:works_app/ui/chat/remove_friends.dart';

import '../../../bloc/chart/chart_bloc.dart';
import '../../../bloc/show_interested/show_interested_bloc.dart';
import '../../../components/colors.dart';
import '../../../models/chat/chart_search_list.dart';
import '../../../models/chat/chat_view_pro_modal.dart';



class ChatProfileViewScreen extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  final String id;
  final ChartSearchList chart;
  const ChatProfileViewScreen(
      {super.key,
        required this.refreshPageCallback, required this.id,required this.chart});

  @override
  State<ChatProfileViewScreen> createState() => _ChatProfileViewScreenState();
}

class _ChatProfileViewScreenState extends State<ChatProfileViewScreen> {
  late ChartBloc chartBloc;
  late ShowInterestedBloc showInterestedBloc;
  String profilePic = '';
  List<Participant> membersList =[];
  late ChatViewGroupInfo chatViewGroupInfo;
  bool loading = true;
  bool error = false;
  late ChartSearchList chart;

  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
    setState(() {
      chart = widget.chart;
    });
  }

  void _refreshPageAfterEdit() {
    widget.refreshPageCallback();
  }

  void _fetchData(){
    chartBloc.add(FetchChartViewProfileEvent(chatId: widget.id!));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChartBloc, ChartState>(listener: (context, state) {
          if (state is ChatViewProfileLoading) {
            setState(() {
              loading = true;
            });
          } else if (state is ChatViewProfileSuccess) {
            setState(() {
              chatViewGroupInfo = state.chatViewGroupInfo;
              profilePic = state.chatViewGroupInfo.picture!;
              membersList = [...chatViewGroupInfo.participants!]
                ..sort((a, b) => (b.isAdmin! ? 1 : 0).compareTo(a.isAdmin! ? 1 : 0));
              loading = false;
              error = false;
            });
          } else if (state is ChatViewProfileFailed) {
            setState(() {
              loading = false;
              error = true;
            });
          }
        })
      ],
      child: Scaffold(
        backgroundColor: const Color(0xffF5FAFF),
        appBar: CustomAppBar(
          title: '',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark,
          showLeadingIcon: true,
          borderColor: true,
          actions: [
            InkWell(
              child: Image.asset(
                'assets/images/home/share.png',
                height: SizeConfig.blockWidth * 5,
                width: SizeConfig.blockWidth * 5,
              ),
            ),
            SizedBox(width: SizeConfig.blockWidth*4,)
          ],
        ),
        body: SafeArea(
            child: SingleChildScrollView(
              child: loading?SizedBox(
                  width: SizeConfig.blockWidth*100,
                  height: SizeConfig.blockHeight*70,
                  child: globalLoadingWidget()):error? ErrorScreen(onRetry: () {
                _fetchData();
              }):SizedBox(
                width: SizeConfig.blockWidth * 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: COLORS.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(SizeConfig.blockWidth * 0.5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildProfilePicture(),
                                  SizedBox(height: SizeConfig.blockHeight*2,),
                                  SizedBox(
                                    width:SizeConfig.blockWidth*50,
                                    child: Text(
                                      chatViewGroupInfo.name!,
                                      style: TextStyle(
                                        color: COLORS.neutralDark,
                                        fontSize: SizeConfig.blockWidth * 4,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Poppins",
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${chatViewGroupInfo.participants!.length} Members'
                                        .tr(),
                                    style: TextStyle(
                                      color: COLORS.neutralDarkOne,
                                      fontSize: SizeConfig.blockWidth * 3.5,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                  SizedBox(height: SizeConfig.blockHeight*2,),
                                  customButton(
                                    text: chart.isInvited != null ? 'Invited' : chart.isRequested != null?'Request Sent':'Join Group',
                                    onPressed: () {
                                      if (chart.isInvited != null) {
                                        showInterestedBloc.add(AcceptSendChatEvent(
                                          chatId: chart.isInvited!.id!,
                                          onSuccess: (message) {
                                            setState(() {
                                              chart.isInvited = null;
                                              chart.participantsDetails = IsInvited(chatId: chart.id);
                                            });
                                            showCustomSnackBar(
                                              context: context,
                                              message: message,
                                              backgroundColor: COLORS.neutralDarkTwo,
                                            );
                                            _refreshPageAfterEdit();
                                          },
                                          onError: (message) {
                                            showCustomSnackBar(context: context, message: message);
                                          },
                                        ));
                                      } else if (chart.isRequested != null) {
                                        showInterestedBloc.add(CancelJoinRequestChatEvent(
                                          chatId: chart.isRequested!.chatId!,
                                          onSuccess: (message) {
                                            setState(() {
                                              chart.isRequested = null;
                                            });
                                            showCustomSnackBar(
                                              context: context,
                                              message: message,
                                              backgroundColor: COLORS.neutralDarkTwo,
                                            );
                                            _refreshPageAfterEdit();
                                          },
                                          onError: (message) {
                                            showCustomSnackBar(context: context, message: message);
                                          },
                                        ));
                                      } else {
                                        showInterestedBloc.add(SendJoinGroupChatEvent(
                                          chatId: chart.id!,
                                          onSuccess: (message) {
                                            setState(() {
                                              chart.isRequested = IsInvited(chatId: chart.id);
                                            });
                                            showCustomSnackBar(
                                              context: context,
                                              message: message,
                                              backgroundColor: COLORS.neutralDarkTwo,
                                            );
                                            _refreshPageAfterEdit();
                                          },
                                          onError: (message) {
                                            showCustomSnackBar(context: context, message: message);
                                          },
                                        ));
                                      }
                                    },
                                    backgroundColor: (chart.isInvited != null || chart.isRequested != null)?COLORS.neutralDarkTwo:COLORS.primary,
                                    showIcon: false,

                                    textColor: (chart.isInvited != null || chart.isRequested != null)?COLORS.neutralDark:COLORS.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockHeight * 2,
                          ),
                          const Divider(
                            color: COLORS.neutralDarkTwo,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockHeight,
                                horizontal: SizeConfig.blockWidth * 4.5),
                            child:      Text(
                              'Description'.tr(),
                              style: TextStyle(
                                color: COLORS.neutralDark,
                                fontSize: SizeConfig.blockWidth * 4,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockWidth * 4.5),
                            child: Text(
                              chatViewGroupInfo.description!,
                              style: TextStyle(
                                color: COLORS.neutralDarkOne,
                                fontSize: SizeConfig.blockWidth * 3.5,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                              ),
                              softWrap: true,
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockHeight * 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: COLORS.neutralDarkTwo,
                                  width: SizeConfig.blockWidth * 0.2))),
                      padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockHeight * 2,
                          horizontal: SizeConfig.blockWidth * 4.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Members'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDark,
                              fontSize: SizeConfig.blockWidth * 4,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                          ),
                          Container(
                            margin:
                            EdgeInsets.only(left: SizeConfig.blockWidth),
                            alignment: Alignment.center,
                            width: SizeConfig.blockWidth * 7,
                            height: SizeConfig.blockHeight * 3.5,
                            decoration: BoxDecoration(
                              color: COLORS.accent,
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 1.5),
                            ),
                            child: Text(
                              chatViewGroupInfo.participants!.length!
                                  .toString(),
                              style: TextStyle(
                                color: COLORS.white,
                                fontSize: SizeConfig.blockWidth * 2.8,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockHeight * 0.5,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 4.5,
                      ),
                      child: ListView.builder(
                          itemCount: membersList!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            Participant participants = membersList![index];
                            return chartMemberCardViewSearchCards(
                              image: participants.user!.profilePic!,
                              name: participants.user!.name!,
                              admin: participants.isAdmin!,
                              onTapCard: () {
                              },
                              message: participants.user!.professionType!,
                            );
                          }),
                    )
                  ],
                ),
              ),
            )

        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return  profilePic.isNotEmpty?Container(
      height: SizeConfig.blockWidth * 30,
      width: SizeConfig.blockWidth * 30,
      decoration: BoxDecoration(
        border: Border.all(
          color: COLORS.primary,
          width: SizeConfig.blockWidth * 0.25,
        ),
        image: DecorationImage(
          image: NetworkImage(profilePic),
          fit: BoxFit.fill,
        ),
        borderRadius:
        BorderRadius.circular(SizeConfig.blockWidth * 3.5),
      ),
    ): Container(
      height: SizeConfig.blockWidth * 30,
      width: SizeConfig.blockWidth * 30,
      decoration: BoxDecoration(
        border: Border.all(
          color: COLORS.primary,
          width: SizeConfig.blockWidth * 0.25,
        ),
        borderRadius:
        BorderRadius.circular(SizeConfig.blockWidth * 3.5),
      ),
      child: Icon(
        Icons.people,
        color: COLORS.neutralDarkOne,
        size: SizeConfig.blockWidth * 15,
      ),
    );
  }
}
