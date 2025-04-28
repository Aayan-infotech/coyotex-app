import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPreviewController extends ChangeNotifier {
  late WebViewController webViewController;

  String url = "";
  bool isLoading = true;

  WebViewPreviewController(this.url) {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Handle progress
          },
          onPageStarted: (String url) {
            isLoading = true; // Set loading state
            notifyListeners(); // Notify listeners to update UI
          },
          onPageFinished: (String url) {
            isLoading = false; // Set loading state to false
            notifyListeners(); // Notify listeners to update UI
          },
          onHttpError: (HttpResponseError error) {
            // Handle HTTP error
          },
          onWebResourceError: (WebResourceError error) {
            // Handle resource error
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://hunt30.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  // You can call this method to initialize the controller if needed
  void initController() {
    webViewController.loadRequest(Uri.parse(url));
  }
}
