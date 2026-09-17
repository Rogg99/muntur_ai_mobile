import 'package:flutter/material.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Generic Campay-hosted-payment-widget webview: hosts [paymentLink] and
/// intercepts a redirect starting with [successUrl] or [failureUrl] (custom
/// URI schemes, same zero-platform-config approach as
/// marketplace_payment_webview.dart — Campay never actually resolves them,
/// they're just where its widget's "done" step redirects to). Doesn't
/// assume any particular next screen itself; [onFinished] decides what
/// happens once either redirect fires.
class PaymentWebview extends StatefulWidget {
  const PaymentWebview({
    super.key,
    required this.title,
    required this.paymentLink,
    required this.successUrl,
    required this.failureUrl,
    required this.onFinished,
  });

  final String title;
  final String paymentLink;
  final String successUrl;
  final String failureUrl;
  final VoidCallback onFinished;

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<PaymentWebview> {
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
            if (request.url.startsWith(widget.successUrl) ||
                request.url.startsWith(widget.failureUrl)) {
              _finish();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentLink));
  }

  void _finish() {
    if (_finishing || !mounted) return;
    _finishing = true;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleTxt: widget.title),
      body: WebViewWidget(controller: _controller),
    );
  }
}
