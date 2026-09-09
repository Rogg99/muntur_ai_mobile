import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/theming/dimens.dart';
import 'package:munturai/features/chatbot/presentation/providers/chatbot_provider.dart';
import 'package:munturai/screens/chat.dart';

import 'package:munturai/features/notifications/presentation/providers/notification_provider.dart';
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
  bool _centerUser = false;

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
      MapScreen(buttonPressed: _centerUser),

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
          // No reload button — pull-to-refresh (RefreshIndicator) on the
          // Discussions/Forums lists below covers this already, and doesn't
          // require a network round-trip on every tab switch to be visible.
          title: Center(
            child: Text(
              titles.elementAt(_selectedIndex),
              style: appStyle.H3(),
            ),
          ),
          actions: [
            _selectedIndex == 1
                ? IconButton(
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Ma position',
                    onPressed: () {
                      setState(() {
                        _centerUser = true;
                        Timer(const Duration(milliseconds: 100), () {
                          setState(() {
                            _centerUser = false;
                          });
                        });
                      });
                    },
                  )
                : SizedBox(),
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
        // IndexedStack, not tabs.elementAt(_selectedIndex): the latter swaps
        // a different widget *type* into this slot on every tab switch, so
        // Flutter unmounts the outgoing tab and mounts a fresh one — any
        // autoDispose provider it was watching (discussions, forums, ...)
        // gets disposed and then rebuilt from scratch next visit, which is
        // exactly the request-and-loader-on-every-switch this replaces.
        // IndexedStack keeps all five tabs permanently mounted so none of
        // that ever happens — the data loads once and stays live via WS.
        body: IndexedStack(
          index: _selectedIndex,
          children: tabs,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: [
            NavigationDestination(
              icon: _navIcon(ImageConstant.navHomeOutline, colorScheme.onSurfaceVariant),
              selectedIcon: _navIcon(ImageConstant.navHomeFilled, colorScheme.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: _navIcon(ImageConstant.navMapOutline, colorScheme.onSurfaceVariant),
              selectedIcon: _navIcon(ImageConstant.navMapFilled, colorScheme.primary),
              label: 'Carte',
            ),
            NavigationDestination(
              icon: _navIcon(ImageConstant.navNewsOutline, colorScheme.onSurfaceVariant),
              selectedIcon: _navIcon(ImageConstant.navNewsFilled, colorScheme.primary),
              label: 'News',
            ),
            NavigationDestination(
              icon: _navIcon(ImageConstant.navForumOutline, colorScheme.onSurfaceVariant),
              selectedIcon: _navIcon(ImageConstant.navForumFilled, colorScheme.primary),
              label: 'Forums',
            ),
            NavigationDestination(
              icon: _navIcon(ImageConstant.navSettingsOutline, colorScheme.onSurfaceVariant),
              selectedIcon: _navIcon(ImageConstant.navSettingsFilled, colorScheme.primary),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }

  // Custom-drawn nav icons (see assets/images/nav_*.svg) instead of stock
  // Material glyphs. SvgPicture doesn't read the ambient IconTheme the way
  // Icon does, so the selected/unselected color has to be applied here
  // explicitly, matching navigationBarTheme() in theme.dart. flutter_svg
  // 1.1.6's SvgPicture.asset takes color/colorBlendMode, not colorFilter
  // (that param was added in a later major version).
  Widget _navIcon(String asset, Color color) {
    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      color: color,
      colorBlendMode: BlendMode.srcIn,
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
                // Still wrapped in RefreshIndicator — there's no reload
                // button anymore, so an empty list needs its own way to
                // pull-to-refresh. AlwaysScrollableScrollPhysics + a
                // full-height child is what makes the pull gesture register
                // at all when there's nothing to naturally overflow-scroll.
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(discussionsProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Aucune conversation. Commence une nouvelle conversation avec Autosynx !',
                              style: appStyle.H4(color: colorScheme.primary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(discussionsProvider.notifier).refresh(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
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
              // Still wrapped in RefreshIndicator — see the matching comment
              // in _DiscussionsTab above.
              return RefreshIndicator(
                onRefresh: () => ref.read(forumsProvider.notifier).refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Text('Aucun forum disponible',
                            style: appStyle.H5()),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(forumsProvider.notifier).refresh(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
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
