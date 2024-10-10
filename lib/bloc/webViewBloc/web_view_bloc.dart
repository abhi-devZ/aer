import 'dart:async';

import 'package:aer/UI/utils/constant.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'web_view_event.dart';

part 'web_view_state.dart';

class WebViewBloc extends Bloc<WebViewEvent, WebViewState> {
  WebViewBloc() : super(WebViewInitial()) {
    on<WebViewSearchEvent>(_webViewSearchEvent);
  }

  Future<FutureOr<void>> _webViewSearchEvent(WebViewSearchEvent event, Emitter<WebViewState> emit) async {
    Uri url = toSearchQuery(event.searchQuery);
    emit(NewQueryLoadState(searchQuery: url));
  }

  Uri toSearchQuery(String url) {
    if (checkFormat(url)) {
      if (!url.startsWith("http://") && !url.startsWith("https://")) {
        url = "https://$url";
      }

      Uri uri = Uri.parse(url);
      String protocol = uri.scheme;
      String domain = uri.host;
      if (domain.split('.').length == 2 && !domain.startsWith('www')) {
        domain = 'www.$domain';
      }

      return Uri.parse('$protocol://$domain');
    } else {
      String encodedQuery = Uri.encodeQueryComponent(url);
      return Uri.parse('$searchEngineUrl?q=$encodedQuery');
    }
  }

  bool checkFormat(String url) {
    RegExp regex = RegExp(r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9-]+)(\.[a-zA-Z]{2,}){1,2}$');

    return regex.hasMatch(url);
  }
}
