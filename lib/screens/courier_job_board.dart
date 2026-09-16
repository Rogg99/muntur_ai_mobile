import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/courier/data/models/courier_models.dart';
import 'package:munturai/features/courier/presentation/providers/courier_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

/// Pending, unclaimed deliveries any verified+active courier can grab.
/// Claiming is atomic server-side (409 if someone else got there first) —
/// surfaced here as a snackbar rather than a crash.
class CourierJobBoard extends ConsumerWidget {
  const CourierJobBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final deliveriesAsync = ref.watch(availableDeliveriesProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: translator.courier_available_title),
      body: deliveriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              err.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: appStyle.H5(),
            ),
          ),
        ),
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return Center(
                child: Text(translator.courier_no_jobs, style: appStyle.H5()));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(availableDeliveriesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: deliveries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _JobTile(delivery: deliveries[index]),
            ),
          );
        },
      ),
    );
  }
}

class _JobTile extends ConsumerStatefulWidget {
  const _JobTile({required this.delivery});

  final Delivery delivery;

  @override
  ConsumerState<_JobTile> createState() => _JobTileState();
}

class _JobTileState extends ConsumerState<_JobTile> {
  bool _claiming = false;

  Future<void> _claim() async {
    setState(() => _claiming = true);
    try {
      await ref.read(courierRepositoryProvider).claimDelivery(widget.delivery.id);
      ref.invalidate(availableDeliveriesProvider);
      ref.invalidate(myDeliveriesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.courier_job_claimed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
        ref.invalidate(availableDeliveriesProvider);
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
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
          if (delivery.addressText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(delivery.addressText, style: appStyle.H6(color: Colors.grey)),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _claiming ? null : _claim,
              child: Text(_claiming ? translator.courier_claiming : translator.courier_claim_job),
            ),
          ),
        ],
      ),
    );
  }
}
