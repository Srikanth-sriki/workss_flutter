import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/ImagePickerComponent.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/friends/component.dart';
import 'package:works_app/ui/friends/friends_details.dart';

import '../../models/chat/chat_view_pro_modal.dart';

class MarkAsAdminList extends StatefulWidget {
  final List<Participant> members;
  const MarkAsAdminList({super.key,required this.members});

  @override
  State<MarkAsAdminList> createState() => _MarkAsAdminListState();
}

class _MarkAsAdminListState extends State<MarkAsAdminList> {

  late List<Participant> membersList;

  @override
  void initState() {
    super.initState();
    membersList = widget.members;
  }

  void toggleAdminStatus(int index) {
    setState(() {
      membersList[index] = Participant(
        id: membersList[index].id,
        chatId: membersList[index].chatId,
        userId: membersList[index].userId,
        isAdmin: !membersList[index].isAdmin, // Toggle isAdmin
        user: membersList[index].user,
      );
    });
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
                itemCount: widget.members.where((member) => !member.isAdmin).length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  List<Participant> nonAdminMembers =
                  widget.members.where((member) => !member.isAdmin).toList();
                  Participant member = nonAdminMembers[index];

                  return friendSearchDetailsCards(
                    image: 'assets/images/home/dumy1.png',
                    name: member.user.name,
                    onTapCard: () {},
                    added: index % 2 == 0 ? true : false,
                    disc: member.user.professionType,
                    onTapButtonCard: () {

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
            setState(() {});
            Navigator.pop(context);
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
