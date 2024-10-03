import 'package:aer/bloc/appStartsCubit/app_starts_cubit.dart';
import 'package:aer/bloc/webViewBloc/web_view_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UI/screen/aer_home_page.dart';
import 'UI/utils/constant.dart';
import 'app_routes.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black54,
    statusBarIconBrightness: Brightness.light, // Light icons for dark gradient
    statusBarBrightness: Brightness.dark, // Dark background (iOS)
  ));
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,overlays: [SystemUiOverlay.top]
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SharedPreferences _prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WebViewBloc(),
        ),
        BlocProvider(
          create: (context) => AppStartsCubit()..appOpen(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.dark,
          textTheme: const TextTheme(
            titleMedium: TextStyle(color: Colors.white), // Example for input text
          ),
          useMaterial3: true,
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        navigatorKey: navigatorKey,
        onGenerateRoute: AppRouter().generateRoute,
      ),
    );
  }

}

