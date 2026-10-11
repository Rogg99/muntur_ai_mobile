import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/collect_agent/presentation/providers/collect_agent_provider.dart';
import 'package:munturai/screens/collect_agent_submit_panne.dart' show getBestEffortPosition;
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Field-agent submission of a new garage found in the field — same shape
/// as the existing GarageEntity fields (nom/description/contact/hours),
/// reviewed by staff, optionally promoted into a real Garage.
class CollectAgentSubmitGarage extends ConsumerStatefulWidget {
  const CollectAgentSubmitGarage({super.key});

  @override
  ConsumerState<CollectAgentSubmitGarage> createState() =>
      _CollectAgentSubmitGarageState();
}

class _CollectAgentSubmitGarageState extends ConsumerState<CollectAgentSubmitGarage> {
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephone1Controller = TextEditingController();
  final _telephone2Controller = TextEditingController();
  final _villeController = TextEditingController();
  bool _submitting = false;
  String? _error;
  double? _latitude;
  double? _longitude;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  Future<void> _captureLocation() async {
    setState(() => _locating = true);
    final position = await getBestEffortPosition();
    if (!mounted) return;
    setState(() {
      _latitude = position?.latitude;
      _longitude = position?.longitude;
      _locating = false;
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _telephone1Controller.dispose();
    _telephone2Controller.dispose();
    _villeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final nom = _nomController.text.trim();
    final telephone1 = _telephone1Controller.text.trim();
    if (nom.isEmpty || telephone1.isEmpty || _latitude == null || _longitude == null) {
      setState(() => _error = l10n.collect_agent_garage_missing_fields);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(collectAgentRepositoryProvider).submitGarage(
            nom: nom,
            telephone1: telephone1,
            latitude: _latitude!,
            longitude: _longitude!,
            description: _descriptionController.text.trim(),
            email: _emailController.text.trim(),
            telephone2: _telephone2Controller.text.trim(),
            ville: _villeController.text.trim(),
            // submission_* records where the agent stood when reporting it
            // — same coordinates, distinct field from the garage's own
            // latitude/longitude on the backend model.
            submissionLatitude: _latitude,
            submissionLongitude: _longitude,
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
      appBar: CustomAppBar(titleTxt: l10n.collect_agent_submit_garage_button),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(Icons.location_on,
                  size: 18,
                  color: _latitude != null ? Colors.green : Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _locating
                      ? l10n.collect_agent_locating
                      : (_latitude != null
                          ? l10n.collect_agent_location_captured
                          : l10n.collect_agent_location_missing),
                  style: appStyle.H6(color: Colors.grey),
                ),
              ),
              if (!_locating)
                TextButton(onPressed: _captureLocation, child: Text(l10n.repair_start_action)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nomController,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.collect_agent_garage_name_label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telephone1Controller,
            keyboardType: TextInputType.phone,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.collect_agent_garage_phone1_label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telephone2Controller,
            keyboardType: TextInputType.phone,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.collect_agent_garage_phone2_label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.collect_agent_garage_email_label,
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
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: appStyle.H6(),
            decoration: InputDecoration(
              labelText: l10n.repair_description_label,
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
