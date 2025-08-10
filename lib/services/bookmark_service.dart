import '../models/bookmark_item.dart';

class BookmarkService {
  static final List<BookmarkItem> _bookmarks = [];

  static List<BookmarkItem> get bookmarks => List.unmodifiable(_bookmarks);

  static void addBookmark(BookmarkItem bookmark) {
    if (!_bookmarks.any((b) => b.url == bookmark.url)) {
      _bookmarks.add(bookmark);
    }
  }

  static void removeBookmark(String url) {
    _bookmarks.removeWhere((bookmark) => bookmark.url == url);
  }

  static bool isBookmarked(String url) {
    return _bookmarks.any((bookmark) => bookmark.url == url);
  }

  static void clearBookmarks() {
    _bookmarks.clear();
  }

  static List<BookmarkItem> getDefaultBookmarks() {
    return [
      BookmarkItem(title: 'Google', url: 'https://google.com', favicon: '🔍'),
      BookmarkItem(title: 'YouTube', url: 'https://youtube.com', favicon: '📺'),
      BookmarkItem(title: 'GitHub', url: 'https://github.com', favicon: '💻'),
      BookmarkItem(
        title: 'Stack Overflow',
        url: 'https://stackoverflow.com',
        favicon: '❓',
      ),
      BookmarkItem(title: 'Reddit', url: 'https://reddit.com', favicon: '🗨️'),
      BookmarkItem(title: 'Twitter', url: 'https://twitter.com', favicon: '🐦'),
    ];
  }
}
