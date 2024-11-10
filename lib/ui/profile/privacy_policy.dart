import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/size_config.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../components/colors.dart';
import '../../global_helper/reuse_widget.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  bool isLoading = true;
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(COLORS.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              isLoading = progress < 100;
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
            if (request.url.startsWith('https://workss.co/privacy-policy')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://workss.co/privacy-policy'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
        title: 'Privacy Policy',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // WebView widget only displayed once content is loaded
            if (!isLoading)
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockHeight,
                  horizontal: SizeConfig.blockWidth * 4,
                ),
                child: WebViewWidget(controller: controller),
              ),

            // Loading indicator
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
