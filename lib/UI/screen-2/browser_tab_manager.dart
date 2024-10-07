import 'package:aer/UI/screen-2/home_page.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserTabManager extends StatefulWidget {
  const BrowserTabManager({Key? key}) : super(key: key);

  @override
  State<BrowserTabManager> createState() => _BrowserTabManagerState();
}

class _BrowserTabManagerState extends State<BrowserTabManager> {
  List<HomePage> tabs = [];
  int currentIndex = 0;
  bool showTabGrid = false;

  @override
  void initState() {
    super.initState();
    _addNewTab();
  }

  void _addNewTab() {
    setState(() {
      tabs.add(HomePage(
        key: UniqueKey(),
        onUpdateTitle: (title) {
          setState(() {});
        },
      ));
      currentIndex = tabs.length - 1;
      showTabGrid = false;
    });
  }

  void _removeTab(int index) {
    setState(() {
      tabs.removeAt(index);
      if (tabs.isEmpty) {
        _addNewTab();
      } else if (currentIndex >= tabs.length) {
        currentIndex = tabs.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showTabGrid) {
          setState(() {
            showTabGrid = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: showTabGrid ? _buildTabGrid() : tabs[currentIndex],
        floatingActionButton: !showTabGrid
            ? FloatingActionButton(
          child: const Icon(Icons.tab_outlined),
          onPressed: () {
            setState(() {
              showTabGrid = true;
            });
          },
        )
            : null,
      ),
    );
  }

  Widget _buildTabGrid() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewTab,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: tabs.length,
        itemBuilder: (context, index) => _buildTabCard(index),
      ),
    );
  }

  Widget _buildTabCard(int index) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            currentIndex = index;
            showTabGrid = false;
          });
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeTab(index),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Text(
                  tabs[index].title ?? 'New Tab',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowserTab extends StatefulWidget {
  final Function(String?)? onUpdateTitle;

  const BrowserTab({
    Key? key,
    this.onUpdateTitle,
  }) : super(key: key);

  String? get title => _BrowserTabState.titles[key];

  @override
  State<BrowserTab> createState() => _BrowserTabState();
}

class _BrowserTabState extends State<BrowserTab> {
  static final Map<Key?, String> titles = {};
  late final WebViewController controller;
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              isLoading = false;
            });
            final title = await controller.getTitle();
            titles[widget.key] = title ?? 'New Tab';
            widget.onUpdateTitle?.call(title);
          },
        ),
      );
    _loadHomePage();
  }

  void _loadHomePage() {
    setState(() {
      searchController.clear();
    });
  }

  void _handleSearch() {
    String searchText = searchController.text.trim();
    if (searchText.isEmpty) return;

    String url;
    if (searchText.startsWith('http://') || searchText.startsWith('https://')) {
      url = searchText;
    } else if (searchText.contains('.') && !searchText.contains(' ')) {
      url = 'https://$searchText';
    } else {
      url = 'https://www.google.com/search?q=${Uri.encodeComponent(searchText)}';
    }

    controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search or enter URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _handleSearch,
                      ),
                    ),
                    onSubmitted: (_) => _handleSearch(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading) const LinearProgressIndicator(),
        Expanded(
          child: WebViewWidget(controller: controller),
        ),
      ],
    );
  }
}