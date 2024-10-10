import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebViewController {
  WebViewController? _controller;
  final String initialUrl;
  final Function(String) onPageStarted;
  final Function(String) onPageFinished;

  CustomWebViewController._({
    required this.initialUrl,
    required this.onPageStarted,
    required this.onPageFinished,
  });

  static Future<CustomWebViewController> initialize({
    required String initialUrl,
    required Function(String) onPageStarted,
    required Function(String) onPageFinished,
  }) async {
    final controller = CustomWebViewController._(
      initialUrl: initialUrl,
      onPageStarted: onPageStarted,
      onPageFinished: onPageFinished,
    );
    await controller._initWebView();
    return controller;
  }

  Future<void> _initWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: onPageStarted,
        onPageFinished: onPageFinished,
      ))
      ..loadRequest(Uri.parse(initialUrl))
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true);

    await _controller?.runJavaScript(
      "window.localStorage.setItem('token','Bearer token');",
    );
  }

  Widget buildWebView() {
    return _controller != null
        ? WebViewWidget(controller: _controller!)
        : const SizedBox();
  }

  Future<void> goBack() async {
    if (await _controller?.canGoBack() ?? false) {
      _controller?.goBack();
    }
  }

  Future<void> goForward() async {
    if (await _controller?.canGoForward() ?? false) {
      _controller?.goForward();
    }
  }

  void reload() => _controller?.reload();

  void loadUrl(String url) => _controller?.loadRequest(Uri.parse(url));
}
