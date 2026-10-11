import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/collect_agent/presentation/providers/collect_agent_provider.dart';
import 'package:munturai/screens/collect_agent_apply.dart';
import 'package:munturai/screens/collect_agent_my_submissions.dart';
import 'package:munturai/screens/collect_agent_submit_garage.dart';
import 'package:munturai/screens/collect_agent_submit_panne.dart';
import 'package:munturai/widgets/CustomAppBar.dart';
import 'package:munturai/widgets/primary_button.dart';

/// Entry point for the "agent collecteur" program: apply (no profile yet),
/// show status while pending/rejected, or give access to the two
/// submission forms + history once approved.
class CollectAgentHomeScreen extends ConsumerWidget {
  const CollectAgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(myAgentProfileProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: l10n.collect_agent_title),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.collect_agent_load_error, style: appStyle.H5())),
        data: (profile) {
          if (profile == null) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.badge_outlined, size: 56, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(l10n.collect_agent_pitch, textAlign: TextAlign.center, style: appStyle.H5()),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: l10n.collect_agent_apply_button,
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CollectAgentApplyScreen())),
                  ),
                ],
              ),
            );
          }

          if (profile.status != 'approved') {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    profile.status == 'rejected' ? Icons.cancel_outlined : Icons.hourglass_top,
                    size: 56,
                    color: profile.status == 'rejected' ? Colors.redAccent : Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.status == 'rejected'
                        ? l10n.collect_agent_rejected_notice
                        : l10n.collect_agent_pending_notice,
                    textAlign: TextAlign.center,
                    style: appStyle.H5(),
                  ),
                  if (profile.status == 'rejected' && (profile.rejectionReason ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(profile.rejectionReason!,
                        textAlign: TextAlign.center, style: appStyle.H6(color: Colors.grey)),
                  ],
                  if (profile.status == 'rejected') ...[
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: l10n.collect_agent_reapply_button,
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CollectAgentApplyScreen())),
                    ),
                  ],
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.verified, size: 56, color: Colors.green),
                const SizedBox(height: 12),
                Text(l10n.collect_agent_approved_notice,
                    textAlign: TextAlign.center, style: appStyle.H5()),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: l10n.collect_agent_submit_panne_button,
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CollectAgentSubmitPanne())),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CollectAgentSubmitGarage())),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: Text(l10n.collect_agent_submit_garage_button),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CollectAgentMySubmissions())),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: Text(l10n.collect_agent_my_submissions_title),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
