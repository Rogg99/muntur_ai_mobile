import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/collect_agent/presentation/providers/collect_agent_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Candidature "agent collecteur" : CNI recto/verso + 3 selfies (face,
/// gauche, droite), chacun uploadé séparément via le même endpoint
/// /medias/ partagé (chatbot, marketplace, profil), puis les 5 ids
/// envoyés à /collect-agents/apply/. Idempotent côté serveur
/// (update_or_create) — resoumettre après un rejet écrase l'ancienne
/// candidature et repasse en 'pending', pas d'erreur "déjà candidat".
class CollectAgentApplyScreen extends ConsumerStatefulWidget {
  const CollectAgentApplyScreen({super.key});

  @override
  ConsumerState<CollectAgentApplyScreen> createState() =>
      _CollectAgentApplyScreenState();
}

enum _Slot { cniFront, cniBack, selfieFace, selfieLeft, selfieRight }

class _CollectAgentApplyScreenState extends ConsumerState<CollectAgentApplyScreen> {
  final Map<_Slot, String> _localPaths = {};
  final Map<_Slot, String> _mediaIds = {};
  _Slot? _uploading;
  bool _submitting = false;
  String? _error;

  Future<void> _pickAndUpload(_Slot slot) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null || !mounted) return;

    setState(() {
      _uploading = slot;
      _localPaths[slot] = file.path;
      _error = null;
    });
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.name),
      });
      final response = await ApiClient().postMultipart('/medias/', form);
      final data = response.data['data'] ?? response.data;
      final mediaId = data is Map ? data['id']?.toString() : null;
      if (mediaId == null) throw Exception('no media id in response');
      if (!mounted) return;
      setState(() => _mediaIds[slot] = mediaId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localPaths.remove(slot);
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _uploading = null);
    }
  }

  bool get _allUploaded => _Slot.values.every((s) => _mediaIds.containsKey(s));

  Future<void> _submit() async {
    if (!_allUploaded) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(collectAgentRepositoryProvider).apply(
            cniFrontMediaId: _mediaIds[_Slot.cniFront]!,
            cniBackMediaId: _mediaIds[_Slot.cniBack]!,
            selfieFaceMediaId: _mediaIds[_Slot.selfieFace]!,
            selfieLeftMediaId: _mediaIds[_Slot.selfieLeft]!,
            selfieRightMediaId: _mediaIds[_Slot.selfieRight]!,
          );
      ref.invalidate(myAgentProfileProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _slotLabel(AppLocalizations l10n, _Slot slot) {
    switch (slot) {
      case _Slot.cniFront:
        return l10n.collect_agent_cni_front;
      case _Slot.cniBack:
        return l10n.collect_agent_cni_back;
      case _Slot.selfieFace:
        return l10n.collect_agent_selfie_face;
      case _Slot.selfieLeft:
        return l10n.collect_agent_selfie_left;
      case _Slot.selfieRight:
        return l10n.collect_agent_selfie_right;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: l10n.collect_agent_apply_title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.collect_agent_apply_intro, style: appStyle.H6(color: Colors.grey)),
          const SizedBox(height: 16),
          for (final slot in _Slot.values) ...[
            _CaptureRow(
              label: _slotLabel(l10n, slot),
              localPath: _localPaths[slot],
              uploaded: _mediaIds.containsKey(slot),
              uploading: _uploading == slot,
              onTap: () => _pickAndUpload(slot),
            ),
            const SizedBox(height: 10),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: appStyle.H6(color: Colors.redAccent)),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            text: l10n.collect_agent_apply_submit,
            loading: _submitting,
            onPressed: _allUploaded ? _submit : null,
          ),
        ],
      ),
    );
  }
}

class _CaptureRow extends StatelessWidget {
  const _CaptureRow({
    required this.label,
    required this.localPath,
    required this.uploaded,
    required this.uploading,
    required this.onTap,
  });

  final String label;
  final String? localPath;
  final bool uploaded;
  final bool uploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: uploading ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: uploaded ? Border.all(color: Colors.green) : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: localPath != null
                  ? Image.file(
                      File(localPath!),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: appStyle.H6(weight: 'bold'))),
            if (uploading)
              const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else if (uploaded)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              Icon(Icons.chevron_right, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
