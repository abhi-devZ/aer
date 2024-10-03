part of 'app_starts_cubit.dart';

@immutable
abstract class AppStartsState {}

class AppStartsInitial extends AppStartsState {}


class AppNavToPage extends AppStartsInitial {
  final String routeName;
  final String? arguments;

  AppNavToPage({required this.routeName, this.arguments});
}