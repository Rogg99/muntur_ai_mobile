import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/courier/presentation/providers/courier_provider.dart';
import 'package:munturai/screens/courier_qr_reveal.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

const Map<String, String> _statusLabels = {
  'pending': 'En attente d\'un livreur',
  'assigned': 'Livreur assigné — prêt pour le retrait',
  'picked_up': 'Récupérée par le livreur',
  'in_transit': 'En route',
  'delivered': 'Livrée',
  'failed': 'Échouée',
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
    final colorScheme = Theme.of(context).colorScheme;
    final deliveryAsync = ref.watch(deliveryDetailProvider(deliveryId));

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(titleTxt: 'Livraison'),
      body: deliveryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Impossible de charger la livraison.', style: appStyle.H5())),
        data: (delivery) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(deliveryDetailProvider(deliveryId)),
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(delivery.partTitle, style: appStyle.H4(weight: 'bold')),
                const SizedBox(height: 8),
                Text(_statusLabels[delivery.status] ?? delivery.status,
                    style: appStyle.H5(color: colorScheme.primary, weight: 'bold')),
                if (delivery.status == 'assigned') ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourierQrReveal(
                          title: 'QR de retrait',
                          instructions:
                              'Montrez ce QR au livreur pour confirmer qu\'il récupère bien la pièce.',
                          fetchToken: () => ref
                              .read(courierRepositoryProvider)
                              .getPickupQrToken(deliveryId),
                        ),
                      ),
                    ),
                    child: const Text('Afficher le QR de retrait'),
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
