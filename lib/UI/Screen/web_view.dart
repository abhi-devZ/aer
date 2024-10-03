import 'package:aer/UI/utils/constant.dart';
import 'package:aer/UI/utils/web_view_controller.dart';
import 'package:aer/bloc/appStartsCubit/app_starts_cubit.dart';
import 'package:aer/bloc/webViewBloc/web_view_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'demo.dart';

class WebView extends StatefulWidget {
  final String data;

  const WebView({super.key, required this.data});

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late WebViewer webViewer;
  final GlobalKey _globalKey = GlobalKey();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    webViewer = WebViewer(context);
    super.initState();
    _searchTextController.text = widget.data;
    onSubmitQuery();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewer.webViewController.canGoBack()) {
          webViewer.webViewController.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          key: _globalKey,
          // appBar: AppBar(
          //   title: const Text('Flutter WebView example'),
          //   // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
          //   actions: <Widget>[
          //     NavigationControls(webViewController: webViewer.webViewController),
          //     SampleMenu(webViewController: webViewer.webViewController),
          //   ],
          // ),
          body: BlocConsumer<WebViewBloc, WebViewState>(
            listener: (context, state) {
              if (state is NewQueryLoadState) {
                webViewer.webViewController.loadRequest(state.searchQuery);
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: kBottomNavigationBarHeight,
                    child: WebViewWidget(
                      controller: webViewer.webViewController,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _bottomAppBar(),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _bottomAppBar() {
    return SizedBox(
      height: kBottomNavigationBarHeight,
      child: BottomAppBar(
        child: TextFormField(
          controller: _searchTextController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 16.0, bottom: 2.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                onSubmitQuery();
              },
              child: const Icon(
                Icons.search_rounded,
                size: 20,
              ),
            ),
          ),
          // style: const TextStyle(color: Colors.black),
          cursorColor: Colors.white,
          cursorWidth: 1.0,
          cursorRadius: const Radius.circular(50.0),
          onFieldSubmitted: (value) {
            onSubmitQuery();
          },
          onTapOutside: (event) {
            // constructSearchQueryUrl();
            logger.e("onOutside");
          },
        ),
      ),
    );
  }

  void onSubmitQuery() {
    if (_searchTextController.text.isNotEmpty) {
      String route = "/webPageLoader";
      String arguments = _searchTextController.text;
      context.read<AppStartsCubit>().appChangeRoute(route, arguments);
      BlocProvider.of<WebViewBloc>(context).add(WebViewSearchEvent(searchQuery: _searchTextController.text));
    }
  }
}
