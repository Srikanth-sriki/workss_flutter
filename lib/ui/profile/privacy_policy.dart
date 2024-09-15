import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:works_app/components/size_config.dart';

import '../../components/colors.dart';
import '../../global_helper/reuse_widget.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://workss.co/privacy-policy'));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Privacy Policy',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SafeArea(child: Container(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight*4,horizontal: SizeConfig.blockWidth*4),
        child:  WebViewWidget(controller: controller),
      )),
    );
  }
}
