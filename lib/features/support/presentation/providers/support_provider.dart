import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/support_models.dart';
import '../../data/repositories_impl/support_repository_impl.dart';

final supportRepositoryProvider = Provider<SupportRepositoryImpl>(
  (ref) => SupportRepositoryImpl(ApiClient()),
);

final supportTicketsProvider = FutureProvider.autoDispose<List<SupportTicket>>((ref) {
  return ref.read(supportRepositoryProvider).getMyTickets();
});

final supportTicketDetailProvider =
    FutureProvider.autoDispose.family<SupportTicket, String>((ref, id) {
  return ref.read(supportRepositoryProvider).getTicketDetail(id);
});
