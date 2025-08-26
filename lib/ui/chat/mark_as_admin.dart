import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/ImagePickerComponent.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/friends/component.dart';
import 'package:works_app/ui/friends/friends_details.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../components/config.dart';
import '../../models/chat/chat_view_pro_modal.dart';


class MarkAsAdminList extends StatefulWidget {
  final List<Participant> members;
  const MarkAsAdminList({super.key, required this.members});

  @override
  State<MarkAsAdminList> createState() => _MarkAsAdminListState();
}

class _MarkAsAdminListState extends State<MarkAsAdminList> {
  late List<Participant> membersList;
  late ChartBloc chartBloc;

  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);

    // Remove the current user from the list
    membersList = widget.members.where((member) => member.userId != Config.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
        title: 'Friend Suggestion',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4.5,
                    vertical: SizeConfig.blockHeight * 0.2,
                  ),
                  child: ListView.builder(
                    itemCount: membersList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      Participant member = membersList[index];

                      return friendSearchDetailsCards(
                        context: context,
                        image: member.user!.profilePic!,
                        name: member.user!.name!,
                        onTapCard: () {},
                        added: member.isAdmin!,
                        disc: member.user!.professionType!,
                        onTapButtonCard: () {
                          chartBloc.add(MarkAsAdminEvent(
                              chatId: member.chatId!,
                              users: [member.userId!],
                              onSuccess: (message) {
                                setState(() {
                                  member.isAdmin = true;
                                });
                              },
                              onError: (message) {
                                showCustomSnackBar(
                                  context: context,
                                  message: message,
                                );
                              }));
                        },
                        bgFriend: true,
                        buttonText1: 'Marked as admin',
                        buttonWidth: 40,
                        width: 25,
                        buttonText2: 'Mark as admin',
                      );
                    },
                  ),
                ),
              )
            ],
          )),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 6.5,
            vertical: SizeConfig.blockHeight),
        child: customButton(
          text: 'LEAVE GROUP'.tr(),
          onPressed: () {
            bool hasAdmin = membersList.any((member) => member.isAdmin!);
            if (hasAdmin) {
              chartBloc.add(LeaveGroupChatEvent(chatId: widget.members[0].chatId!,
                  onSuccess: (message){
                    showCustomSnackBar(
                      context: context,
                      message: message,
                      backgroundColor: COLORS.neutralDarkTwo
                    );
                    Navigator.pushNamed(
                      context,
                      '/main_screen',
                      arguments: {'selectedIndex': 3},
                    );
                  }, onError: (message){
                    showCustomSnackBar(
                      context: context,
                      message: message,
                    );
                  }));
            } else {
              showCustomSnackBar(
                context: context,
                message: "At least one admin is required before leaving.",
              );
            }
          },
          backgroundColor: COLORS.primary,
          showIcon: false,
          width: SizeConfig.blockWidth * 42,
          height: SizeConfig.blockHeight * 8,
          textColor: COLORS.white,
        ),
      ),
    );
  }
}
