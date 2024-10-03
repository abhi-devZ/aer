part of 'web_view_bloc.dart';

abstract class WebViewEvent extends Equatable {
  const WebViewEvent();
}

class WebViewSearchEvent extends WebViewEvent {
  final String searchQuery;

  const WebViewSearchEvent({required this.searchQuery});

  @override
  List<Object> get props => [searchQuery];
}
