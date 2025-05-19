import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/global_helper/reuse_widget.dart';

import '../../components/colors.dart';
import 'notification.dart';

class SmartCallControl extends StatefulWidget {
  const SmartCallControl({super.key});

  @override
  State<SmartCallControl> createState() => _SmartCallControlState();
}

class _SmartCallControlState extends State<SmartCallControl> {
  bool? workPostedInCity = true;
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
          title: 'Notifications',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        // buildSwitchTile(
        // title: 'Works Posted in Cities',
        // value: workPostedInCity!
        // onChanged: (value) {},)
        ],
      )),
    );
  }
  Widget buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchTile(
      title: title,
      value: value,
      onChanged: onChanged,
    );
  }
}


