import 'package:coyotex/core/utills/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../web_page_controller.dart';

class WebScreen extends StatelessWidget {
  final String url;

  const WebScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final webViewController = WebViewPreviewController(url);

    return ChangeNotifierProvider(
      create: (_) => webViewController,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('', style: TextStyle(color: Colors.white)),
        ),
        body: Consumer<WebViewPreviewController>(
          builder: (context, controller, child) {
            return Stack(
              children: [
                WebViewWidget(controller: controller.webViewController),
                if (controller.isLoading)
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: MediaQuery.of(context).size.width * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.white, blurRadius: 0.15)
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Pallete.primaryColor),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
