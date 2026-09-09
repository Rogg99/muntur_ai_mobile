import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/screens/chat.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/utils/dateUtils.dart';

class WidgetDiscussion extends ConsumerWidget {
  final DiscussionModel? disc;

  const WidgetDiscussion({
    super.key,
    required this.disc,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final d = disc!;
    final unread = d.unreadCount > 0;
    final initial =
        d.title.isNotEmpty ? d.title.substring(0, 1).toUpperCase() : '?';
    // "Vous:" means the CURRENT USER wrote the last message — last_writer is
    // now the sender's profile id (see chatbot_repository_impl.dart);
    // "initiateur" is never populated by the backend and can't be used here.
    final myId = ref.watch(authStateProvider).valueOrNull?.id;
    final isMe = myId != null && d.last_writer == myId;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatView(disc: d)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(photo: d.photo, initial: initial, colorScheme: colorScheme),
            const SizedBox(width: 12),
            // Expanded, not a hardcoded (screen width - N) — the row shrinks
            // and grows with whatever space is actually available instead of
            // assuming one fixed screen width.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.title,
                    style: appStyle.H5(
                      weight: 'bold',
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMe
                        ? '${translator.you} : ${d.last_message}'
                        : d.last_message,
                    style: appStyle
                        .H6(
                          color: unread
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          weight: unread ? 'bold' : 'Regular',
                        )
                        .copyWith(overflow: TextOverflow.ellipsis),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  getLocalizedDate(
                      d.last_date, Localizations.localeOf(context).languageCode),
                  style: appStyle.txtDefault(
                    size: 12,
                    color: unread ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                if (unread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      d.unreadCount > 99 ? '99+' : '${d.unreadCount}',
                      textAlign: TextAlign.center,
                      style: appStyle.H8(color: colorScheme.onPrimary),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String photo;
  final String initial;
  final ColorScheme colorScheme;

  const _Avatar({
    required this.photo,
    required this.initial,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final fallbackColor =
        ConstantsProvider.getColorFromLetter(context, initial);

    Widget fallback() => Container(
          decoration: BoxDecoration(
            color: fallbackColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: appStyle.H5(weight: 'bold', color: Colors.white),
          ),
        );

    return SizedBox(
      height: 48,
      width: 48,
      child: photo.startsWith('http')
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: photo,
                fit: BoxFit.cover,
                placeholder: (context, url) => fallback(),
                errorWidget: (context, url, error) => fallback(),
              ),
            )
          : fallback(),
    );
  }
}
