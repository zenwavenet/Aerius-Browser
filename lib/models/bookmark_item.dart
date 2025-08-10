class BookmarkItem {
  final String title;
  final String url;
  final String? favicon;

  BookmarkItem({required this.title, required this.url, this.favicon});

  BookmarkItem copyWith({String? title, String? url, String? favicon}) {
    return BookmarkItem(
      title: title ?? this.title,
      url: url ?? this.url,
      favicon: favicon ?? this.favicon,
    );
  }
}
