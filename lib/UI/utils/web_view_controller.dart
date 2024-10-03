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
          },
          onPageFinished: (String url) {
            isLoading.value = false;
            logger.e('Page finished loading: $url');
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

  WebViewController get webViewController => _controller;
}

class HistoryStack {
  static const String HISTORY_KEY = 'browsing_history';

  final List<String> _history = [];

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(HISTORY_KEY);
    if (history != null) {
      _history.addAll(history);
    }
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(HISTORY_KEY, _history);
  }
}