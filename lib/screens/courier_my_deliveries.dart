import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/courier/data/models/courier_models.dart';
import 'package:munturai/features/courier/presentation/providers/courier_provider.dart';
import 'package:munturai/screens/courier_qr_reveal.dart';
import 'package:munturai/screens/courier_qr_scan.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _statusLabels(AppLocalizations t) => {
  'pending': t.courier_status_pending,
  'assigned': t.courier_status_assigned,
  'picked_up': t.courier_status_picked_up,
  'in_transit': t.courier_status_in_transit,
  'delivered': t.courier_status_delivered,
  'failed': t.courier_status_failed,
};

/// Courier's own deliveries (claimed job-board rows) — same
/// /marketplace/deliveries/ list a vendor sees their own orders' deliveries
/// on, server-side scoped to whichever role this account has.
class CourierMyDeliveries extends ConsumerWidget {
  const CourierMyDeliveries({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final deliveriesAsync = ref.watch(myDeliveriesProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: translator.courier_my_deliveries_title),
      body: deliveriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(translator.courier_load_error, style: appStyle.H5())),
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return Center(child: Text(translator.courier_no_claimed, style: appStyle.H5()));
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
    final translator = AppLocalizations.of(context)!;
    final token = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CourierQrScan(
          title: translator.courier_scan_vendor_title,
          instructions: translator.courier_scan_vendor_instructions,
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
    final translator = AppLocalizations.of(context)!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourierQrReveal(
          title: translator.courier_dropoff_qr_title,
          instructions: translator.courier_dropoff_qr_instructions,
          fetchToken: () =>
              ref.read(courierRepositoryProvider).getDropoffQrToken(widget.delivery.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
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
          Text(_statusLabels(translator)[delivery.status] ?? delivery.status,
              style: appStyle.H6(color: colorScheme.primary, weight: 'bold')),
          if (delivery.status == 'assigned' || delivery.status == 'picked_up') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (delivery.status == 'assigned')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _scanForPickup,
                      child: Text(translator.courier_scan_pickup_button),
                    ),
                  ),
                if (delivery.status == 'picked_up') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _startTransit,
                      child: Text(translator.courier_start_transit_button),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _showDropoffQr,
                      child: Text(translator.courier_dropoff_qr_button),
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
                child: Text(translator.courier_show_dropoff_qr_button),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
