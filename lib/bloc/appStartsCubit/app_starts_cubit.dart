import 'package:aer/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_starts_state.dart';

class AppStartsCubit extends Cubit<AppStartsState> {
  AppStartsCubit() : super(AppStartsInitial());

  Future<void> appOpen() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? route = prefs.getString('lastRoute');
      if (initialRoute == '/test') {
        emit(AppNavToPage(routeName: initialRoute));
      } else if (route != null) {
        String? arguments = prefs.getString('arguments');
        emit(AppNavToPage(routeName: route, arguments: arguments));
      } else {
        emit(AppNavToPage(routeName: "/home"));
      }
    } catch (e) {
      emit(AppNavToPage(routeName: "/home"));
    }
  }

  Future<void> appChangeRoute(route, arguments) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastRoute', route);
      await prefs.setString('arguments', arguments);
    } catch (e) {
      emit(AppNavToPage(routeName: "/home"));
    }
  }
}
