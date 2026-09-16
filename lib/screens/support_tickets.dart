import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/support/data/models/support_models.dart';
import 'package:munturai/features/support/presentation/providers/support_provider.dart';
import 'package:munturai/screens/support_ticket_new.dart';
import 'package:munturai/screens/support_ticket_thread.dart';
import 'package:munturai/widgets/CustomAppBar.dart';

Map<String, String> _statusLabels(AppLocalizations t) => {
  'open': t.support_status_open,
  'in_progress': t.support_status_in_progress,
  'resolved': t.support_status_resolved,
  'closed': t.support_status_closed,
};

const Map<String, Color> _statusColors = {
  'open': Colors.orange,
  'in_progress': Colors.blue,
  'resolved': Colors.green,
  'closed': Colors.grey,
};

/// "Contacter l'assistance" — ticket history. Standalone entry point (from
/// Settings) and also where escalate_human's new ticket lands afterward.
class SupportTickets extends ConsumerWidget {
  const SupportTickets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ticketsAsync = ref.watch(supportTicketsProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(titleTxt: translator.support_tickets_title),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SupportTicketNew())),
        icon: const Icon(Icons.add),
        label: Text(translator.support_new_ticket),
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(translator.support_load_error, style: appStyle.H5())),
        data: (tickets) {
          if (tickets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  translator.support_no_tickets,
                  textAlign: TextAlign.center,
                  style: appStyle.H5(),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(supportTicketsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _TicketTile(ticket: tickets[index]),
            ),
          );
        },
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColors[ticket.status] ?? Colors.grey;
    final lastMessage = ticket.messages.isNotEmpty ? ticket.messages.last.contenu : '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SupportTicketThread(ticketId: ticket.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(ticket.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appStyle.H5(weight: 'bold')),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabels(AppLocalizations.of(context)!)[ticket.status] ?? ticket.status,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (lastMessage.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(lastMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: appStyle.H6(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}
