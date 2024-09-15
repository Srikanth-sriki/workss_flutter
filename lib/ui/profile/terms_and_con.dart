import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/size_config.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../components/colors.dart';
import '../../global_helper/reuse_widget.dart';

class TermsAndCondition extends StatefulWidget {
  const TermsAndCondition({super.key});

  @override
  State<TermsAndCondition> createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://workss.co/terms&conditions'));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Terms & Conditions',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(
            vertical: SizeConfig.blockHeight * 4,
            horizontal: SizeConfig.blockWidth * 4),
        child: WebViewWidget(controller: controller),
      )),
    );
  }
}
