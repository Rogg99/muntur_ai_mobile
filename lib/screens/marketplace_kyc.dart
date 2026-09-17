import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/marketplace/data/models/marketplace_models.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Vendor identity verification (a4 commit d681ba7): upload CNI front/back
/// (required) plus an optional business registration document, submitted
/// together to POST /marketplace/vendors/submit-kyc/. Selling is blocked
/// server-side until kyc_status reaches 'approved' — this screen shows the
/// current status (pending/approved/rejected+reason) and, unless already
/// approved, the upload form (doubling as the re-submission flow after a
/// rejection — submit-kyc/ resets to pending and clears the old reason
/// either way, so there's no separate "resubmit" endpoint to call).
class MarketplaceKyc extends ConsumerStatefulWidget {
  const MarketplaceKyc({super.key, required this.vendor});

  final VendorProfile vendor;

  @override
  ConsumerState<MarketplaceKyc> createState() => _MarketplaceKycState();
}

class _MarketplaceKycState extends ConsumerState<MarketplaceKyc> {
  File? _idFront;
  File? _idBack;
  File? _businessRegistration;
  bool _submitting = false;
  String? _error;

  Future<void> _pick(void Function(File) onPicked) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked != null) onPicked(File(picked.path));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_idFront == null || _idBack == null) {
      setState(() => _error = l10n.kyc_missing_documents_error);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final idFrontId = await repo.uploadKycDocument(_idFront!);
      final idBackId = await repo.uploadKycDocument(_idBack!);
      String? businessRegId;
      if (_businessRegistration != null) {
        businessRegId = await repo.uploadKycDocument(_businessRegistration!);
      }
      if (idFrontId == null || idBackId == null) {
        throw Exception(l10n.kyc_upload_failed_error);
      }
      await repo.submitKyc(
        idFrontMediaId: idFrontId,
        idBackMediaId: idBackId,
        businessRegistrationMediaId: businessRegId,
      );
      ref.invalidate(marketplaceVendorDashboardProvider);
      ref.invalidate(marketplaceMyVendorProvider);
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
    final l10n = AppLocalizations.of(context)!;
    final status = widget.vendor.kycStatus;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(titleTxt: l10n.kyc_screen_title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _KycStatusBanner(status: status, reason: widget.vendor.kycRejectionReason),
          if (status != 'approved') ...[
            const SizedBox(height: 24),
            Text(l10n.kyc_id_front_label, style: appStyle.H5(weight: 'bold')),
            const SizedBox(height: 8),
            _DocumentPicker(
              file: _idFront,
              onTap: () => _pick((f) => setState(() => _idFront = f)),
            ),
            const SizedBox(height: 20),
            Text(l10n.kyc_id_back_label, style: appStyle.H5(weight: 'bold')),
            const SizedBox(height: 8),
            _DocumentPicker(
              file: _idBack,
              onTap: () => _pick((f) => setState(() => _idBack = f)),
            ),
            const SizedBox(height: 20),
            Text(l10n.kyc_business_registration_label,
                style: appStyle.H5(weight: 'bold')),
            const SizedBox(height: 4),
            Text(l10n.kyc_optional_hint,
                style: appStyle.H6(color: Colors.grey)),
            const SizedBox(height: 8),
            _DocumentPicker(
              file: _businessRegistration,
              onTap: () =>
                  _pick((f) => setState(() => _businessRegistration = f)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              text: status == 'rejected'
                  ? l10n.kyc_resubmit_button
                  : l10n.kyc_submit_button,
              loading: _submitting,
              onPressed: _submit,
            ),
          ],
        ],
      ),
    );
  }
}

class _KycStatusBanner extends StatelessWidget {
  const _KycStatusBanner({required this.status, this.reason});

  final String status;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final l10n = AppLocalizations.of(context)!;

    final (Color color, IconData icon, String label) = switch (status) {
      'approved' => (Colors.green, Icons.verified, l10n.kyc_status_approved),
      'rejected' => (Colors.redAccent, Icons.error_outline, l10n.kyc_status_rejected),
      _ => (Colors.orange, Icons.hourglass_top, l10n.kyc_status_pending),
    };

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
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(label, style: appStyle.H5(weight: 'bold', color: color)),
            ],
          ),
          if (status == 'rejected' && reason != null && reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(reason!, style: appStyle.H6()),
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
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(file!, fit: BoxFit.cover),
              )
            : Icon(Icons.camera_alt_outlined,
                size: 32, color: colorScheme.onSurface.withValues(alpha: 0.4)),
      ),
    );
  }
}
