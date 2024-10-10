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

  Future<void> injectViewportMeta() async {
    // JavaScript to adjust viewport and scale content
    const String javascript = '''
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=400, initial-scale=0.5, maximum-scale=1.0, user-scalable=no';
      document.getElementsByTagName('head')[0].appendChild(meta);
      
      // Additional styling to ensure content fits
      document.body.style.width = '400px';
      document.body.style.margin = '0';
      document.body.style.padding = '0';
      document.documentElement.style.overflow = 'auto';
      
      // Force layout recalculation
      document.body.style.display = 'none';
      document.body.offsetHeight;
      document.body.style.display = 'block';
    ''';

    await _controller?.runJavaScript(javascript);
  }


  Widget buildWebView() {
    return _controller != null
        ?  WebViewWidget(controller: _controller!)
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
