import 'dart:developer';

import 'package:aer/UI/screen-2/tab_grid.dart';
import 'package:aer/UI/testing-1/web_view_screen.dart';
import 'package:aer/UI/utils/constant.dart';
import 'package:aer/UI/utils/random_color.dart';
import 'package:aer/services/tab_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    TabService().tabList.add(const WebViewScreen());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: true,
      child: Scaffold(
        body: TabService().showTabs
            ? TabGrid()
            : IndexedStack(
                index: TabService().currentIndex,
                children: TabService().tabList,
              ),
        bottomNavigationBar: _bottomNavBar(),
      ),
    );
  }

  Widget _bottomNavBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              TabService().tabList.add(const WebViewScreen());
              TabService().setCurrentIndex(TabService().tabList.length - 1);
            });
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              TabService().toggleTabs();
            });
          },
          icon: const Icon(Icons.menu),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Uri toSearchQuery(String url) {
  if (checkFormat(url)) {
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

bool checkFormat(String url) {
  RegExp regex = RegExp(r'^(https?://)?(www\.)?([a-zA-Z0-9-]+)(\.[a-zA-Z]{2,}){1,2}$');

  return regex.hasMatch(url);
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {},
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: RandomColorGenerator.randomColor,
          child: WebViewWidget(controller: controller),
        ),
        FloatingActionButton(
          onPressed: () {
            Uri uri = toSearchQuery("google.com");
            controller.loadRequest(uri);
          },
          child: const Icon(Icons.refresh),
        )
      ],
    );
  }
}
