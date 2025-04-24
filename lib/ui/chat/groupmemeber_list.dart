import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/chat/chat_view_pro_modal.dart';
import '../professional/professional_view.dart';
import 'chat_view.dart';
import 'component.dart';
import 'modal/markas_admin_modal.dart';

class MemberListWidget extends StatefulWidget {
  final List<Participant> members;
  final String createdBy;
  final Function() refreshPageCallback;

  const MemberListWidget({
    super.key,
    required this.members,
    required this.createdBy,
    required this.refreshPageCallback,
  });

  @override
  State<MemberListWidget> createState() => _MemberListWidgetState();
}

class _MemberListWidgetState extends State<MemberListWidget> {
  late List<Participant> filteredList;
  String query = '';
  late ChartBloc chartBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);
    filteredList = List.from(widget.members)
      ..sort((a, b) => b.isAdmin ? 1 : 0 - (a.isAdmin ? 1 : 0));
  }


  void _onSearchChanged(String value) {
    setState(() {
      query = value.toLowerCase();
      filteredList = widget.members
          .where((p) => p.user.name.toLowerCase().contains(query))
          .toList()
        ..sort((a, b) => b.isAdmin ? 1 : 0 - (a.isAdmin ? 1 : 0)); // admins first
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
        title: 'Group Members',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 4.5,
              vertical: SizeConfig.blockHeight * 2,
            ),
            child: Row(
              children: [
                Expanded(
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
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: filteredList.isEmpty?COLORS.white:COLORS.neutralDarkTwo,
              padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockHeight * 2,
                horizontal: SizeConfig.blockWidth * 2.5,
              ),
              child: filteredList.isEmpty
                  ? emptyComponent()
                  : ListView.builder(
                      itemCount: filteredList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final participant = filteredList[index];

                        return GestureDetector(
                          onTap: () => _showMemberOptions(context, participant),
                          child: chartMemberCardViewSearchCards(
                            image: participant.user.profilePic,
                            name: participant.user.name,
                            admin: participant.isAdmin,
                            message: participant.user.professionType,
                            onTapCard: () {
                              _showMemberOptions(context, participant);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      )),
    );
  }

  void _showMemberOptions(BuildContext context, Participant participant) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("View Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) => ProfessionalBloc()
                            ..add(FetchProfessionalView(participant.userId)),
                        ),
                        BlocProvider(create: (_) => ShowInterestedBloc()),
                        BlocProvider(create: (_) => ReportPostBloc()),
                      ],
                      child: ProfessionalViewScreen(
                        id: participant.userId,
                        refreshPageCallback: widget.refreshPageCallback,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (!participant.isAdmin)
              ListTile(
                title: Text("Mark as admin"),
                onTap: () {
                  Navigator.pop(context);
                  _showMarkAdminModal(participant);
                },
              ),
            if (widget.createdBy != participant.userId)
              ListTile(
                title: const Text("Message"),
                onTap: () {
                  Navigator.pop(context);
                  chartBloc.add(StartMessageEvent(
                    chatId: participant.user.id,
                    onSuccess: (chatId) {
                      widget.refreshPageCallback();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (_) => ChartBloc()
                                  ..add(FetchChartViewEvent(
                                      page: 1, pageSize: 10, chatId: chatId)),
                              ),
                              BlocProvider(
                                  create: (_) => InitialRegisterBloc()),
                              BlocProvider(create: (_) => ShowInterestedBloc()),
                            ],
                            child: ChatViewScreen(
                              refreshPageCallback: widget.refreshPageCallback,
                              chatId: chatId,
                              isGroup: false,
                            ),
                          ),
                        ),
                      );
                    },
                    onError: (message) {
                      showCustomSnackBar(context: context, message: message);
                    },
                  ));
                },
              ),
            if (!participant.isAdmin)
              ListTile(
                title: Text("Remove (${participant.user.name})"),
                onTap: () {
                  Navigator.pop(context);
                  chartBloc.add(SendRemoveMemberEvent(
                    chatId: participant.chatId,
                    removeMember: [participant.userId],
                    onSuccess: (message) {
                      showCustomSnackBar(context: context, message: message);
                      widget.refreshPageCallback();
                    },
                    onError: (message) {
                      showCustomSnackBar(context: context, message: message);
                    },
                  ));
                },
              ),
          ],
        );
      },
    );
  }

  void _showMarkAdminModal(Participant participant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MarkasAdminModal(
        members: widget.members,
        header:
            'Are you sure you want to mark ${participant.user.name} as admin?',
        leaveGroup: false,
        subHeader: '',
        onTapCalled: () {
          chartBloc.add(MarkAsAdminEvent(
            chatId: participant.chatId,
            users: [participant.userId],
            onSuccess: (message) {
              Navigator.pop(context);
              widget.refreshPageCallback();
              showCustomSnackBar(context: context, message: message);
            },
            onError: (message) {
              Navigator.pop(context);
              showCustomSnackBar(context: context, message: message);
            },
          ));
        },
      ),
    );
  }
}
