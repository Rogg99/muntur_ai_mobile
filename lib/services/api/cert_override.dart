import 'dart:io';

import 'package:crypto/crypto.dart';

/// The API server (195.26.244.215:447) runs on a self-signed certificate —
/// there's no CA-signed cert for a bare IP. Rather than trusting any
/// certificate (which would allow a MITM to intercept all traffic in
/// release builds), this pins the server's exact certificate by SHA-256
/// fingerprint: only THIS specific certificate is accepted, everything
/// else is rejected like normal.
///
/// Regenerate this value if the server's certificate is ever renewed/rotated:
///   openssl s_client -connect 195.26.244.215:447 -servername 195.26.244.215 </dev/null 2>/dev/null | openssl x509 -noout -fingerprint -sha256
const _pinnedCertSha256Fingerprint =
    '9FB0F2F246A31ABCA13B592DDFD1DBFCFE665BCE7C5B75F2A9F9C030F0255F52';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        final fingerprint = sha256.convert(cert.der).toString().toUpperCase();
        return fingerprint == _pinnedCertSha256Fingerprint;
      };
  }
}
