import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_starts_state.dart';

class AppStartsCubit extends Cubit<AppStartsState> {
  AppStartsCubit() : super(AppStartsInitial());

  Future<void> appOpen() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? initialRoute = prefs.getString('lastRoute');
      if (initialRoute != null) {
        String? arguments = prefs.getString('arguments');
        // emit(AppNavToPage(routeName: initialRoute, arguments: arguments));
        emit(AppNavToPage(routeName: "/home"));
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
