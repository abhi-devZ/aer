import 'dart:async';

import 'package:aer/UI/Widget/search_box.dart';
import 'package:aer/UI/utils/web_view_controller.dart';
import 'package:aer/bloc/appStartsCubit/app_starts_cubit.dart';
import 'package:aer/bloc/webViewBloc/web_view_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatefulWidget {
  final String data;

  const WebView({super.key, required this.data});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late WebViewer webViewer;
  final GlobalKey _globalKey = GlobalKey();
  bool _isBottomSheetVisible = true;
  double _lastScrollPosition = 0;
  Timer? _scrollDebounce;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    webViewer = WebViewer(context);
    super.initState();
    onSubmitQuery(widget.data);
    _initScrollListener();
  }

  void _initScrollListener() {
    webViewer.webViewController.setOnScrollPositionChange(
      (ScrollPositionChange change) {
        // Debounce scroll events
        if (_scrollDebounce?.isActive ?? false) _scrollDebounce!.cancel();
        _scrollDebounce = Timer(const Duration(milliseconds: 50), () {
          if (!mounted) return;

          // Get current scroll position
          final currentPosition = change.y;

          // Calculate scroll direction and distance
          final double delta = currentPosition - _lastScrollPosition;

          // Update bottom sheet visibility based on scroll direction
          if (delta > 50 && _isBottomSheetVisible) {
            // Scrolling down - hide bottom sheet
            setState(() {
              _isBottomSheetVisible = false;
            });
          } else if (delta < -50 && !_isBottomSheetVisible) {
            // Scrolling up - show bottom sheet
            setState(() {
              _isBottomSheetVisible = true;
            });
          }

          // Update last scroll position
          _lastScrollPosition = currentPosition;
        });
      },
    );
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
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
        top: true,
        child: Scaffold(
          key: _globalKey,
          body: BlocConsumer<WebViewBloc, WebViewState>(
            listener: (context, state) {
              if (state is NewQueryLoadState) {
                webViewer.webViewController.loadRequest(state.searchQuery);
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  WebViewWidget(
                    controller: webViewer.webViewController,
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: _bottomAppBar(),
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   right: 0,
                  //   width: 16,
                  //   height: 48,
                  //   child: AbsorbPointer(
                  //     absorbing: true,
                  //     child: GestureDetector(
                  //       behavior: HitTestBehavior.opaque,
                  //       // Important!
                  //       onHorizontalDragStart: (_) {},
                  //       onHorizontalDragUpdate: (_) {},
                  //       onHorizontalDragEnd: (_) {},
                  //       child: Container(
                  //         height: 200,
                  //         color: Colors.blue.withOpacity(0.2),
                  //         child: const Center(
                  //           child: Text('Navigation Blocked Here'),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _bottomAppBar() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: Offset(0, _isBottomSheetVisible ? 0 : 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isBottomSheetVisible ? 1.0 : 0.0,
        child: ValueListenableBuilder<bool>(
          valueListenable: webViewer.isLoading,
          builder: (context, isLoading, child) {
            return SearchBox(
              searchTerm: widget.data,
              isLoading: isLoading,
              controller: _controller,
              onSubmitTextField: (value) => onSubmitQuery(value),
            );
          },
        ),
      ),
    );
  }

  void onSubmitQuery(searchQuery) {
    if (searchQuery.isNotEmpty) {
      webViewer.isLoading.value = true;
      String route = "/webPageLoader";
      String arguments = searchQuery;
      context.read<AppStartsCubit>().appChangeRoute(route, arguments);
      BlocProvider.of<WebViewBloc>(context).add(WebViewSearchEvent(searchQuery: searchQuery));
    }
  }
}
