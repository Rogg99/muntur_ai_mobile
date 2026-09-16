import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/courier/presentation/providers/courier_provider.dart';
import 'package:munturai/screens/courier_qr_reveal.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _statusLabels(AppLocalizations t) => {
  'pending': t.vendor_status_pending,
  'assigned': t.vendor_status_assigned,
  'picked_up': t.vendor_status_picked_up,
  'in_transit': t.courier_status_in_transit,
  'delivered': t.courier_status_delivered,
  'failed': t.courier_status_failed,
};

/// Vendor-side delivery status for one order, opened after "Marquer prêt".
/// Shows the pickup QR once a courier has claimed it (status 'assigned') —
/// nothing to do before that beyond waiting for the job board.
class CourierVendorDelivery extends ConsumerWidget {
  const CourierVendorDelivery({super.key, required this.deliveryId});

  final String deliveryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final deliveryAsync = ref.watch(deliveryDetailProvider(deliveryId));

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: translator.vendor_delivery_title),
      body: deliveryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(translator.vendor_delivery_load_error, style: appStyle.H5())),
        data: (delivery) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(deliveryDetailProvider(deliveryId)),
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(delivery.partTitle, style: appStyle.H4(weight: 'bold')),
                const SizedBox(height: 8),
                Text(_statusLabels(translator)[delivery.status] ?? delivery.status,
                    style: appStyle.H5(color: colorScheme.primary, weight: 'bold')),
                if (delivery.status == 'assigned') ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourierQrReveal(
                          title: translator.vendor_pickup_qr_title,
                          instructions: translator.vendor_pickup_qr_instructions,
                          fetchToken: () => ref
                              .read(courierRepositoryProvider)
                              .getPickupQrToken(deliveryId),
                        ),
                      ),
                    ),
                    child: Text(translator.vendor_show_pickup_qr_button),
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
