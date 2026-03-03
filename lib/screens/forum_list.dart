import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';
import 'package:munturai/screens/forum_chat.dart';

class ForumListScreen extends ConsumerWidget {
  const ForumListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final forumsAsync = ref.watch(forumsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        title: Text('Forum', style: appStyle.H3(weight: 'bold')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(forumsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: forumsAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (forums) {
          if (forums.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.chat_bubble_2,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('Aucun forum disponible', style: appStyle.H5()),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                    onPressed: () =>
                        ref.read(forumsProvider.notifier).refresh(),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(forumsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: forums.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
              ),
              itemBuilder: (ctx, i) => _ForumTile(forum: forums[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ForumTile extends StatelessWidget {
  final DiscussionModel forum;
  const _ForumTile({required this.forum});

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: (forum.photo != 'none' && forum.photo.isNotEmpty)
            ? NetworkImage(forum.photo)
            : null,
        child: (forum.photo == 'none' || forum.photo.isEmpty)
            ? Icon(CupertinoIcons.chat_bubble_2, color: colorScheme.primary)
            : null,
      ),
      title: Text(
        forum.title,
        style: appStyle.H5(weight: 'bold'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        forum.last_message.replaceAll('none', ''),
        style: appStyle.H6(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatDate(forum.last_date),
            style: appStyle.H6(color: colorScheme.onSurface.withOpacity(0.5)),
          ),
          if (forum.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                forum.unreadCount.toString(),
                style: appStyle.H6(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForumChatView(disc: forum),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays < 7) {
        const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        return days[dt.weekday - 1];
      } else {
        return '${dt.day}/${dt.month}';
      }
    } catch (_) {
      return '';
    }
  }
}
