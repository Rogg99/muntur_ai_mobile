import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/courier/presentation/providers/courier_provider.dart';
import 'package:munturai/screens/courier_job_board.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final courierAsync = ref.watch(myCourierProfileProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(titleTxt: 'Livreur'),
      body: courierAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Impossible de charger votre statut.', style: appStyle.H5())),
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
                    "Devenez livreur pour AUTOSYNX et récupérez des courses de livraison de pièces détachées.",
                    textAlign: TextAlign.center,
                    style: appStyle.H5(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: "S'inscrire comme livreur",
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
                    label: courier.verified ? 'Vérifié' : 'En attente de vérification',
                    color: courier.verified ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: courier.active ? 'Disponible' : 'Indisponible',
                    color: courier.active ? Colors.green : Colors.grey,
                  ),
                ],
              ),
              if (!courier.verified) ...[
                const SizedBox(height: 16),
                Text(
                  "Votre compte est en cours de vérification par notre équipe. Vous pourrez accepter des courses une fois validé.",
                  style: appStyle.H6(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Voir les courses disponibles',
                onPressed: !courier.verified || !courier.active
                    ? null
                    : () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CourierJobBoard())),
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
