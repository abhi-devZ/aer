import 'package:aer/UI/Screen/web_view.dart';
import 'package:aer/UI/Widget/search_box.dart';
import 'package:aer/UI/utils/web_view_controller.dart';
import 'package:aer/app_routes.dart';
import 'package:aer/bloc/appStartsCubit/app_starts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'browser_tab_manager.dart';

class HomePage extends StatefulWidget {
  final Function(String?)? onUpdateTitle;

  const HomePage({
    super.key,
    this.onUpdateTitle,
  });

  String? get title => _HomePageState.titles[key];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final Map<Key?, String> titles = {};
  final TextEditingController _controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    // ValueNotifier<String>
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SearchBox(
              isLoading: false,
              controller: _controller,
              onSubmitTextField: (value) {
                onSubmitQuery(value);
                _controller.clear();
              },
            ),
          ),
        ),
      ),
    );
  }

  void onSubmitQuery(query) {
    if (query.isNotEmpty) {
      String route = "/webPageLoader";
      context.read<AppStartsCubit>().appChangeRoute(route, query);
      // Navigator.pushReplacementNamed(context, route, arguments: query);
    }
  }
}

