import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import '../widgets/CustomAppBar.dart';

/// Privacy & Safety Policy. Static legal text — see
/// Doc/privacy-and-safety-policy.docx for the source.
class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(titleTxt: 'Confidentialité & sécurité'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Privacy & Safety Policy",
            style: appStyle.H3(weight: 'bold'),
          ),
          const SizedBox(height: 20),
          _Section(
            appStyle: appStyle,
            title: "1. Regulatory Alignment Statement",
            body:
                "AUTOSYNX BY ZEMNOVA (formerly Muntur AI) is committed to protecting user privacy, data security, and personal safety. This Privacy & Safety Policy governs data collection, audio recording processing, and location tracking across all mobile client applications. Our workflows are engineered to comply with regional data protection standards, Cameroon's Law No. 2010/012 on Cybersecurity and Cybercriminality, and international frameworks including the African Union Convention on Cyber Security and Personal Data Protection.",
          ),
          _Section(
            appStyle: appStyle,
            title: "2. Core Data Categories Collected",
            body:
                "To provide accurate voice diagnostics and proximity dispatching, AUTOSYNX collects the following necessary data categories:\n\n"
                "• Real-Time Geolocation: Continuous background GPS coordinates are processed during active dispatch requests to locate broken-down drivers and route nearby verified mechanics.\n\n"
                "• Voice Notes & Audio Assets: Audio clips recorded to describe vehicle issues are uploaded, compressed, and processed via AI speech-to-text models to generate diagnostic summaries.\n\n"
                "• Financial Identifiers: Mobile phone numbers linked to MTN MoMo or Orange Money wallets are encrypted to execute coin purchases, subscription billing, and escrow transfers.\n\n"
                "• Device Telemetry: Device model, operating system version, and network state metrics are collected to optimize offline background data synchronization.",
          ),
          _Section(
            appStyle: appStyle,
            title: "3. Offline Storage & On-Device Vaulting",
            body:
                "When operating without internet connectivity, diagnostic inputs, audio records, and transaction states cache locally inside a secure SQLite database vault on the user's mobile device. Once network access returns, background sync workers (WorkManager on Android / Background Tasks on iOS) securely transmit compressed data blocks to central server infrastructure and flush local audio caches.",
          ),
          _Section(
            appStyle: appStyle,
            title: "4. Third-Party Sharing & Encryption Protocols",
            body:
                "User data is never sold or rented to third parties. Data fields are transmitted exclusively over encrypted Transport Layer Security (TLS 1.3) channels to authenticated payment gateway partners (Campay, Maviance) to clear financial flows, or to licensed SMS aggregators to send automated dispatch notifications.",
          ),
          _Section(
            appStyle: appStyle,
            title: "5. Data Retention & User Deletion Rights",
            body:
                "User account profiles and financial ledger records are retained as long as the account remains active to fulfill legal and accounting duties. Users may request full account deletion via app settings. Upon verification, personal identifiers, voice notes, and GPS logs are permanently deleted or anonymized within 30 days, excepting records required by law.",
          ),
          _Section(
            appStyle: appStyle,
            title: "6. User Safety, Anti-Harassment & Phone Number Masking",
            body:
                "To protect driver and mechanic safety and prevent off-app harassment, raw phone numbers are masked during early match communications. All interactions occur via in-app text chat or VoIP voice calling, shielding user identities while maintaining a complete safety audit trail.",
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.appStyle, required this.title, required this.body});

  final AppStyle appStyle;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: appStyle.H4(weight: 'bold')),
          const SizedBox(height: 8),
          Text(body, style: appStyle.H5()),
        ],
      ),
    );
  }
}
