import 'package:aer/UI/Widget/search_box.dart';
import 'package:aer/UI/utils/web_view_controller.dart';
import 'package:aer/app_routes.dart';
import 'package:aer/bloc/appStartsCubit/app_starts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  final Function(String?)? onUpdateTitle;

  const HomePage({
    Key? key,
    this.onUpdateTitle,
  }) : super(key: key);

  String? get title => _HomePageState.titles[key];
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final Map<Key?, String> titles = {};

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
              onSubmitTextField: (value) {
                onSubmitQuery(value);
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigatorKey?.currentState!.pushNamed('/tabview');
          },
        ),
      ),
    );
  }

  void onSubmitQuery(query) {
    if (query.isNotEmpty) {
      String route = "/webPageLoader";
      context.read<AppStartsCubit>().appChangeRoute(route, query);
      Navigator.pushNamed(context, route, arguments: query);
    }
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


//
// PreferredSizeWidget _buildAppBar() {
//   return AppBar(
//     backgroundColor: Colors.white,
//     elevation: 0,
//     title: !showTabGrid
//         ? Row(
//       children: [
//         Expanded(
//           child: Container(
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: TextField(
//               controller: urlController,
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Search or enter URL',
//               ),
//               onSubmitted: (value) {
//                 tabs[currentIndex].webViewer.loadUrl(value);
//               },
//             ),
//           ),
//         ),
//       ],
//     )
//         : Text('${tabs.length} tabs'),
//     actions: [
//       IconButton(
//         icon: Text(
//           tabs.length.toString(),
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         onPressed: () => setState(() => showTabGrid = !showTabGrid),
//       ),
//       PopupMenuButton<String>(
//         onSelected: (value) {
//           if (value == 'new_tab') _addNewTab();
//         },
//         itemBuilder: (context) => [
//           const PopupMenuItem(
//             value: 'new_tab',
//             child: Text('New tab'),
//           ),
//         ],
//       ),
//     ],
//   );
// }
