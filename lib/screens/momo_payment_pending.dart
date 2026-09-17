import 'dart:async';

import 'package:flutter/material.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

/// Generic "waiting for a MoMo collect to confirm" screen — used by both the
/// coins-pack and subscription purchase flows (same `payment_pending` +
/// `ussd_code` shape a4's Campay consolidation gives every MoMo endpoint,
/// mirroring what marketplace checkout already does for orders). Doesn't
/// know about any specific Riverpod provider itself — [checkDone] is a
/// caller-supplied closure (usually reading/invalidating whichever provider
/// the real-time WS push already updates) so this stays reusable without
/// being typed to one feature's state.
class MomoPaymentPending extends StatefulWidget {
  const MomoPaymentPending({
    super.key,
    required this.title,
    required this.pendingMessage,
    this.ussdCode,
    required this.checkDone,
    required this.onDone,
  });

  final String title;
  final String pendingMessage;
  final String? ussdCode;

  /// Polled every 5s; return true once the payment has actually confirmed.
  final Future<bool> Function() checkDone;

  /// Called once [checkDone] returns true — typically pops this screen and
  /// shows a success message.
  final VoidCallback onDone;

  @override
  State<MomoPaymentPending> createState() => _MomoPaymentPendingState();
}

class _MomoPaymentPendingState extends State<MomoPaymentPending> {
  Timer? _poller;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _poller = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  Future<void> _poll() async {
    if (_checking || !mounted) return;
    _checking = true;
    try {
      final done = await widget.checkDone();
      if (done && mounted) {
        _poller?.cancel();
        widget.onDone();
      }
    } catch (_) {
      // keep polling — a transient network error shouldn't stop the wait
    } finally {
      _checking = false;
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: widget.title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                widget.pendingMessage,
                textAlign: TextAlign.center,
                style: appStyle.H5(weight: 'bold'),
              ),
              if (widget.ussdCode != null && widget.ussdCode!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.ussdCode!,
                    style: appStyle.H4(
                        weight: 'bold', color: colorScheme.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
