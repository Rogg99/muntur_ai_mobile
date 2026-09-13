import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/support_models.dart';

class SupportRepositoryImpl {
  final ApiClient _apiClient;

  SupportRepositoryImpl(this._apiClient);

  Future<List<SupportTicket>> getMyTickets() async {
    final response = await _apiClient.get('/support/tickets/');
    final rawList = asResponseList(response.data);
    return rawList
        .whereType<Map>()
        .map((j) => SupportTicket.fromJson(j.cast<String, dynamic>()))
        .toList();
  }

  Future<SupportTicket> getTicketDetail(String id) async {
    final response = await _apiClient.get('/support/tickets/$id/');
    final raw = response.data['data'] ?? response.data;
    return SupportTicket.fromJson((raw as Map).cast<String, dynamic>());
  }

  /// [sourceDiscussionId] lets the backend snapshot the discussion's
  /// context_summary onto the ticket — omit for a standalone ticket with no
  /// chat history behind it (e.g. opened directly from Settings).
  Future<SupportTicket> createTicket({
    required String subject,
    required String contenu,
    List<String> mediaIds = const [],
    String? sourceDiscussionId,
  }) async {
    final response = await _apiClient.post('/support/tickets/', data: {
      'subject': subject,
      'contenu': contenu,
      'media': mediaIds,
      if (sourceDiscussionId != null) 'source_discussion': sourceDiscussionId,
    });
    final raw = response.data['data'] ?? response.data;
    return SupportTicket.fromJson((raw as Map).cast<String, dynamic>());
  }

  Future<SupportTicket> replyToTicket({
    required String ticketId,
    required String contenu,
    List<String> mediaIds = const [],
  }) async {
    final response = await _apiClient.post(
      '/support/tickets/$ticketId/messages/',
      data: {'contenu': contenu, 'media': mediaIds},
    );
    final raw = response.data['data'] ?? response.data;
    return SupportTicket.fromJson((raw as Map).cast<String, dynamic>());
  }

  /// Same shared /medias/ endpoint chat/marketplace attachments use.
  Future<String?> uploadAttachment(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.uri.pathSegments.last),
    });
    final response = await _apiClient.postMultipart('/medias/', form);
    final data = response.data['data'] ?? response.data;
    return data is Map ? data['id']?.toString() : null;
  }
}
