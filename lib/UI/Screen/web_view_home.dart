import 'package:aer/bloc/appStartsCubit/app_starts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'a_i.dart';

class WebViewHome extends StatefulWidget {
  const WebViewHome({super.key});

  @override
  State<WebViewHome> createState() => _WebViewHomeState();
}

class _WebViewHomeState extends State<WebViewHome> {
  final FocusNode _focusNode = FocusNode();
  final _searchTextController = TextEditingController();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: ClipPath(
        clipper: ShapePainter(),
        child: Container(
          color: Colors.black45,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
                child: Image.network(
                  "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png",
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  margin: const EdgeInsets.only(left: 32.0, right: 32.0),
                  child: TextFormField(
                    controller: _searchTextController,
                    focusNode: _focusNode,
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
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onSubmitQuery() {
    if (_searchTextController.text.isNotEmpty) {
      String route = "/webPageLoader";
      String arguments = _searchTextController.text;
      context.read<AppStartsCubit>().appChangeRoute(route, arguments);

      Navigator.pushNamed(context, route, arguments: arguments);
      _searchTextController.clear();
    }
  }
}
