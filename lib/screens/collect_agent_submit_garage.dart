import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
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
  // Picked locally, uploaded to the shared /medias/ endpoint on submit;
  // same cap as the API (GarageSubmissionSerializer.medias).
  static const _maxPhotos = 10;
  final List<XFile> _photos = [];
  TimeOfDay? _opening;
  TimeOfDay? _closing;

  // API expects HH:MM (GarageSubmissionSerializer.heure_ouverture/fermeture).
  String? _hhmm(TimeOfDay? t) => t == null
      ? null
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool opening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (opening ? _opening : _closing) ??
          TimeOfDay(hour: opening ? 8 : 18, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() => opening ? _opening = picked : _closing = picked);
  }

  Widget _timeField(String label, TimeOfDay? value, bool opening) {
    final appStyle = AppStyle.of(context);
    return InkWell(
      onTap: () => _pickTime(opening),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: value == null
              ? const Icon(Icons.schedule)
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => opening ? _opening = null : _closing = null),
                ),
        ),
        child: Text(value?.format(context) ?? '', style: appStyle.H6()),
      ),
    );
  }

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

  Future<void> _pickPhotos(ImageSource source) async {
    final left = _maxPhotos - _photos.length;
    if (left <= 0) return;
    final picker = ImagePicker();
    final picked = source == ImageSource.camera
        ? [if (await picker.pickImage(source: source, imageQuality: 85) case final f?) f]
        : await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty || !mounted) return;
    setState(() => _photos.addAll(picked.take(left)));
  }

  Future<List<String>> _uploadPhotos() async {
    final ids = <String>[];
    for (final photo in _photos) {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(photo.path, filename: photo.name),
      });
      final response = await ApiClient().postMultipart('/medias/', form);
      final data = response.data['data'] ?? response.data;
      final id = data is Map ? data['id']?.toString() : null;
      if (id == null) throw Exception('no media id in response');
      ids.add(id);
    }
    return ids;
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
      final mediaIds = await _uploadPhotos();
      await ref.read(collectAgentRepositoryProvider).submitGarage(
            nom: nom,
            telephone1: telephone1,
            latitude: _latitude!,
            longitude: _longitude!,
            description: _descriptionController.text.trim(),
            email: _emailController.text.trim(),
            telephone2: _telephone2Controller.text.trim(),
            ville: _villeController.text.trim(),
            heureOuverture: _hhmm(_opening),
            heureFermeture: _hhmm(_closing),
            // submission_* records where the agent stood when reporting it
            // — same coordinates, distinct field from the garage's own
            // latitude/longitude on the backend model.
            submissionLatitude: _latitude,
            submissionLongitude: _longitude,
            mediaIds: mediaIds,
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
          Row(
            children: [
              Expanded(child: _timeField(l10n.collect_agent_garage_opening_label, _opening, true)),
              const SizedBox(width: 12),
              Expanded(child: _timeField(l10n.collect_agent_garage_closing_label, _closing, false)),
            ],
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
          const SizedBox(height: 16),
          Text('${l10n.marketplace_photos_label} (${_photos.length}/$_maxPhotos)',
              style: appStyle.H5(weight: 'bold')),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final photo in _photos)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(photo.path), width: 72, height: 72, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.remove(photo)),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_photos.length < _maxPhotos) ...[
                _AddPhotoTile(icon: Icons.photo_camera_outlined, onTap: () => _pickPhotos(ImageSource.camera)),
                _AddPhotoTile(icon: Icons.add_photo_alternate_outlined, onTap: () => _pickPhotos(ImageSource.gallery)),
              ],
            ],
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

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon),
      ),
    );
  }
}
