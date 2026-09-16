import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/screens/marketplace_order_tracking.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Redirect scheme Campay is told to bounce back to once the buyer finishes
/// (or abandons) their card payment on its hosted widget — a custom URI
/// scheme rather than a universal/app link, since it needs zero platform
/// config (no AndroidManifest intent-filter, no apple-app-site-association)
/// and is simply intercepted client-side in [NavigationDelegate]. Campay
/// never actually resolves it as a real destination; it's just the target
/// the widget's "done" step redirects to.
const String marketplacePaymentSuccessUrl = 'autosynx://payment/success';
const String marketplacePaymentFailureUrl = 'autosynx://payment/failure';

/// Hosts Campay's own hosted payment widget (MoMo/card choice, no card data
/// ever transits through us) for the pay-by-link flow. This screen never
/// decides the order's outcome itself — it only watches for the redirect
/// Campay was told to use and then hands off to [MarketplaceOrderTracking],
/// which already listens for the real `marketplace_order_updated` WS push
/// once Campay's webhook confirms things server-side.
class MarketplacePaymentWebview extends StatefulWidget {
  const MarketplacePaymentWebview({
    super.key,
    required this.orderId,
    required this.paymentLink,
  });

  final String orderId;
  final String paymentLink;

  @override
  State<MarketplacePaymentWebview> createState() =>
      _MarketplacePaymentWebviewState();
}

class _MarketplacePaymentWebviewState
    extends State<MarketplacePaymentWebview> {
  late final WebViewController _controller;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(marketplacePaymentSuccessUrl) ||
                request.url.startsWith(marketplacePaymentFailureUrl)) {
              _finishAndReturnToTracking();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentLink));
  }

  void _finishAndReturnToTracking() {
    if (_finishing || !mounted) return;
    _finishing = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MarketplaceOrderTracking(orderId: widget.orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleTxt: AppLocalizations.of(context)!.pay,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
