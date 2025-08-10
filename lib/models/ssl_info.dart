class SSLInfo {
  final String subject;
  final String issuer;
  final String serialNumber;
  final String version;
  final String signatureAlgorithm;
  final String publicKeyAlgorithm;
  final DateTime validFrom;
  final DateTime validTo;
  final String fingerprint;
  final List<String> subjectAltNames;
  final bool isValid;
  final Duration timeUntilExpiry;

  SSLInfo({
    required this.subject,
    required this.issuer,
    required this.serialNumber,
    required this.version,
    required this.signatureAlgorithm,
    required this.publicKeyAlgorithm,
    required this.validFrom,
    required this.validTo,
    required this.fingerprint,
    required this.subjectAltNames,
    required this.isValid,
    required this.timeUntilExpiry,
  });

  factory SSLInfo.fromJson(Map<String, dynamic> json) {
    final validFrom =
        DateTime.tryParse(json['validFrom'] ?? '') ?? DateTime.now();
    final validTo =
        DateTime.tryParse(json['validTo'] ?? '') ??
        DateTime.now().add(Duration(days: 365));
    final now = DateTime.now();

    return SSLInfo(
      subject: json['subject'] ?? '',
      issuer: json['issuer'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      version: json['version'] ?? '',
      signatureAlgorithm: json['signatureAlgorithm'] ?? '',
      publicKeyAlgorithm: json['publicKeyAlgorithm'] ?? '',
      validFrom: validFrom,
      validTo: validTo,
      fingerprint: json['fingerprint'] ?? '',
      subjectAltNames: List<String>.from(json['subjectAltNames'] ?? []),
      isValid: validTo.isAfter(now),
      timeUntilExpiry: validTo.difference(now),
    );
  }
}
