class URLValidator {
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String formatUrl(String input) {
    if (input.isEmpty) return '';

    input = input.trim();

    if (!input.contains('.') || input.contains(' ')) {
      return 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
    }

    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'https://$input';
    }

    return input;
  }

  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  static String getDisplayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host + uri.path;
    } catch (e) {
      return url;
    }
  }
}
