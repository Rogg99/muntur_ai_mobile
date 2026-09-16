import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/courier/presentation/providers/courier_provider.dart';
import 'package:munturai/screens/courier_job_board.dart';
import 'package:munturai/screens/courier_my_deliveries.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// "Devenir livreur" account screen — registration + status. Verification
/// is admin-only (no mobile flow for that), so a freshly-registered
/// account sits at verified=false until reviewed; the job board is
/// gated on verified+active server-side, this screen just explains that.
class CourierProfileScreen extends ConsumerStatefulWidget {
  const CourierProfileScreen({super.key});

  @override
  ConsumerState<CourierProfileScreen> createState() => _CourierProfileScreenState();
}

class _CourierProfileScreenState extends ConsumerState<CourierProfileScreen> {
  bool _registering = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _registering = true;
      _error = null;
    });
    try {
      await ref.read(courierRepositoryProvider).registerAsCourier();
      ref.invalidate(myCourierProfileProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final courierAsync = ref.watch(myCourierProfileProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: translator.settings_courier),
      body: courierAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(translator.courier_status_load_error, style: appStyle.H5())),
        data: (courier) {
          if (courier == null) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 56, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    translator.courier_become_courier_pitch,
                    textAlign: TextAlign.center,
                    style: appStyle.H5(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: translator.courier_register_button,
                    loading: _registering,
                    onPressed: _register,
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  _StatusPill(
                    label: courier.verified
                        ? translator.courier_verified_label
                        : translator.courier_pending_verification_label,
                    color: courier.verified ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: courier.active
                        ? translator.courier_available_label
                        : translator.courier_unavailable_label,
                    color: courier.active ? Colors.green : Colors.grey,
                  ),
                ],
              ),
              if (!courier.verified) ...[
                const SizedBox(height: 16),
                Text(
                  translator.courier_verification_pending_notice,
                  style: appStyle.H6(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                text: translator.courier_view_available_button,
                onPressed: !courier.verified || !courier.active
                    ? null
                    : () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CourierJobBoard())),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CourierMyDeliveries())),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(translator.courier_my_deliveries_title),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
