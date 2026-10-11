import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/repair/presentation/providers/repair_provider.dart';
import 'package:munturai/screens/repair_booking_tracking.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _repairStatusLabels(AppLocalizations l10n) => {
      'pending': l10n.repair_status_pending,
      'accepted': l10n.repair_status_accepted,
      'in_progress': l10n.repair_status_in_progress,
      'completed': l10n.repair_status_completed,
      'cancelled': l10n.repair_status_cancelled,
      'refused': l10n.repair_status_refused,
    };

/// Client's own repair-booking history — "Mes dépôts", parallel to
/// Settings' "Mes commandes" for marketplace.
class RepairMyBookings extends ConsumerWidget {
  const RepairMyBookings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final bookingsAsync = ref.watch(myRepairBookingsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: l10n.repair_my_bookings_title),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.repair_load_error, style: appStyle.H5())),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Text(l10n.repair_my_bookings_empty, style: appStyle.H5(color: Colors.grey)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myRepairBookingsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return ListTile(
                  tileColor: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  title: Text(booking.garageName, style: appStyle.H5(weight: 'bold')),
                  subtitle: Text(_repairStatusLabels(l10n)[booking.status] ?? booking.status),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RepairBookingTracking(bookingId: booking.id),
                    ),
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
