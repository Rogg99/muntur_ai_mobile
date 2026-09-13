import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';

/// FAQ / Help center: two intro blocks (drivers, professionals) plus an
/// accordion of the 60-item Q&A matrix. Static content — see
/// Doc/faqs-and-help-guide.docx for the source; Q34/Q36 (parts marketplace
/// commission) reflect the current 5,000 XAF/month vendor subscription +
/// 5% commission (95% vendor / 5% ZEMNOVA split) model rather than the
/// doc's original 90/10 split.
class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        leadingWidth: 90,
        leading: Center(
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text('Aide', overflow: TextOverflow.ellipsis, style: appStyle.H3()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "AUTOSYNX BY ZEMNOVA Vehicle Owner Support Center",
            style: appStyle.H4(weight: 'bold'),
          ),
          const SizedBox(height: 8),
          Text(
            "What are Coin Packs? Virtual points used for pay-as-you-go AI diagnostics. Purchasing a 1,500 XAF Starter Pack deposits 500 coins into your wallet.\n\n"
            "How much do actions cost? Typed Text Query = 30 Coins; Voice Note Recording = 50 Coins; Advanced OBD Code Translation = 100 Coins; Automated Mechanic Match = 150 Coins.\n\n"
            "What if I have no network connection? You can record engine sounds or dashboard photos completely offline. The app saves data locally and auto-dispatches help the second your phone finds a signal.\n\n"
            "How does escrow protect me? Every repair finalized in-app is backed by our 7-Day Guarantee. Your 1,000 XAF deposit is locked in escrow and only released when you verify the fix.",
            style: appStyle.H5(),
          ),
          const SizedBox(height: 24),
          Text(
            "AUTOSYNX Pro Workshop Directory",
            style: appStyle.H4(weight: 'bold'),
          ),
          const SizedBox(height: 8),
          Text(
            "How do automated recommendations work? The platform features zero arbitrary lead limits. The AI automatically recommends your workshop based on your location and repair specialties.\n\n"
            "How do escrow payouts work? Clients pay an upfront 1,000 XAF deposit. The app reserves your lead fee and holds the remainder in escrow until you complete the job and the client inputs their 4-digit token.\n\n"
            "What is the Technician Forum? The Technician Voice Forum allows you to post complex troubleshooting voice notes, trade spare parts in the Scrap Market, and earn coin bounties.",
            style: appStyle.H5(),
          ),
          const SizedBox(height: 24),
          Text("Questions fréquentes", style: appStyle.H4(weight: 'bold')),
          const SizedBox(height: 8),
          ..._faqItems.map((qa) => _FaqTile(question: qa.key, answer: qa.value)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        collapsedIconColor: colorScheme.primary,
        iconColor: colorScheme.primary,
        title: Text(question, style: appStyle.H5(weight: 'bold')),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(answer, style: appStyle.H5()),
          ),
        ],
      ),
    );
  }
}

const List<MapEntry<String, String>> _faqItems = [
  MapEntry("What is AUTOSYNX BY ZEMNOVA?",
      "A high-utility mobile platform connecting vehicle owners to automotive professionals via AI-powered voice diagnostics and automated proximity matchmaking."),
  MapEntry("Who owns and operates the application?",
      "AUTOSYNX is a wholly owned software asset developed, protected, and managed by ZEMNOVA (Parent Holding Company & Innovation Hub)."),
  MapEntry("What was the former name of the platform?",
      "The platform formerly operated under the name Muntur AI before officially rebranding to AUTOSYNX BY ZEMNOVA."),
  MapEntry("How do I create an account?",
      "Sign up directly using your mobile phone number, which integrates into local Mobile Money utility frameworks."),
  MapEntry("Do I need continuous internet connection to run the application?",
      "No. AUTOSYNX functions offline, caching voice diagnoses and matching queues locally until network access returns."),
  MapEntry("Can I register both as a driver and a technician on the same account?",
      "No. To preserve transactional integrity, accounts must be explicitly designated as either a Client or a Professional profile."),
  MapEntry("Which cities in Cameroon are covered during launch?",
      "Initial launch operations focus on Douala and Yaoundé, before expanding across major transit corridors."),
  MapEntry("How does the app handle local languages?",
      "The voice assistant is built to interpret localized French, English, Camfranglais, and regional speech patterns."),
  MapEntry("What is the average diagnostic accuracy rate of the AI?",
      "The machine learning models achieve a 94%+ diagnostic accuracy rate on pre-owned imported vehicles."),
  MapEntry("Is AUTOSYNX available on both Android and iOS?",
      "Yes, the mobile application is engineered for cross-platform Android and iOS deployment."),
  MapEntry("What are AUTOSYNX Coins?",
      "Virtual platform points used by Pay-As-You-Go clients to execute AI diagnostics and route requests to mechanics."),
  MapEntry("How much does a standard Coin Pack cost?",
      "A baseline Starter Emergency Pack costs 1,500 XAF and deposits 500 coins into your wallet."),
  MapEntry("What is the coin deduction rate for a standard typed query?",
      "Simple text diagnostic entries run through the AI engine deduct 30 coins from your user balance."),
  MapEntry("Why do voice diagnostics cost more than text?",
      "Voice queries require greater cloud processing power for speech-to-text translation, costing 50 coins per recording."),
  MapEntry("How many coins are consumed for an OBD error code scan?",
      "Advanced OBD2 fault code translation and guided fix reports consume 100 coins."),
  MapEntry("What is the coin cost for an automated mechanic dispatch match?",
      "Pushing your diagnostic report to the 3 nearest matching mechanics consumes 150 coins."),
  MapEntry("Can I convert unused coins back into real Mobile Money cash?",
      "No. Coins are non-refundable digital items usable exclusively for in-app platform actions."),
  MapEntry("Do purchased coins expire if unused?",
      "No. Purchased coins remain in your digital wallet indefinitely until consumed."),
  MapEntry("Can I buy coins using physical scratch cards?",
      "Yes. Physical coin scratch cards (2,000 XAF for 500 coins) are available at partner fuel stations and retail hubs."),
  MapEntry("Can I transfer coins to another driver's wallet?",
      "No. Coins are securely tied to your registered mobile phone identifier to prevent fraud."),
  MapEntry("What is the Driver Simple Plan?",
      "Billed at 1,000 XAF/month, it provides 500 coins monthly plus manual mechanic search directory mapping."),
  MapEntry("What features are included in the Driver Intermediate Plan?",
      "Billed at 2,500 XAF/month, it includes 1,500 coins, free voice messaging tools, automatic pro recommendations, and offline SOS pings."),
  MapEntry("What does the Driver Premium Plan offer?",
      "Billed at 5,000 XAF/month, it provides unlimited AI diagnostics, VIP automatic pro matching, and partner spare parts discount vouchers."),
  MapEntry("What is the Professional Simple Pro Plan?",
      "Billed at 3,000 XAF/month, it assesses a 10% commission on labor and parts, offering basic breakdown leads and read-only Forum access."),
  MapEntry("What are the benefits of the Pro Intermediate Plan?",
      "Billed at 7,500 XAF/month, it lowers job commissions to 5%, grants unlimited AI OBD tools, and unlocks full Technician Forum posting."),
  MapEntry("What is the Enterprise Pro Tier for Master Workshops?",
      "Billed at 15,000 XAF/month, it eliminates labor commission (0%), provides priority map matching, and grants a 'Certified Expert' profile badge."),
  MapEntry("Is there a maximum cap on client leads for pro subscription plans?",
      "No. AUTOSYNX features no artificial lead caps; customer recommendations scale naturally with local demand."),
  MapEntry("Can a mechanic change their subscription tier mid-month?",
      "Yes. Plan upgrades apply immediately, while downgrades take effect at the end of the current 30-day billing cycle."),
  MapEntry("What occurs if my subscription payment attempt fails?",
      "The system automatically drops your account features back to the standard Pay-As-You-Go free tier state."),
  MapEntry("How does the system handle subscription billing retries?",
      "Automated billing workers detect insufficient mobile money balances and retry billing on common regional paydays."),
  MapEntry("Which payment platforms are natively supported in Cameroon?",
      "The platform natively supports direct clearing via MTN Mobile Money (MoMo) and Orange Money payment gateways."),
  MapEntry("What is the purpose of the 1,000 XAF user repair deposit?",
      "It ensures driver commitment, covers platform dispatch costs (300 XAF), and holds 700 XAF securely in escrow for the mechanic."),
  MapEntry("When are escrow funds released to the attending mechanic?",
      "Funds are released when the driver verifies repair completion via PIN token or when verified GPS metrics confirm fulfillment."),
  MapEntry("How are commissions collected from spare parts marketplace sales?",
      "Spare-parts vendors pay a flat 5,000 XAF/month subscription plus a 5% commission on each transaction (95% vendor / 5% ZEMNOVA split), guaranteeing strict price parity with physical retail stores."),
  MapEntry("What happens if a client cancels a job request while the mechanic is traveling?",
      "The system evaluates transit logs; if the mechanic traveled significantly, a partial deposit allocation is awarded to cover travel expenses."),
  MapEntry("Are platform commission fees deducted from my raw parts inventory costs?",
      "Yes — a 5% commission is deducted from each parts sale (95% goes to the vendor, 5% to ZEMNOVA), in addition to the flat 5,000 XAF/month subscription."),
  MapEntry("What is the 4-digit delivery PIN token check?",
      "A secure PIN issued to the Buyer that must be entered by the seller/courier upon physical delivery to release held marketplace escrow funds."),
  MapEntry("Can a customer refuse to share their completion token?",
      "If a customer improperly holds a token, the mechanic can file a review. Platform staff evaluate on-site GPS logs to release funds."),
  MapEntry("How long do funds remain frozen if a dispute is filed?",
      "Disputed escrow funds are frozen immediately and reviewed by ZEMNOVA administrative staff within 48 business hours."),
  MapEntry("Can independent mechanics list spare parts on the marketplace?",
      "Yes, any registered professional or merchant can list verified spare parts for sale through our verification system."),
  MapEntry("How does the offline voice recording engine function?",
      "Voice recordings are compressed locally on-device and stored inside an encrypted SQLite database vault until a connection returns."),
  MapEntry("Will offline data synchronization drain my mobile internet data?",
      "No. Background sync workers compress audio assets into ultra-lightweight formats before transmission to minimize data usage."),
  MapEntry("What happens if my smartphone battery dies mid-repair before sync occurs?",
      "Unsynced transaction logs remain securely saved inside local SQLite storage and auto-sync when the device powers back up."),
  MapEntry("Can I receive automated phone recommendations while completely offline?",
      "No. An active internet connection is required to receive real-time incoming client dispatch alerts from the central server."),
  MapEntry("How long does local offline data remain cached on the device?",
      "Local cache files remain until server synchronization receives an HTTP 200 OK confirmation, after which cache files are safely purged."),
  MapEntry("Does the app work in low 2G or 3G connectivity zones?",
      "Yes, the sequence batching logic pushes numerical data first, ensuring financial balances update even on slow 2G signals."),
  MapEntry("Can I view local garage maps while offline?",
      "Yes, the app caches local terrain maps and verified provider profile cards for offline navigation."),
  MapEntry("How does the Technician Voice Forum handle offline posts?",
      "Mechanics can record troubleshooting voice notes offline; the app queues and posts them to the Forum automatically upon reconnecting."),
  MapEntry("What is the maximum size of a recorded voice note?",
      "Voice notes are capped at 30 seconds to optimize AI speech processing and minimize file size."),
  MapEntry("Can fleet managers view vehicle health logs offline?",
      "Fleet managers can view locally cached telemetry; live fleet dashboard streaming requires an active network connection."),
  MapEntry("How does the platform prevent mechanics from taking transactions offline?",
      "Off-platform repairs void the user's 7-Day Guarantee. The app also monitors background GPS telemetry to detect circumvention."),
  MapEntry("What is a professional shadow-ban penalty?",
      "If circumvention or GPS fraud is confirmed, the profile is hidden from the automated AI recommendation loop for 30 days."),
  MapEntry("How does the system handle counterfeit spare parts claims?",
      "Marketplace vendors offering substandard components face immediate store suspension and escrow refund deductions."),
  MapEntry("Can spare parts Buyers return items that do not fit?",
      "Yes. Unused components can be returned within 48 hours, provided the delivery verification PIN token has not been finalized."),
  MapEntry("How does phone number masking protect user safety?",
      "Raw phone numbers are hidden during early communications; interactions route via masked in-app VoIP or text chat to prevent harassment."),
  MapEntry("How does the Technician Voice Forum protect technical advice?",
      "A coin bounty system rewards mechanics who provide verified diagnostic answers, fostering peer-to-peer technical support."),
  MapEntry("How can corporate accounts manage multiple company vehicles?",
      "Corporate fleet profiles can track multiple vehicles under a single business dashboard with individual driver permissions."),
  MapEntry("What is the 'Certified Expert' professional profile badge?",
      "A verification shield awarded to top-rated Enterprise workshops that increases profile visibility and client conversions."),
  MapEntry("How is user location data protected under regional laws?",
      "Geolocation telemetry is encrypted under TLS 1.3 in compliance with Cameroon Cybersecurity Law No. 2010/012 and AU privacy standards."),
  MapEntry("What court holds jurisdiction over legal disputes regarding the platform?",
      "All legal disputes regarding AUTOSYNX BY ZEMNOVA fall under the exclusive jurisdiction of the competent courts in Douala and Yaoundé, Cameroon."),
];
