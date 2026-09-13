import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Create/edit a catalog listing. [existing] null = create.
///
/// Creating actually succeeds server-side only once the vendor's 5,000
/// XAF/month subscription is active (PartListingSerializer.create checks
/// this) — that payment flow (phase 3d) isn't wired yet, so until then this
/// screen works but the API call fails with a clear validation message.
class MarketplacePartForm extends ConsumerStatefulWidget {
  const MarketplacePartForm({super.key, this.existing});

  final PartListing? existing;

  @override
  ConsumerState<MarketplacePartForm> createState() => _MarketplacePartFormState();
}

class _MarketplacePartFormState extends ConsumerState<MarketplacePartForm> {
  late final _titleController =
      TextEditingController(text: widget.existing?.title ?? '');
  late final _descriptionController =
      TextEditingController(text: widget.existing?.description ?? '');
  late final _priceController = TextEditingController(
      text: widget.existing != null ? widget.existing!.price.toStringAsFixed(0) : '');
  late final _stockController = TextEditingController(
      text: widget.existing?.stockQuantity.toString() ?? '1');
  late final _oemController = TextEditingController();
  late final _vehicleController = TextEditingController();
  String _condition = '';
  late final List<String> _oemReferences = List.of(widget.existing?.oemReferences ?? []);
  late final List<String> _compatibleVehicles =
      List.of(widget.existing?.compatibleVehicles ?? []);

  // Existing remote photos (kept unless removed) + newly picked local files
  // (uploaded on submit). Their ids must be resent on update — PUT replaces
  // the whole `medias` M2M list, it doesn't merge.
  late final List<MediaRefItem> _existingMedia = List.of(widget.existing?.medias ?? []);
  final List<File> _newPhotos = [];
  bool _submitting = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _condition = widget.existing?.condition ?? 'used';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _oemController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() => _newPhotos.addAll(picked.map((x) => File(x.path))));
  }

  void _addOem() {
    final value = _oemController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _oemReferences.add(value);
      _oemController.clear();
    });
  }

  void _addVehicle() {
    final value = _vehicleController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _compatibleVehicles.add(value);
      _vehicleController.clear();
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());
    if (title.isEmpty || price == null || stock == null) {
      setState(() => _error = 'Vérifiez le titre, le prix et le stock.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final mediaIds = _existingMedia.map((m) => m.id).toList();
      for (final file in _newPhotos) {
        final id = await repo.uploadPartPhoto(file);
        if (id != null) mediaIds.add(id);
      }
      if (_isEditing) {
        await repo.updatePart(
          id: widget.existing!.id,
          title: title,
          description: _descriptionController.text.trim(),
          condition: _condition,
          price: price,
          stockQuantity: stock,
          oemReferences: _oemReferences,
          compatibleVehicles: _compatibleVehicles,
          mediaIds: mediaIds,
        );
      } else {
        await repo.createPart(
          title: title,
          description: _descriptionController.text.trim(),
          condition: _condition,
          price: price,
          stockQuantity: stock,
          oemReferences: _oemReferences,
          compatibleVehicles: _compatibleVehicles,
          mediaIds: mediaIds,
        );
      }
      ref.invalidate(marketplaceVendorDashboardProvider);
      if (!mounted) return;
      Navigator.of(context).pop(true);
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

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: _isEditing ? 'Modifier la pièce' : 'Nouvelle pièce'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _condition,
            decoration: const InputDecoration(labelText: 'État'),
            items: const [
              DropdownMenuItem(value: 'brand_new', child: Text('Neuf')),
              DropdownMenuItem(value: 'used', child: Text('Occasion')),
            ],
            onChanged: (v) => setState(() => _condition = v ?? 'used'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix (XAF)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Références OEM', style: appStyle.H5(weight: 'bold')),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final ref in _oemReferences)
                Chip(
                  label: Text(ref),
                  onDeleted: () => setState(() => _oemReferences.remove(ref)),
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _oemController,
                  decoration: const InputDecoration(hintText: 'Ajouter une référence OEM'),
                  onSubmitted: (_) => _addOem(),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _addOem),
            ],
          ),
          const SizedBox(height: 16),
          Text('Véhicules compatibles', style: appStyle.H5(weight: 'bold')),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final vehicle in _compatibleVehicles)
                Chip(
                  label: Text(vehicle),
                  onDeleted: () => setState(() => _compatibleVehicles.remove(vehicle)),
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _vehicleController,
                  decoration:
                      const InputDecoration(hintText: 'Ex: Toyota Corolla'),
                  onSubmitted: (_) => _addVehicle(),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _addVehicle),
            ],
          ),
          const SizedBox(height: 16),
          Text('Photos', style: appStyle.H5(weight: 'bold')),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final media in _existingMedia)
                _PhotoThumb(
                  child: Image.network(ApiClient.resolveMediaUrl(media.file),
                      width: 72, height: 72, fit: BoxFit.cover),
                  onRemove: () => setState(() => _existingMedia.remove(media)),
                ),
              for (final file in _newPhotos)
                _PhotoThumb(
                  child: Image.file(file, width: 72, height: 72, fit: BoxFit.cover),
                  onRemove: () => setState(() => _newPhotos.remove(file)),
                ),
              GestureDetector(
                onTap: _pickPhotos,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo_outlined),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: _isEditing ? 'Enregistrer' : 'Publier la pièce',
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
