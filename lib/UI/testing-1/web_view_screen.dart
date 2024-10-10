import 'package:flutter/material.dart';
import 'web_view_controller.dart';
import 'snapshot_controller.dart';
import 'history_controller.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final CustomWebViewController _webViewController;
  late final CustomSnapshotController _snapshotController;
  late final HistoryController _historyController;
  bool isLoading = true;
  bool isInitCompleted = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    _historyController = await HistoryController.initialize();
    _snapshotController = CustomSnapshotController();
    _webViewController = await CustomWebViewController.initialize(
      initialUrl: _historyController.lastUrl,
      onPageStarted: _handlePageStarted,
      onPageFinished: _handlePageFinished,
    );
    setState(() {
      isInitCompleted = true;
    });
  }

  void _handlePageStarted(String url) {
    setState(() => isLoading = true);
  }

  void _handlePageFinished(String url) async {
    await _historyController.addToHistory(url);
    _webViewController.injectViewportMeta();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persistent WebView'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _snapshotController.captureSnapshot(context),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _webViewController.goBack;
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              _webViewController.goForward();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _historyController.showHistoryDialog(
                context,
                _webViewController.loadUrl,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          ),
        ],
      ),
      body: isInitCompleted
          ? Stack(
              children: [
                RepaintBoundary(
                  key: _snapshotController.webViewKey,
                  child: _webViewController.buildWebView(),
                ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
                _snapshotController.buildSnapshotWindow(context),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  @override
  void dispose() {
    _snapshotController.dispose();
    super.dispose();
  }
}
