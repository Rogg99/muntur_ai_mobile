import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/features/chatbot/data/models/forum_detail.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';

final RegExp _urlPattern = RegExp(r'https?://\S+');

class ForumDetailsScreen extends ConsumerWidget {
  final DiscussionModel forum;
  const ForumDetailsScreen({super.key, required this.forum});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final detailAsync = ref.watch(forumDetailProvider(forum.id));
    final messagesAsync = ref.watch(chatMessagesProvider(forum.id, isForum: true));

    final messages = messagesAsync.valueOrNull ?? [];
    final mediaItems = <Map<String, dynamic>>[];
    final links = <String>[];
    for (final m in messages) {
      try {
        final decoded = jsonDecode(m.media);
        if (decoded is List) {
          mediaItems.addAll(decoded.whereType<Map>().map((e) => e.cast<String, dynamic>()));
        }
      } catch (_) {}
      links.addAll(_urlPattern.allMatches(m.contenu).map((match) => match.group(0)!));
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text('Détails du groupe', style: appStyle.H4(weight: 'bold')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                _ForumAvatar(forum: forum, size: 84),
                const SizedBox(height: 12),
                Text(forum.title,
                    style: appStyle.H3(weight: 'bold'), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                detailAsync.when(
                  data: (detail) => Text(
                    detail?.membersCount != null
                        ? '${detail!.membersCount} membre${detail.membersCount! > 1 ? 's' : ''}'
                        : 'Groupe',
                    style: appStyle.H6(color: colorScheme.onSurfaceVariant),
                  ),
                  loading: () => Text('Groupe',
                      style: appStyle.H6(color: colorScheme.onSurfaceVariant)),
                  error: (_, __) => Text('Groupe',
                      style: appStyle.H6(color: colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          detailAsync.maybeWhen(
            data: (detail) => (detail?.description.isNotEmpty ?? false)
                ? _Section(
                    title: 'Description',
                    child: Text(detail!.description, style: appStyle.H5()),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          detailAsync.maybeWhen(
            data: (detail) => (detail?.members.isNotEmpty ?? false)
                ? _Section(
                    title: 'Membres (${detail!.members.length})',
                    child: Column(
                      children: detail.members
                          .map((member) => _MemberTile(member: member))
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          _Section(
            title: 'Médias partagés (${mediaItems.length})',
            child: mediaItems.isEmpty
                ? Text('Aucun média partagé pour le moment',
                    style: appStyle.H6(color: colorScheme.onSurfaceVariant))
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: mediaItems.length,
                    itemBuilder: (context, index) {
                      final item = mediaItems[index];
                      final url = item['file']?.toString() ?? '';
                      final kind = item['kind']?.toString() ?? 'unknown';
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kind == 'image'
                            ? CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  color: colorScheme.surfaceContainer,
                                  child: const Icon(Icons.broken_image_outlined),
                                ),
                              )
                            : Container(
                                color: colorScheme.surfaceContainer,
                                alignment: Alignment.center,
                                child: Icon(
                                  kind == 'audio'
                                      ? Icons.audiotrack
                                      : Icons.attach_file,
                                  color: colorScheme.primary,
                                ),
                              ),
                      );
                    },
                  ),
          ),
          _Section(
            title: 'Liens (${links.length})',
            child: links.isEmpty
                ? Text('Aucun lien partagé pour le moment',
                    style: appStyle.H6(color: colorScheme.onSurfaceVariant))
                : Column(
                    children: links
                        .map((link) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.link,
                                      size: 18, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      link,
                                      style: appStyle.H6(color: colorScheme.primary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: appStyle.H5(weight: 'bold')),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final ForumMember member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final initial = member.name.isNotEmpty ? member.name.substring(0, 1).toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: member.photo.startsWith('http')
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: member.photo,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _initialAvatar(context, initial),
                    ),
                  )
                : _initialAvatar(context, initial),
          ),
          const SizedBox(width: 12),
          Text(member.name, style: appStyle.H5()),
        ],
      ),
    );
  }

  Widget _initialAvatar(BuildContext context, String initial) {
    return Container(
      decoration: BoxDecoration(
        color: ConstantsProvider.getColorFromLetter(context, initial),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(initial,
          style: AppStyle.of(context).H6(weight: 'bold', color: Colors.white)),
    );
  }
}

class _ForumAvatar extends StatelessWidget {
  final DiscussionModel forum;
  final double size;
  const _ForumAvatar({required this.forum, required this.size});

  @override
  Widget build(BuildContext context) {
    final initial = forum.title.isNotEmpty ? forum.title.substring(0, 1).toUpperCase() : '?';
    final fallback = Container(
      decoration: BoxDecoration(
        color: ConstantsProvider.getColorFromLetter(context, initial),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(initial,
          style: AppStyle.of(context).H2(weight: 'bold', color: Colors.white)),
    );
    return SizedBox(
      width: size,
      height: size,
      child: forum.photo.startsWith('http')
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: forum.photo,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => fallback,
              ),
            )
          : fallback,
    );
  }
}
