import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/repair/data/models/repair_models.dart';
import 'package:munturai/features/repair/presentation/providers/repair_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _repairStatusLabels(AppLocalizations l10n) => {
      'pending': l10n.repair_status_pending,
      'accepted': l10n.repair_status_accepted,
      'in_progress': l10n.repair_status_in_progress,
      'completed': l10n.repair_status_completed,
      'cancelled': l10n.repair_status_cancelled,
      'refused': l10n.repair_status_refused,
    };

/// Garage staff-side booking list with the accept/refuse/start/complete
/// actions, per c7's contract. `completed` is backend-gated on a correct
/// PIN and only confirmed once the withdraw webhook lands (never
/// optimistic) — this screen just surfaces whatever the repository raises.
class RepairGarageDashboard extends ConsumerWidget {
  const RepairGarageDashboard({super.key});

  Future<void> _accept(BuildContext context, WidgetRef ref, RepairBooking booking) =>
      _runAction(context, ref, () => ref.read(repairRepositoryProvider).acceptBooking(booking.id));

  Future<void> _refuse(BuildContext context, WidgetRef ref, RepairBooking booking) =>
      _runAction(context, ref, () => ref.read(repairRepositoryProvider).refuseBooking(booking.id));

  Future<void> _start(BuildContext context, WidgetRef ref, RepairBooking booking) =>
      _runAction(context, ref, () => ref.read(repairRepositoryProvider).startBooking(booking.id));

  Future<void> _runAction(
      BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    try {
      await action();
      ref.invalidate(garageRepairDashboardProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _completeDialog(BuildContext context, WidgetRef ref, RepairBooking booking) async {
    final l10n = AppLocalizations.of(context)!;
    final pinController = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.repair_complete_dialog_title),
        content: TextField(
          controller: pinController,
          style: AppStyle.of(ctx).H6(),
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(labelText: l10n.repair_client_pin_label),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, pinController.text.trim()),
            child: Text(l10n.marketplace_validate),
          ),
        ],
      ),
    );
    pinController.dispose();
    if (pin == null || pin.isEmpty) return;
    await _runAction(
        context, ref, () => ref.read(repairRepositoryProvider).completeBooking(booking.id, pin));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final bookingsAsync = ref.watch(garageRepairDashboardProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: l10n.repair_staff_dashboard_button),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.repair_load_error, style: appStyle.H5())),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Text(l10n.repair_dashboard_empty, style: appStyle.H5(color: Colors.grey)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(garageRepairDashboardProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking.description.isNotEmpty
                                  ? booking.description
                                  : l10n.repair_no_description,
                              style: appStyle.H6(weight: 'bold'),
                            ),
                          ),
                          Text(_repairStatusLabels(l10n)[booking.status] ?? booking.status,
                              style: appStyle.H6(color: colorScheme.primary)),
                        ],
                      ),
                      if (booking.status == 'pending') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _refuse(context, ref, booking),
                                child: Text(l10n.repair_refuse_action),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _accept(context, ref, booking),
                                child: Text(l10n.repair_accept_action),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (booking.status == 'accepted') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _start(context, ref, booking),
                                child: Text(l10n.repair_start_action),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _completeDialog(context, ref, booking),
                                child: Text(l10n.repair_complete_action),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (booking.status == 'in_progress') ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _completeDialog(context, ref, booking),
                            child: Text(l10n.repair_complete_action),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
