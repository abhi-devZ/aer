import 'dart:ui';

import 'package:aer/UI/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewer {
  late WebViewController _controller;
  DateTime? lastNavigationTime;
  final ValueNotifier<double> progressLevel = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> searchUrl = ValueNotifier<String?>(null);
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
            searchUrl.value = url;
            logger.e('Page started loading: $url');
          },
          onPageFinished: (String url) {
            isLoading.value = false;
            searchUrl.value = url;
            logger.e('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigation requested to: ${request.url}');

            // Check if this is a rapid subsequent navigation (within 500ms)
            final now = DateTime.now();
            if (lastNavigationTime != null) {
              final timeDifference = now.difference(lastNavigationTime!);
              if (timeDifference.inMilliseconds < 500) {
                debugPrint('Blocked rapid subsequent navigation');
                return NavigationDecision.prevent;
              }
            }
            lastNavigationTime = now;

            // Parse URLs for comparison
            final Uri requestUri = Uri.parse(request.url);
            final Uri currentUri = Uri.parse(searchUrl.value??"");
            const String allowedDomain = "asuracomic.net";

            // Allow navigation only if:
            // 1. It's to the allowed domain
            // 2. It's a relative URL (same domain)
            // 3. It's a subdomain of the allowed domain
            if (requestUri.host == allowedDomain ||
                requestUri.host.endsWith('.$allowedDomain') ||
                request.url.startsWith('/')) {
              debugPrint('Allowing navigation to: ${request.url}');
              return NavigationDecision.navigate;
            }

            debugPrint('Blocked navigation to: ${request.url}');
            return NavigationDecision.prevent;
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