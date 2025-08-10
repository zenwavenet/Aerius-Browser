class SSLUtils {
  static String extractDomain(String subject) {
    final match = RegExp(r'CN=([^,]+)').firstMatch(subject);
    return match?.group(1) ?? subject;
  }

  static String extractIssuer(String issuer) {
    final match = RegExp(r'CN=([^,]+)').firstMatch(issuer);
    return match?.group(1) ?? issuer;
  }

  static String formatFingerprint(String fingerprint) {
    if (fingerprint.length <= 32) return fingerprint;

    final pairs = <String>[];
    for (int i = 0; i < fingerprint.length; i += 2) {
      if (i + 1 < fingerprint.length) {
        pairs.add(fingerprint.substring(i, i + 2));
      }
    }
    return pairs.join(':').toUpperCase();
  }

  static bool isSSLSecure(String url) {
    return url.startsWith('https://');
  }

  static String getSSLProtocol(String url) {
    if (url.startsWith('https://')) return 'HTTPS';
    if (url.startsWith('http://')) return 'HTTP';
    return 'Unknown';
  }
}
