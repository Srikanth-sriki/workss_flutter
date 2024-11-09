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
  bool isLoading = true;
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              isLoading = true;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onHttpError: (HttpResponseError error) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://workss.co/terms&conditions')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://workss.co/terms&conditions'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
        title: 'Terms & Conditions',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // WebView widget
            Container(
              padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockHeight,
                horizontal: SizeConfig.blockWidth * 4,
              ),
              child: WebViewWidget(controller: controller),
            ),


            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: COLORS.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
