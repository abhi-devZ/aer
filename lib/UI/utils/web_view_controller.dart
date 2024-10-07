import 'dart:ui';

import 'package:aer/UI/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewer {
  late WebViewController _controller;
  final ValueNotifier<double> progressLevel = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String> title = ValueNotifier<String>('');
  final ValueNotifier<String> currentUrl = ValueNotifier<String>('');

  WebViewer(context) {
    _initializeWebViewController(context);
  }

  void _initializeWebViewController(context) {
    _controller = WebViewController.fromPlatformCreationParams(const PlatformWebViewControllerCreationParams())
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            progressLevel.value = progress.toDouble();
            logger.e('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            isLoading.value = true;
            logger.e('Page started loading: $url');
            currentUrl.value = url;
            // Inject viewport meta tag for better scaling
              _controller.runJavaScript('''
              var meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
              document.getElementsByTagName('head')[0].appendChild(meta);
            ''');
          },
          onPageFinished: (String url) async {
            isLoading.value = false;
            currentUrl.value = url;
            final pageTitle = await _controller.getTitle();
            if (pageTitle != null) {
              title.value = pageTitle;
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      );

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void loadUrl(String url) {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    _controller.loadRequest(Uri.parse(url));
  }

  WebViewController get webViewController => _controller;
}
