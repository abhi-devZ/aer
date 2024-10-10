// browser_dashboard.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserDashboard extends StatefulWidget {
  const BrowserDashboard({super.key});

  @override
  State<BrowserDashboard> createState() => _BrowserDashboardState();
}

class _BrowserDashboardState extends State<BrowserDashboard> with AutomaticKeepAliveClientMixin {
  late final TabManager _tabManager;

  @override
  void initState() {
    super.initState();
    _tabManager = TabManager(
      onTabsChanged: () => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        body: _tabManager.showTabsGrid ? _buildTabsGridView() : _buildCurrentTab(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildCurrentTab() {
    return IndexedStack(
      index: _tabManager.currentIndex,
      children: _tabManager.tabs.map((tabData) => tabData.tab).toList(),
    );
  }

  Widget _buildTabsGridView() {
    return Container(
      color: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _tabManager.tabs.length,
        itemBuilder: (context, index) => _buildTabCard(index),
      ),
    );
  }

  Widget _buildTabCard(int index) {
    final tabData = _tabManager.tabs[index];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () => _tabManager.selectTab(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: SizedBox(
                height: double.infinity,
                child: tabData.thumbnail != null
                    ? Image.memory(
                        base64Decode(tabData.thumbnail!),
                        fit: BoxFit.fill,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.web, size: 48),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => _tabManager.closeTab(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _tabManager.addTab,
            icon: const Icon(Icons.add),
            tooltip: 'New Tab',
          ),
          Text('${_tabManager.currentIndex + 1}/${_tabManager.tabs.length}'),
          IconButton(
            onPressed: _tabManager.toggleTabsView,
            icon: const Icon(Icons.grid_view),
            tooltip: 'Show all tabs',
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// browser_tab.dart

class BrowserTab extends StatefulWidget {
  final Function(String? thumbnail, String? url)? onStateChanged;
  final String? initialUrl;

  const BrowserTab({
    super.key,
    this.onStateChanged,
    this.initialUrl,
  });

  @override
  State<BrowserTab> createState() => _BrowserTabState();
}

class _BrowserTabState extends State<BrowserTab> with AutomaticKeepAliveClientMixin {
  late final CustomWebViewController _webViewController;
  final GlobalKey _webViewKey = GlobalKey();
  bool isLoading = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    _webViewController = await CustomWebViewController.initialize(
      onPageStarted: _handlePageStarted,
      onPageFinished: _handlePageFinished,
      initialUrl: _currentUrl,
    );
    setState(() {});
  }

  void _handlePageStarted(String url) {
    setState(() {
      isLoading = true;
      _currentUrl = url;
    });
    widget.onStateChanged?.call(null, url);
  }

  void _handlePageFinished(String url) async {
    setState(() {
      isLoading = false;
    });
    _captureTabThumbnail();
  }

  Future<void> _captureTabThumbnail() async {
    try {
      RenderRepaintBoundary boundary =
      _webViewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final base64Thumbnail = base64Encode(byteData.buffer.asUint8List());
        widget.onStateChanged?.call(base64Thumbnail, _currentUrl);
      }
    } catch (e) {
      debugPrint('Error capturing thumbnail: $e');
    }
  }

  void _handleSearch(String query) {
    _webViewController.loadUrl(query);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      key: _webViewKey,
      child: Stack(
        children: [
          if (_currentUrl == null)
            _buildHomePage()
          else
            _buildWebView(),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(Icons.stream),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchWidget(onSearch: _handleSearch),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        _webViewController.buildWebView(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SearchWidget(
            onSearch: _handleSearch,
            initialValue: _currentUrl,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
// search_widget.dart

class SearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  final String? initialValue;

  const SearchWidget({
    super.key,
    required this.onSearch,
    this.initialValue,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  void _handleSubmitted(String value) {
    if (value.isEmpty) return;
    final url = UrlUtils.toSearchQuery(value);
    widget.onSearch(url.toString());
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search or type URL',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              _focusNode.requestFocus();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onSubmitted: _handleSubmitted,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// tab_manager.dart

class TabData {
  final Key key = UniqueKey();
  late final BrowserTab tab;
  String? thumbnail;
  String? currentUrl;

  TabData({String? initialUrl})
      : tab = BrowserTab(
    key: UniqueKey(),
    initialUrl: initialUrl,
    onStateChanged: (thumbnail, url) {
      // This will be set after instantiation
    },
  );
  void setOnStateChanged(Function(String? thumbnail, String? url) callback) {
    tab = BrowserTab(
      key: key,
      initialUrl: currentUrl,
      onStateChanged: (newThumbnail, newUrl) {
        thumbnail = newThumbnail ?? thumbnail;
        currentUrl = newUrl;
        callback(newThumbnail, newUrl);
      },
    );
  }
}

class TabManager {
  final List<TabData> _tabs = [];
  int _currentIndex = 0;
  bool _showTabsGrid = false;
  final VoidCallback onTabsChanged;

  TabManager({required this.onTabsChanged}) {
    addTab(); // Add initial tab
  }

  List<TabData> get tabs => _tabs;
  int get currentIndex => _currentIndex;
  bool get showTabsGrid => _showTabsGrid;

  void addTab() {
    final newTab = TabData();
    newTab.setOnStateChanged((thumbnail, url) {
      _updateTabState(_tabs.indexOf(newTab), thumbnail, url);
    });

    _tabs.add(newTab);
    _currentIndex = _tabs.length - 1;
    _showTabsGrid = false;
    onTabsChanged();
  }

  void closeTab(int index) {
    if (_tabs.length <= 1) return; // Keep at least one tab

    _tabs.removeAt(index);
    if (_currentIndex >= _tabs.length) {
      _currentIndex = _tabs.length - 1;
    }
    onTabsChanged();
  }

  void selectTab(int index) {
    _currentIndex = index;
    _showTabsGrid = false;
    onTabsChanged();
  }

  void toggleTabsView() {
    _showTabsGrid = !_showTabsGrid;
    onTabsChanged();
  }

  void _updateTabState(int index, String? thumbnail, String? url) {
    if (index >= 0 && index < _tabs.length) {
      _tabs[index].thumbnail = thumbnail ?? _tabs[index].thumbnail;
      _tabs[index].currentUrl = url;
      onTabsChanged();
    }
  }
}

// url_utils.dart
class UrlUtils {
  static const String searchEngineUrl = 'https://www.google.com/search';

  static Uri toSearchQuery(String url) {
    if (_isValidUrl(url)) {
      if (!url.startsWith("http://") && !url.startsWith("https://")) {
        url = "https://$url";
      }

      Uri uri = Uri.parse(url);
      String protocol = uri.scheme;
      String domain = uri.host;
      if (domain.split('.').length == 2 && !domain.startsWith('www')) {
        domain = 'www.$domain';
      }

      return Uri.parse('$protocol://$domain');
    } else {
      String encodedQuery = Uri.encodeQueryComponent(url);
      return Uri.parse('$searchEngineUrl?q=$encodedQuery');
    }
  }

  static bool _isValidUrl(String url) {
    RegExp regex = RegExp(r'^(https?://)?(www\.)?([a-zA-Z0-9-]+)(\.[a-zA-Z]{2,}){1,2}$');
    return regex.hasMatch(url);
  }
}

// web_view_controller.dart

class CustomWebViewController {
  WebViewController? _controller;
  String? currentUrl;

  CustomWebViewController._();

  static Future<CustomWebViewController> initialize({
    required Function(String) onPageStarted,
    required Function(String) onPageFinished,
    String? initialUrl,
  }) async {
    final controller = CustomWebViewController._();
    await controller._initWebView(onPageStarted, onPageFinished, initialUrl);
    return controller;
  }

  Future<void> _initWebView(
      Function(String) onPageStarted,
      Function(String) onPageFinished,
      String? initialUrl,
      ) async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            currentUrl = url;
            onPageStarted(url);
          },
          onPageFinished: onPageFinished,
        ),
      )
      ..setBackgroundColor(Colors.white);

    if (initialUrl != null) {
      await _controller?.loadRequest(Uri.parse(initialUrl));
    }
  }

  Widget buildWebView() {
    return _controller != null
        ? WebViewWidget(controller: _controller!)
        : const SizedBox();
  }

  void loadUrl(String url) {
    _controller?.loadRequest(Uri.parse(url));
  }
}
