import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/courier/data/models/courier_models.dart';
import 'package:munturai/features/courier/presentation/providers/courier_provider.dart';
import 'package:munturai/screens/courier_qr_reveal.dart';
import 'package:munturai/screens/courier_qr_scan.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

const Map<String, String> _statusLabels = {
  'pending': 'En attente',
  'assigned': 'Réclamée — à récupérer',
  'picked_up': 'Récupérée',
  'in_transit': 'En route',
  'delivered': 'Livrée',
  'failed': 'Échouée',
};

/// Courier's own deliveries (claimed job-board rows) — same
/// /marketplace/deliveries/ list a vendor sees their own orders' deliveries
/// on, server-side scoped to whichever role this account has.
class CourierMyDeliveries extends ConsumerWidget {
  const CourierMyDeliveries({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final deliveriesAsync = ref.watch(myDeliveriesProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(titleTxt: 'Mes courses'),
      body: deliveriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Impossible de charger vos courses.', style: appStyle.H5())),
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return Center(child: Text('Aucune course réclamée.', style: appStyle.H5()));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myDeliveriesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: deliveries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _DeliveryTile(delivery: deliveries[index]),
            ),
          );
        },
      ),
    );
  }
}

class _DeliveryTile extends ConsumerStatefulWidget {
  const _DeliveryTile({required this.delivery});

  final Delivery delivery;

  @override
  ConsumerState<_DeliveryTile> createState() => _DeliveryTileState();
}

class _DeliveryTileState extends ConsumerState<_DeliveryTile> {
  bool _busy = false;

  Future<void> _scanForPickup() async {
    final token = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const CourierQrScan(
          title: 'Scanner le QR du vendeur',
          instructions: 'Scannez le QR affiché par le vendeur pour confirmer la récupération.',
        ),
      ),
    );
    if (token == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(courierRepositoryProvider)
          .confirmPickup(widget.delivery.id, token);
      ref.invalidate(myDeliveriesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startTransit() async {
    setState(() => _busy = true);
    try {
      await ref.read(courierRepositoryProvider).startTransit(widget.delivery.id);
      ref.invalidate(myDeliveriesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showDropoffQr() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourierQrReveal(
          title: 'QR de remise',
          instructions: "Montrez ce QR à l'acheteur pour confirmer la livraison.",
          fetchToken: () =>
              ref.read(courierRepositoryProvider).getDropoffQrToken(widget.delivery.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final delivery = widget.delivery;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(delivery.partTitle, style: appStyle.H5(weight: 'bold')),
          const SizedBox(height: 4),
          Text(
            '${delivery.vendorShopName}${delivery.vendorVille.isNotEmpty ? ' · ${delivery.vendorVille}' : ''}',
            style: appStyle.H6(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(_statusLabels[delivery.status] ?? delivery.status,
              style: appStyle.H6(color: colorScheme.primary, weight: 'bold')),
          if (delivery.status == 'assigned' || delivery.status == 'picked_up') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (delivery.status == 'assigned')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _scanForPickup,
                      child: const Text('Scanner (retrait)'),
                    ),
                  ),
                if (delivery.status == 'picked_up') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _startTransit,
                      child: const Text('En route'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _showDropoffQr,
                      child: const Text('QR remise'),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (delivery.status == 'in_transit') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : _showDropoffQr,
                child: const Text('Afficher le QR de remise'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
