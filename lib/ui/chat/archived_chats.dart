import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import 'chat_view.dart';
import 'component.dart';

class ArchivedChatsScreen extends StatefulWidget {
  const ArchivedChatsScreen({super.key});

  @override
  State<ArchivedChatsScreen> createState() => _ArchivedChatsScreenState();
}

class _ArchivedChatsScreenState extends State<ArchivedChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Archived Chats',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 5.5,
            vertical: SizeConfig.blockHeight*2),
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
                          builder: (context) =>
                              ChatViewScreen(),
                        ));
                  },
                  message: 'Lorem ipsum dolor sit',
                  count: '2',
                  date: '23 JUN 2024');
            }),
      )),
    );
  }
}
