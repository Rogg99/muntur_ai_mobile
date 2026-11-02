import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/garages/domain/entities/garage_entity.dart';
import 'package:munturai/features/garages/presentation/providers/garage_provider.dart';
import 'package:munturai/features/repair/data/models/repair_models.dart';
import 'package:munturai/features/repair/presentation/providers/repair_provider.dart';
import 'package:munturai/screens/abonnement.dart';
import 'package:munturai/screens/repair_garage_dashboard.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// "Personnel garage" account screen. Steps, driven by /repair-garages/me/:
///   1. register (pick the garage + payout MoMo number) → KYC 'pending'
///   2. send the KYC documents (ID front/back, photo in front of the garage,
///      optional patente) — also the re-submission path after a rejection
///   3. wait for staff review
///   4. approved → pay the Pro plan (the garage "patente"): opened right away
///   5. approved + paid → booking dashboard
class RepairGarageStaffScreen extends ConsumerStatefulWidget {
  const RepairGarageStaffScreen({super.key});

  @override
  ConsumerState<RepairGarageStaffScreen> createState() =>
      _RepairGarageStaffScreenState();
}

class _RepairGarageStaffScreenState
    extends ConsumerState<RepairGarageStaffScreen> {
  // Opens the Pro plans once per visit when the KYC was just approved.
  bool _sentToPlans = false;

  Future<void> _openProPlans() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const SubscriptionsScreen(planType: 'Pro')),
    );
    ref.invalidate(myGarageStaffProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final staffAsync = ref.watch(myGarageStaffProfileProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: l10n.repair_staff_title),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.repair_load_error, style: appStyle.H5())),
        data: (staff) {
          if (staff == null) return const _RegisterForm();
          if (staff.kycStatus == 'rejected' ||
              (staff.kycStatus == 'pending' && staff.kycSubmittedAt == null)) {
            return _KycForm(staff: staff);
          }
          if (staff.kycStatus == 'pending') {
            return _StatusView(
              icon: Icons.hourglass_top,
              color: Colors.orange,
              title: l10n.kyc_status_pending,
              text: l10n.garage_kyc_waiting,
              garageName: staff.garageName,
            );
          }
          if (!staff.subscriptionActive) {
            if (!_sentToPlans) {
              _sentToPlans = true;
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => mounted ? _openProPlans() : null);
            }
            return _StatusView(
              icon: Icons.workspace_premium_outlined,
              color: colorScheme.primary,
              title: l10n.garage_pro_required_title,
              text: l10n.garage_pro_required_text,
              garageName: staff.garageName,
              action: PrimaryButton(
                text: l10n.garage_pro_required_button,
                onPressed: _openProPlans,
              ),
            );
          }
          return _StatusView(
            icon: Icons.check_circle,
            color: Colors.green,
            title: l10n.kyc_status_approved,
            garageName: staff.garageName,
            action: PrimaryButton(
              text: l10n.repair_staff_dashboard_button,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RepairGarageDashboard()),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.color,
    required this.title,
    required this.garageName,
    this.text,
    this.action,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String garageName;
  final String? text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: color),
          const SizedBox(height: 12),
          Text(garageName,
              style: appStyle.H4(weight: 'bold'), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(title,
              style: appStyle.H5(weight: 'bold', color: color),
              textAlign: TextAlign.center),
          if (text != null) ...[
            const SizedBox(height: 10),
            Text(text!, style: appStyle.H5(), textAlign: TextAlign.center),
          ],
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }
}

// ─────────────────────────── step 1: registration ───────────────────────────

class _RegisterForm extends ConsumerStatefulWidget {
  const _RegisterForm();

  @override
  ConsumerState<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  GarageEntity? _selectedGarage;
  final _phoneController = TextEditingController();
  bool _registering = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickGarage() async {
    final picked = await showDialog<GarageEntity>(
      context: context,
      builder: (_) => const _GaragePickerDialog(),
    );
    if (picked != null) setState(() => _selectedGarage = picked);
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    final garage = _selectedGarage;
    final phone = _phoneController.text.trim();
    if (garage == null || phone.isEmpty) {
      setState(() => _error = l10n.repair_staff_missing_fields);
      return;
    }
    setState(() {
      _registering = true;
      _error = null;
    });
    try {
      await ref.read(repairRepositoryProvider).registerAsGarageStaff(
            relatedGarageId: garage.id,
            payoutPhoneNumber: phone,
          );
      ref.invalidate(myGarageStaffProfileProvider);
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
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(Icons.build_circle_outlined, size: 56, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text(l10n.repair_staff_pitch,
            textAlign: TextAlign.center, style: appStyle.H5()),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: _pickGarage,
          child: Text(_selectedGarage?.nom ?? l10n.repair_staff_pick_garage),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: appStyle.H6(),
          decoration: InputDecoration(
            labelText: l10n.repair_staff_payout_phone_label,
            hintText: '2376XXXXXXXX',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          text: l10n.repair_staff_register_button,
          loading: _registering,
          onPressed: _register,
        ),
      ],
    );
  }
}

// ───────────────────────────── step 2: KYC documents ─────────────────────────

class _KycForm extends ConsumerStatefulWidget {
  const _KycForm({required this.staff});

  final GarageStaffProfile staff;

  @override
  ConsumerState<_KycForm> createState() => _KycFormState();
}

class _KycFormState extends ConsumerState<_KycForm> {
  File? _idFront;
  File? _idBack;
  File? _storefront;
  File? _patente;
  bool _submitting = false;
  String? _error;

  Future<void> _pick(void Function(File) onPicked) async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) setState(() => onPicked(File(picked.path)));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_idFront == null || _idBack == null || _storefront == null) {
      setState(() => _error = l10n.garage_kyc_missing_documents_error);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(repairRepositoryProvider);
      final idFront = await repo.uploadKycDocument(_idFront!);
      final idBack = await repo.uploadKycDocument(_idBack!);
      final storefront = await repo.uploadKycDocument(_storefront!);
      final patente =
          _patente == null ? null : await repo.uploadKycDocument(_patente!);
      await repo.submitGarageKyc(
        idFrontMediaId: idFront,
        idBackMediaId: idBack,
        storefrontMediaId: storefront,
        businessRegistrationMediaId: patente,
      );
      ref.invalidate(myGarageStaffProfileProvider);
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
    final l10n = AppLocalizations.of(context)!;
    final rejected = widget.staff.kycStatus == 'rejected';

    Widget doc(String label, File? file, void Function(File) onPicked,
            {bool optional = false}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: appStyle.H5(weight: 'bold')),
              if (optional)
                Text(l10n.kyc_optional_hint,
                    style: appStyle.H6(color: Colors.grey)),
              const SizedBox(height: 8),
              _DocumentPicker(file: file, onTap: () => _pick(onPicked)),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(widget.staff.garageName, style: appStyle.H4(weight: 'bold')),
        const SizedBox(height: 8),
        if (rejected)
          _Banner(
            color: Colors.redAccent,
            icon: Icons.error_outline,
            title: l10n.kyc_status_rejected,
            text: widget.staff.kycRejectionReason,
          )
        else
          Text(l10n.garage_kyc_intro, style: appStyle.H5()),
        const SizedBox(height: 20),
        doc(l10n.kyc_id_front_label, _idFront, (f) => _idFront = f),
        doc(l10n.kyc_id_back_label, _idBack, (f) => _idBack = f),
        doc(l10n.garage_kyc_storefront_label, _storefront,
            (f) => _storefront = f),
        doc(l10n.garage_kyc_patente_label, _patente, (f) => _patente = f,
            optional: true),
        if (_error != null) ...[
          Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          const SizedBox(height: 12),
        ],
        PrimaryButton(
          text: rejected ? l10n.kyc_resubmit_button : l10n.kyc_submit_button,
          loading: _submitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner(
      {required this.color,
      required this.icon,
      required this.title,
      this.text = ''});

  final Color color;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title, style: appStyle.H5(weight: 'bold', color: color)),
          ]),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(text, style: appStyle.H6()),
          ],
        ],
      ),
    );
  }
}

class _DocumentPicker extends StatelessWidget {
  const _DocumentPicker({required this.file, required this.onTap});

  final File? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(file!, fit: BoxFit.cover),
              )
            : Icon(Icons.camera_alt_outlined,
                size: 32,
                color: colorScheme.onSurface.withValues(alpha: 0.4)),
      ),
    );
  }
}

class _GaragePickerDialog extends ConsumerStatefulWidget {
  const _GaragePickerDialog();

  @override
  ConsumerState<_GaragePickerDialog> createState() =>
      _GaragePickerDialogState();
}

class _GaragePickerDialogState extends ConsumerState<_GaragePickerDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resultsAsync = ref.watch(garageSearchProvider);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                  hintText: l10n.repair_staff_search_garage_hint),
              onChanged: (value) =>
                  ref.read(garageSearchProvider.notifier).search(value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              width: double.maxFinite,
              child: resultsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
                data: (results) => ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final garage = results[index];
                    return ListTile(
                      title: Text(garage.nom),
                      subtitle: Text(garage.ville),
                      onTap: () => Navigator.pop(context, garage),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
