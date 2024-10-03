part of 'web_view_bloc.dart';

abstract class WebViewState extends Equatable {
  const WebViewState();
}

class WebViewInitial extends WebViewState {
  @override
  List<Object> get props => [];
}

class NewQueryLoadState extends WebViewState {
  final Uri searchQuery;

  const NewQueryLoadState({required this.searchQuery});

  @override
  List<Object> get props => [searchQuery];
}
