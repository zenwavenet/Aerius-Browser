import 'package:flutter/material.dart';
import '../models/ssl_info.dart';
import '../utils/date_formatter.dart';
import '../utils/ssl_utils.dart';

class SSLInfoDialog extends StatelessWidget {
  final SSLInfo sslInfo;

  const SSLInfoDialog({super.key, required this.sslInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2C2C2E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Color(0xFF34C759)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informacje o certyfikacie SSL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildSSLInfoSection('Podstawowe informacje', [
                  _buildSSLInfoRow(
                    'Domena',
                    SSLUtils.extractDomain(sslInfo.subject),
                  ),
                  _buildSSLInfoRow(
                    'Status',
                    sslInfo.isValid ? 'Ważny' : 'Wygasły',
                    valueColor: sslInfo.isValid
                        ? Color(0xFF34C759)
                        : Colors.red,
                  ),
                  _buildSSLInfoRow(
                    'Wygasa za',
                    DateFormatter.formatDuration(sslInfo.timeUntilExpiry),
                  ),
                  _buildSSLInfoRow(
                    'Wystawiony przez',
                    SSLUtils.extractIssuer(sslInfo.issuer),
                    isLast: true,
                  ),
                ]),

                _buildSSLInfoSection('Szczegóły certyfikatu', [
                  _buildSSLInfoRow('Numer seryjny', sslInfo.serialNumber),
                  _buildSSLInfoRow('Wersja', sslInfo.version),
                  _buildSSLInfoRow(
                    'Algorytm podpisu',
                    sslInfo.signatureAlgorithm,
                  ),
                  _buildSSLInfoRow(
                    'Klucz publiczny',
                    sslInfo.publicKeyAlgorithm,
                    isLast: true,
                  ),
                ]),

                _buildSSLInfoSection('Okres ważności', [
                  _buildSSLInfoRow(
                    'Ważny od',
                    DateFormatter.formatDate(sslInfo.validFrom),
                  ),
                  _buildSSLInfoRow(
                    'Ważny do',
                    DateFormatter.formatDate(sslInfo.validTo),
                    isLast: true,
                  ),
                ]),

                _buildSSLInfoSection('Odcisk palca', [
                  _buildSSLInfoRow(
                    'SHA256',
                    sslInfo.fingerprint.isNotEmpty &&
                            sslInfo.fingerprint != 'N/A'
                        ? sslInfo.fingerprint
                        : 'Odcisk palca niedostępny',
                    isFingerprint: true,
                    isLast: true,
                  ),
                ]),

                if (sslInfo.subjectAltNames.isNotEmpty)
                  _buildSSLInfoSection('Alternatywne nazwy', [
                    ...sslInfo.subjectAltNames.asMap().entries.map(
                      (entry) => _buildSSLInfoRow(
                        'DNS',
                        entry.value,
                        isLast: entry.key == sslInfo.subjectAltNames.length - 1,
                      ),
                    ),
                  ]),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSSLInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[300],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSSLInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isFingerprint = false,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            // ignore: deprecated_member_use
            : Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: isFingerprint
                ? SelectableText(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }
}
