import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PersistentWebView extends StatefulWidget {
  const PersistentWebView({Key? key}) : super(key: key);

  @override
  _PersistentWebViewState createState() => _PersistentWebViewState();
}

class _PersistentWebViewState extends State<PersistentWebView> {
  WebViewController? _controller;
  List<String> history = [];
  String currentUrl = 'https://www.google.com'; // Default URL
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // Load last visited URL from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final lastUrl = prefs.getString('last_url') ?? currentUrl;
    history = prefs.getStringList('history') ?? [];

    // Get application directory for cache
    final directory = await getApplicationDocumentsDirectory();
    final cachePath = '${directory.path}/webview_cache';

    // Ensure cache directory exists
    await Directory(cachePath).create(recursive: true);

    // Initialize WebView with configurations
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          setState(() {
            isLoading = true;
          });
        },
        onPageFinished: (String url) async {
          _controller?.runJavaScript(
            "window.localStorage.setItem('token','Bearer token');",
          );
          setState(() {
            isLoading = false;
            currentUrl = url;
          });
          // Save current URL and update history
          await _updateHistory(url);
        },
      ))
      ..loadRequest(Uri.parse(lastUrl))
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true);

    // Enable local storage and DOM storage
    // await _controller?.clearLocalStorage();
    // await _controller?.setLocalStorage({});
  }

  Future<void> _updateHistory(String url) async {
    if (!history.contains(url)) {
      history.add(url);
      if (history.length > 100) {
        // Limit history size
        history.removeAt(0);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_url', url);
    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persistent WebView'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller?.canGoBack() ?? false) {
                _controller?.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _controller?.canGoForward() ?? false) {
                _controller?.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showHistoryDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(
              controller: _controller!,
            ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Browsing History'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final url = history[history.length - 1 - index];
                return ListTile(
                  title: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    _controller?.loadRequest(Uri.parse(url));
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}