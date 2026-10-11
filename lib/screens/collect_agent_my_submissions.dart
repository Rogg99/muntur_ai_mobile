import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/collect_agent/presentation/providers/collect_agent_provider.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _statusLabels(AppLocalizations l10n) => {
      'pending': l10n.collect_agent_status_pending,
      'approved': l10n.collect_agent_status_approved,
      'rejected': l10n.collect_agent_status_rejected,
    };

Color _statusColor(String status) {
  switch (status) {
    case 'approved':
      return Colors.green;
    case 'rejected':
      return Colors.redAccent;
    default:
      return Colors.orange;
  }
}

/// History of the agent's own submissions (both kinds, per
/// GET /collect-agents/my-submissions/) with status + rejection reason.
class CollectAgentMySubmissions extends ConsumerWidget {
  const CollectAgentMySubmissions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final submissionsAsync = ref.watch(mySubmissionsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(titleTxt: l10n.collect_agent_my_submissions_title),
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(l10n.collect_agent_load_error, style: appStyle.H5())),
        data: (submissions) {
          if (submissions == null ||
              (submissions.panneCases.isEmpty && submissions.garages.isEmpty)) {
            return Center(
              child: Text(l10n.collect_agent_my_submissions_empty,
                  style: appStyle.H5(color: Colors.grey)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mySubmissionsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (submissions.panneCases.isNotEmpty) ...[
                  Text(l10n.collect_agent_panne_cases_section, style: appStyle.H5(weight: 'bold')),
                  const SizedBox(height: 8),
                  for (final panne in submissions.panneCases) ...[
                    _SubmissionCard(
                      title: panne.description,
                      status: panne.status,
                      rejectionReason: panne.rejectionReason,
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),
                ],
                if (submissions.garages.isNotEmpty) ...[
                  Text(l10n.collect_agent_garages_section, style: appStyle.H5(weight: 'bold')),
                  const SizedBox(height: 8),
                  for (final garage in submissions.garages) ...[
                    _SubmissionCard(
                      title: garage.nom,
                      status: garage.status,
                      rejectionReason: garage.rejectionReason,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.title,
    required this.status,
    this.rejectionReason,
  });

  final String title;
  final String status;
  final String? rejectionReason;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.isNotEmpty ? title : l10n.repair_no_description,
                  style: appStyle.H6(weight: 'bold'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabels(l10n)[status] ?? status,
                  style: TextStyle(
                      color: _statusColor(status), fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          if (status == 'rejected' && (rejectionReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(rejectionReason!, style: appStyle.H6(color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
