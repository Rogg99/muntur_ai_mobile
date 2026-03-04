import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/theming/dimens.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';
import 'package:munturai/screens/chat.dart';

import 'package:munturai/features/notifications/presentation/providers/notification_provider.dart';
import 'package:munturai/core/utils/size_utils.dart';
import 'package:munturai/screens/maps.dart';
import 'package:munturai/screens/notifications.dart';
import 'package:munturai/screens/settings.dart';
import 'package:munturai/utils/sized_extension.dart';
import 'package:munturai/widgets/widget_discussion.dart';
import 'package:munturai/widgets/widget_forum.dart';

import 'infos.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _firstClick = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  // ─── Auto-refresh toutes les 10 secondes ──────────────────────────────────

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (mounted) {
        ref.read(discussionsProvider.notifier).refresh();
        ref.read(forumsProvider.notifier).refresh();
      }
    });
  }

  // ─── Retour physique ──────────────────────────────────────────────────────

  Future<bool> _onBackPressed() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }
    if (!_firstClick) {
      _firstClick = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appuyer encore pour quitter')),
      );
      Future.delayed(const Duration(seconds: 2), () => _firstClick = false);
      return false;
    }
    return true;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final translator = AppLocalizations.of(context)!;

    // ── Titres onglets ─────────────────────────────────────────────────
    final titles = [
      translator.homeTitle,
      translator.searchTitle,
      translator.newsTitle,
      translator.forumsTitle,
      translator.settings_title,
    ];

    // ── Unread count depuis notificationsListProvider ──────────────────
    final notifAsync = ref.watch(notificationsListProvider);
    final unreadCount =
        notifAsync.valueOrNull?.where((n) => !n.isRead).length ?? 0;

    // ── Onglets ────────────────────────────────────────────────────────
    final tabs = <Widget>[
      // Tab 0 — Discussions IA
      _DiscussionsTab(),

      // Tab 1 — Carte / Garages (MapScreen déjà Riverpod)
      const MapScreen(),

      // Tab 2 — Actualités (Infos ConsumerWidget newsListProvider)
      const Infos(),

      // Tab 3 — Forums
      _ForumsTab(),

      // Tab 4 — Paramètres
      const Settings(),
    ];

    // ── Scaffold ───────────────────────────────────────────────────────
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canLeave = await _onBackPressed();
        if (canLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () {
              ref.read(discussionsProvider.notifier).refresh();
              ref.read(forumsProvider.notifier).refresh();
            },
          ),
          title: Center(
            child: Text(
              titles.elementAt(_selectedIndex),
              style: appStyle.H3(),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: Dimens.padding.w),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications, size: 28),
                    if (unreadCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: appStyle.H8(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: tabs.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 16,
          backgroundColor: colorScheme.surface,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map, size: 28),
              label: 'Carte',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              activeIcon: Icon(Icons.newspaper, size: 28),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups, size: 28),
              label: 'Forums',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings, size: 28),
              label: 'Paramètres',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.5),
          selectedLabelStyle: appStyle.H6(),
          unselectedLabelStyle: appStyle.H6(),
          onTap: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
}

// ─── Tab 0 : Discussions IA ───────────────────────────────────────────────────

class _DiscussionsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final translator = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ref.watch(discussionsProvider).when(
            loading: () => Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Erreur : $err', style: appStyle.H5(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(discussionsProvider.notifier).refresh(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Aucune conversation. Commence une nouvelle conversation avec Muntur AI !',
                      style: appStyle.H4(color: colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(discussionsProvider.notifier).refresh(),
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  separatorBuilder: (_, __) =>
                      SizedBox(height: getHorizontalSize(15)),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => WidgetDiscussion(disc: list[i]),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatView()),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        label: Text(translator.newDiscussion),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Tab 3 : Forums ──────────────────────────────────────────────────────────

class _ForumsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ref.watch(forumsProvider).when(
          loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ),
          error: (err, _) => Center(
            child: Text('Erreur : $err', style: appStyle.H5(color: Colors.red)),
          ),
          data: (forums) {
            if (forums.isEmpty) {
              return Center(
                child: Text('Aucun forum disponible', style: appStyle.H5()),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(forumsProvider.notifier).refresh(),
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                separatorBuilder: (_, __) =>
                    SizedBox(height: getHorizontalSize(15)),
                itemCount: forums.length,
                itemBuilder: (ctx, i) => WidgetForum(disc: forums[i]),
              ),
            );
          },
        );
  }
}
