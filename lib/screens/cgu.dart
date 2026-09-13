import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import '../widgets/CustomAppBar.dart';

/// Terms of Service & General Conditions of Use. Static legal text — see
/// Doc/terms-of-service-gcu.docx for the source; the marketplace parts
/// commission clause (section 5) reflects the current 5,000 XAF/month
/// vendor subscription + 5% commission (95% vendor / 5% ZEMNOVA split)
/// model, not the doc's original 90/10 split which is obsolete.
class CGU extends StatelessWidget {
  const CGU({super.key});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(titleTxt: 'CGU'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Terms of Service & General Conditions of Use",
            style: appStyle.H3(weight: 'bold'),
          ),
          const SizedBox(height: 20),
          _Section(
            appStyle: appStyle,
            title: "1. Contractual Framework, Corporate Identity & Rebranding Notice",
            body:
                "These Terms of Service and General Conditions of Use ('GCU' / 'Conditions Générales d'Utilisation') govern access to and usage of the AUTOSYNX mobile application marketplace and diagnostic software. AUTOSYNX BY ZEMNOVA is a software asset wholly owned, developed, and managed by ZEMNOVA ('Holding Company'). All users acknowledge that the platform formerly operating as Muntur AI has officially transitioned to AUTOSYNX BY ZEMNOVA, and these terms apply in full to all current and legacy user accounts.",
          ),
          _Section(
            appStyle: appStyle,
            title: "2. Scope of Services & AI Diagnostic Disclaimers",
            body:
                "AUTOSYNX functions as an intermediary technological matching platform. The application provides an integrated automated AI engine that translates user text descriptions, mechanical error log files, or voice note audio recordings into diagnostic guidance summaries. AUTOSYNX does not maintain physical repair garages, employ field technicians, or manufacture vehicle parts. AI diagnostic outputs are automated assessments intended solely as informational guidelines. ZEMNOVA assumes no legal liability for inaccuracies, mechanical troubleshooting errors, or repairs performed by independent service providers.",
          ),
          _Section(
            appStyle: appStyle,
            title: "3. User Account Registration & Account Profiles",
            body:
                "Users register directly using their mobile phone number integrated with local Mobile Money utility frameworks. Accounts must be designated explicitly as either a 'Client' (Vehicle Owner) or 'Professional' (Mechanic/Vendor) profile to preserve transactional integrity. Users are responsible for maintaining device security and restricting unauthorized account usage.",
          ),
          _Section(
            appStyle: appStyle,
            title: "4. Digital Virtual Economy (Coins), Pricing & Subscriptions",
            body:
                "Pay-as-you-go features consume virtual platform credits ('Coins'). Coins are purchased in digital packs (1,500 XAF for 500 coins) via MoMo/Orange Money. Coins are non-refundable, non-transferable, and cannot be redeemed for cash. Monthly subscriptions (Simple, Intermediate, Premium/Enterprise) bill upfront every 30 days. If a renewal fails due to insufficient mobile wallet funds, account access drops back to the Pay-As-You-Go level.",
          ),
          _Section(
            appStyle: appStyle,
            title: "5. Multi-Party Gateway Escrow & Split Payments",
            body:
                "All repair bookings require an upfront 1,000 XAF deposit. The gateway separates a 300 XAF platform dispatch fee and holds 700 XAF in escrow. Funds are disbursed to the mechanic upon entry of the Buyer's 4-digit verification PIN or confirmed GPS completion metrics.\n\nFor marketplace spare-parts sales: vendors pay a flat 5,000 XAF/month subscription plus a 5% commission on each transaction (95% vendor / 5% ZEMNOVA split), with guaranteed price parity against physical retail stores.",
          ),
          _Section(
            appStyle: appStyle,
            title: "6. Anti-Circumvent Rules & Shadow-Ban Penalties",
            body:
                "Circumventing platform payment protocols by arranging offline cash transactions to bypass commissions is strictly forbidden. Off-platform repairs void the user's 7-Day Guarantee. Confirmed circumvention or GPS fraud infractions result in immediate profile suspension or a 30-day shadow-ban from the automated AI recommendation loop.",
          ),
          _Section(
            appStyle: appStyle,
            title: "7. Dispute Protocols, Arbitration Window & Limitation of Liability",
            body:
                "Unresolved repair disputes or contested spare part deliveries must be flagged within a 48-hour arbitration window to freeze escrow funds for ZEMNOVA administrative review. To the maximum extent permitted by CEMAC and international law, ZEMNOVA's total financial liability for any platform claim is capped at the total fee collected by the platform from that specific transaction.",
          ),
          _Section(
            appStyle: appStyle,
            title: "8. Governing Law & Jurisdiction",
            body:
                "These Terms of Service and GCU are governed by and construed in accordance with the laws of the Republic of Cameroon and the business regulations of the Central African Economic and Monetary Community (CEMAC). Any legal disputes shall be submitted to the exclusive jurisdiction of the competent courts in Douala or Yaoundé.",
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
