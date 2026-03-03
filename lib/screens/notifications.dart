import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/notifications/domain/entities/notification_entity.dart';
import 'package:munturai/features/notifications/presentation/providers/notification_provider.dart';
import 'package:munturai/screens/webview.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final notifAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        title: Text('Notifications', style: appStyle.H3(weight: 'bold')),
        actions: [
          notifAsync.whenOrNull(
                data: (n) => n.any((notif) => !notif.isRead)
                    ? TextButton(
                        onPressed: () => ref
                            .read(notificationsListProvider.notifier)
                            .markAllAsRead(),
                        child: const Text('Tout lire'),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: notifAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('Aucune notification', style: appStyle.H5()),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                    onPressed: () =>
                        ref.read(notificationsListProvider.notifier).refresh(),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationsListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 70, endIndent: 16),
              itemBuilder: (ctx, i) =>
                  _NotificationTile(notification: notifications[i]),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationEntity notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: notification.isRead
          ? null
          : colorScheme.primaryContainer.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: notification.image.isNotEmpty
            ? NetworkImage(notification.image)
            : null,
        child: notification.image.isEmpty
            ? Icon(Icons.notifications, color: colorScheme.primary)
            : null,
      ),
      title: Text(
        notification.title,
        style: appStyle.H5(weight: notification.isRead ? 'regular' : 'bold'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        notification.text,
        style: appStyle.H6(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatDate(notification.time),
            style: appStyle.H6(
                color: colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          if (!notification.isRead) ...[
            const SizedBox(height: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: colorScheme.primary, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
      onTap: () {
        ref
            .read(notificationsListProvider.notifier)
            .markAsRead(notification.id);
        if (notification.url.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WebViewPage(),
            ),
          );
        }
      },
    );
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      const j = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return j[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}';
  }
}
