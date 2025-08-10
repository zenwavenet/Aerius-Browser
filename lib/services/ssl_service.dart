import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ssl_info.dart';

class SSLService {
  static Future<SSLInfo?> getSSLInfo(String domain) async {
    try {
      final crtshUrl = 'https://crt.sh/?q=$domain&output=json&limit=1';
      final crtshResponse = await http
          .get(Uri.parse(crtshUrl))
          .timeout(Duration(seconds: 10));

      if (crtshResponse.statusCode == 200) {
        final crtshData = json.decode(crtshResponse.body);

        if (crtshData is List && crtshData.isNotEmpty) {
          final cert = crtshData[0];
          return _parseCrtShCertificate(cert, domain);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ crt.sh API błąd: $e');
    }

    return null;
  }

  static SSLInfo _parseCrtShCertificate(
    Map<String, dynamic> cert,
    String domain,
  ) {
    final validFrom =
        DateTime.tryParse(cert['not_before'] ?? '') ?? DateTime.now();
    final validTo =
        DateTime.tryParse(cert['not_after'] ?? '') ??
        DateTime.now().add(Duration(days: 90));
    final now = DateTime.now();

    return SSLInfo(
      subject: cert['name_value'] ?? 'CN=$domain',
      issuer: cert['issuer_name'] ?? 'Unknown CA',
      serialNumber: cert['serial_number'] ?? 'N/A',
      version: '3',
      signatureAlgorithm: 'SHA256withRSA',
      publicKeyAlgorithm: 'RSA 2048 bit',
      validFrom: validFrom,
      validTo: validTo,
      fingerprint: cert['sha256_fingerprint'] ?? cert['fingerprint'] ?? 'N/A',
      subjectAltNames: _extractAltNames(cert['name_value']),
      isValid: validTo.isAfter(now),
      timeUntilExpiry: validTo.difference(now),
    );
  }

  static List<String> _extractAltNames(dynamic altNames) {
    if (altNames == null) return [];
    if (altNames is String) return [altNames];
    if (altNames is List) return altNames.map((e) => e.toString()).toList();
    return [];
  }
}
