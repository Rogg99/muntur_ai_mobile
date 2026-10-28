import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/repair/presentation/providers/repair_provider.dart';
import 'package:munturai/screens/tracking_live_screen.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _repairStatusLabels(AppLocalizations l10n) => {
      'pending': l10n.repair_status_pending,
      'accepted': l10n.repair_status_accepted,
      'in_progress': l10n.repair_status_in_progress,
      'completed': l10n.repair_status_completed,
      'cancelled': l10n.repair_status_cancelled,
      'refused': l10n.repair_status_refused,
    };

const List<String> _terminalRepairStatuses = ['completed', 'cancelled', 'refused'];

/// Client-side booking tracking: status, the completion PIN once accepted
/// (never shown to the garage side, per the backend contract), and the
/// cancel/no-show actions while eligible. Polls every 5s while the status
/// can still change server-side (garage response + Campay webhooks both
/// land asynchronously, no push for this yet).
class RepairBookingTracking extends ConsumerStatefulWidget {
  const RepairBookingTracking({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<RepairBookingTracking> createState() => _RepairBookingTrackingState();
}

class _RepairBookingTrackingState extends ConsumerState<RepairBookingTracking> {
  Timer? _poller;
  bool _acting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _poller = Timer.periodic(const Duration(seconds: 5), (_) {
      final current = ref.read(repairBookingDetailProvider(widget.bookingId)).valueOrNull;
      if (current != null && _terminalRepairStatuses.contains(current.status)) {
        _poller?.cancel();
        return;
      }
      ref.invalidate(repairBookingDetailProvider(widget.bookingId));
    });
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.repair_cancel_confirm_title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.repair_cancel_action)),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(() => ref.read(repairRepositoryProvider).cancelBooking(widget.bookingId));
  }

  Future<void> _reportNoShow() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.repair_no_show_confirm_title),
        content: Text(l10n.repair_no_show_confirm_body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.repair_no_show_action)),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(() => ref.read(repairRepositoryProvider).reportNoShow(widget.bookingId));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      _acting = true;
      _error = null;
    });
    try {
      await action();
      ref.invalidate(repairBookingDetailProvider(widget.bookingId));
      if (mounted) setState(() => _acting = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _acting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final bookingAsync = ref.watch(repairBookingDetailProvider(widget.bookingId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: l10n.repair_tracking_title),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.repair_load_error, style: appStyle.H5())),
        data: (booking) {
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(repairBookingDetailProvider(widget.bookingId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(booking.garageName, style: appStyle.H4(weight: 'bold')),
                if (booking.garageVille.isNotEmpty)
                  Text(booking.garageVille, style: appStyle.H6(color: Colors.grey)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _repairStatusLabels(l10n)[booking.status] ?? booking.status,
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                if (booking.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(booking.description, style: appStyle.H6()),
                ],
                // on_site visit: the mechanic's trip to the client (Doc/17).
                if (booking.trackingMissionId != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: Text(l10n.tracking_follow_live),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48)),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackingLiveScreen(
                            missionId: booking.trackingMissionId!),
                      ),
                    ),
                  ),
                ],
                if (booking.completionPinReveal != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.primary),
                    ),
                    child: Column(
                      children: [
                        Text(l10n.repair_completion_code_title,
                            style: appStyle.H5(weight: 'bold')),
                        const SizedBox(height: 8),
                        Text(
                          booking.completionPinReveal!,
                          style: appStyle.H2(weight: 'bold', color: colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.repair_completion_code_warning,
                          textAlign: TextAlign.center,
                          style: appStyle.H6(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
                ],
                if (booking.status == 'pending') ...[
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _acting ? null : _cancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(l10n.repair_cancel_action),
                  ),
                ],
                if (booking.status == 'accepted') ...[
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _acting ? null : _reportNoShow,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(l10n.repair_no_show_action),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
