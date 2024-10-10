import 'package:aer/UI/Screen/widget_test_page.dart';
import 'package:aer/bloc/appStartsCubit/app_starts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'UI/Screen/web_view.dart';
import 'UI/testing-1/browser_dash.dart';
import 'UI/testing-1/dashboard.dart';
import 'UI/testing-1/web_view_screen.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => BlocListener<AppStartsCubit, AppStartsState>(
            listener: (context, state) {
              if (state is AppNavToPage) {
                navigatorKey?.currentState!.pushReplacementNamed('/home', /*state.routeName*/ arguments: state.arguments);
              }
            },
            child: const Scaffold(
              body: Center(
                child: Text("Loading.....!"),
              ),
            ),
          ),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const Dashboard(),
        );
      case '/test':
        return MaterialPageRoute(
          builder: (_) => const WidgetTestPage(),
        );
      case '/tabview':
        return MaterialPageRoute(
          builder: (_) => const Dashboard(),
        );
      case '/webPageLoader':
        final String data = settings.arguments as String;
        return MaterialPageRoute(
          maintainState: true,
          builder: (_) => WebView(data: data),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

// String get initialRoute => '/test';
String get initialRoute => '/';
