import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/collect_agent/presentation/providers/collect_agent_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Best-effort current position — never blocks the caller, same pattern
/// used elsewhere in the app (chat's ask-question, maps.dart) for a
/// "nice to have" GPS field rather than a hard requirement.
Future<Position?> getBestEffortPosition() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition();
  } catch (_) {
    return null;
  }
}

/// Field-agent submission of a breakdown case encountered in the field —
/// reviewed by staff, optionally promoted into a real case (promoted_case
/// on the read serializer, not actionable from mobile).
class CollectAgentSubmitPanne extends ConsumerStatefulWidget {
  const CollectAgentSubmitPanne({super.key});

  @override
  ConsumerState<CollectAgentSubmitPanne> createState() => _CollectAgentSubmitPanneState();
}

class _CollectAgentSubmitPanneState extends ConsumerState<CollectAgentSubmitPanne> {
  final _vehicleController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reparationController = TextEditingController();
  final _villeController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _vehicleController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _reparationController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() => _error = l10n.register_error_required);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final position = await getBestEffortPosition();
    try {
      await ref.read(collectAgentRepositoryProvider).submitPanneCase(
            description: description,
            vehicle: _vehicleController.text.trim(),
            type: _typeController.text.trim(),
            reparation: _reparationController.text.trim(),
            ville: _villeController.text.trim(),
            submissionLatitude: position?.latitude,
            submissionLongitude: position?.longitude,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.collect_agent_submission_sent)));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: l10n.collect_agent_submit_panne_button),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.repair_description_label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vehicleController,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.collect_agent_vehicle_label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _typeController,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.collect_agent_type_label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reparationController,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.collect_agent_reparation_label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _villeController,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.collect_agent_ville_label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            text: l10n.collect_agent_submission_submit,
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
