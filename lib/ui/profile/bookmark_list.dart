import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/size_config.dart';

import '../../components/colors.dart';
import '../../global_helper/reuse_widget.dart';

class BookMarkListScreen extends StatefulWidget {
  const BookMarkListScreen({super.key});

  @override
  State<BookMarkListScreen> createState() => _BookMarkListScreenState();
}

class _BookMarkListScreenState extends State<BookMarkListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Saved Professionals',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SafeArea(child: Container(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight*4,horizontal: SizeConfig.blockWidth*6),
      )),
    );
  }
}
