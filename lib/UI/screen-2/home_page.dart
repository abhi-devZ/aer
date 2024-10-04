import 'package:aer/UI/Widget/gradient_shadow_container.dart';
import 'package:aer/UI/Widget/search_box.dart';
import 'package:aer/UI/utils/web_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: const Center(
          child: AndroidChromeTabs(),
          // child: Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 8.0),
          //   child: SearchBox(
          //     isLoading: false,
          //   ),
          // ),
        ),
      ),
    );
  }
}

class TabData {
  final String title;
  String url;
  final Key key = UniqueKey();
  final WebViewer webViewer;
  String? favicon;

  TabData({
    required this.title,
    required this.url,
    required BuildContext context,
  }) : webViewer = WebViewer(context);
}

class AndroidChromeTabs extends StatefulWidget {
  const AndroidChromeTabs({Key? key}) : super(key: key);

  @override
  State<AndroidChromeTabs> createState() => _AndroidChromeTabsState();
}

class _AndroidChromeTabsState extends State<AndroidChromeTabs> {
  List<TabData> tabs = [];
  int currentIndex = 0;
  bool showTabGrid = false;
  final TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addNewTab();
  }

  void _addNewTab() {
    setState(() {
      tabs.add(TabData(
        title: 'New Tab',
        url: 'about:blank',
        context: context,
      ));
      currentIndex = tabs.length - 1;
    });
  }

  void _removeTab(int index) {
    setState(() {
      tabs.removeAt(index);
      if (currentIndex >= tabs.length) {
        currentIndex = tabs.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: showTabGrid ? _buildTabGrid() : _buildCurrentTab(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: !showTabGrid
          ? Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search or enter URL',
                      ),
                      onSubmitted: (value) {
                        tabs[currentIndex].webViewer.loadUrl(value);
                      },
                    ),
                  ),
                ),
              ],
            )
          : Text('${tabs.length} tabs'),
      actions: [
        IconButton(
          icon: Text(
            tabs.length.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => setState(() => showTabGrid = !showTabGrid),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'new_tab') _addNewTab();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'new_tab',
              child: Text('New tab'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabGrid() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // Adjusted aspect ratio to match preview container
              childAspectRatio: 0.65, // This matches the 200/450 ratio you mentioned
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: tabs.length,
            itemBuilder: (context, index) => _buildTabCard(index),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _addNewTab,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('New Tab', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
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
            urlController.text = tabs[index].webViewer.currentUrl.value;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: tabs[index].webViewer.currentUrl,
                    builder: (context, url, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: WebViewWidget(
                          controller: tabs[index].webViewer.webViewController,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeTab(index),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder<String>(
                valueListenable: tabs[index].webViewer.title,
                builder: (context, title, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isEmpty ? tabs[index].title : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: tabs[index].webViewer.currentUrl,
                        builder: (context, url, child) {
                          return Text(
                            url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    return Column(
      children: [
        ValueListenableBuilder<double>(
          valueListenable: tabs[currentIndex].webViewer.progressLevel,
          builder: (context, progress, child) {
            return progress < 100
                ? LinearProgressIndicator(
                    value: progress / 100.0,
                    backgroundColor: Colors.grey[200],
                  )
                : const SizedBox.shrink();
          },
        ),
        Material(
          child: SizedBox(
            width: 200,
            height: 450,
            child: WebViewWidget(
              controller: tabs[currentIndex].webViewer.webViewController,
            ),
          ),
        ),
      ],
    );
  }
}
