import 'package:webview_flutter/webview_flutter.dart';

class BrowserTab {
  final String id;
  String title;
  String url;
  WebViewController? controller;
  bool isLoading;
  String? favicon;

  BrowserTab({
    required this.id,
    this.title = 'Nowa karta',
    this.url = '',
    this.controller,
    this.isLoading = false,
    this.favicon,
  });

  BrowserTab copyWith({
    String? id,
    String? title,
    String? url,
    WebViewController? controller,
    bool? isLoading,
    String? favicon,
  }) {
    return BrowserTab(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      controller: controller ?? this.controller,
      isLoading: isLoading ?? this.isLoading,
      favicon: favicon ?? this.favicon,
    );
  }
}
