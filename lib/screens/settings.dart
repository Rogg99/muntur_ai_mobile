import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/services/app_lock_service.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/abonnement.dart';
import 'package:munturai/screens/app_lock_pin_screen.dart';
import 'package:munturai/screens/coins.dart';
import 'package:munturai/screens/profile.dart';
import 'package:munturai/screens/switchlanguage.dart';
import 'package:munturai/screens/about.dart';
import 'package:munturai/screens/cgu.dart';
import 'package:munturai/screens/help.dart';
import 'package:munturai/screens/login.dart';
import 'package:munturai/screens/marketplace_orders.dart';
import 'package:munturai/screens/marketplace_wishlist.dart';
import 'package:munturai/screens/marketplace_vendor_dashboard.dart';
import 'package:munturai/screens/privacy_policy.dart';
import 'package:munturai/screens/courier_profile.dart';
import 'package:munturai/screens/repair_garage_staff.dart';
import 'package:munturai/screens/repair_my_bookings.dart';
import 'package:munturai/screens/support_tickets.dart';

import '../core/fonctions.dart';
import '../core/theming/theme.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = ThemeProvider.of(context);
    final isDark = themeProvider.themeMode() == ThemeMode.dark;

    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Settings is a pushed screen (moved out of the bottom-nav tabs so the
      // 5 main tabs' app bars stay to just title+settings+notifications) —
      // it needs its own back arrow, unlike when it lived in HomeScreen's
      // IndexedStack under the shared outer app bar.
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(translator.settings_title, style: appStyle.H3()),
      ),
      body: userAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
        error: (e, _) => Center(child: Text('${translator.error_prefix}: $e')),
        data: (user) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            const SizedBox(height: 20),

            // ─── Avatar + Nom ───
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(130),
                  image: DecorationImage(
                    image: (user?.photo != null && user!.photo!.isNotEmpty)
                        ? NetworkImage(user.photo!) as ImageProvider
                        : const AssetImage(
                            'assets/images/placeholder_user.png'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(width: 4, color: colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                user?.fullName ?? translator.my_account,
                style: appStyle.H4(),
              ),
            ),
            const SizedBox(height: 8),

            // ─── Badge plan ───
            Center(
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SubscriptionsScreen())),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: colorScheme.primaryContainer,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium, size: 18),
                      const SizedBox(width: 6),
                      Text(translator.subscription_free,
                          style: appStyle.H5(weight: 'b')),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _SettingsTile(
              icon: CupertinoIcons.person_fill,
              label: translator.my_account,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Profile())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.moon_stars_fill,
              label: translator.dark_mode,
              trailing: Switch(
                value: isDark,
                activeColor: colorScheme.primary,
                inactiveTrackColor: Colors.transparent,
                onChanged: (val) {
                  final newMode = val ? ThemeMode.dark : ThemeMode.light;
                  saveThemeMode(newMode);
                  ThemeSettingChange(
                    settings: ThemeSettings(
                      sourceColor: themeProvider.settings.value.sourceColor,
                      themeMode: newMode,
                    ),
                  ).dispatch(context);
                },
              ),
            ),
            _SettingsTile(
              icon: CupertinoIcons.globe,
              label: translator.language,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LanguageSwitcherView(initial: false))),
            ),
            _SettingsTile(
              icon: CupertinoIcons.money_dollar_circle,
              label: translator.coins,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Coins())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.cart,
              label: translator.settings_my_orders,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MarketplaceOrders())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.heart,
              label: translator.settings_my_wishlist,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MarketplaceWishlist())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.wrench,
              label: translator.repair_my_bookings_title,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RepairMyBookings())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.gear_alt,
              label: translator.repair_staff_title,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RepairGarageStaffScreen())),
            ),
            // Vendor-only — hidden rather than shown-then-erroring for an
            // account with no storefront (same gating as the Profile
            // screen's "Ma boutique" section).
            Consumer(
              builder: (context, ref, _) {
                final vendor = ref.watch(marketplaceMyVendorProvider).valueOrNull;
                if (vendor == null) return const SizedBox.shrink();
                return _SettingsTile(
                  icon: CupertinoIcons.shopping_cart,
                  label: AppLocalizations.of(context)!.settings_my_shop,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MarketplaceVendorDashboard())),
                );
              },
            ),
            _SettingsTile(
              icon: CupertinoIcons.location_north_line,
              label: translator.settings_courier,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CourierProfileScreen())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.chat_bubble_2,
              label: translator.settings_contact_support,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SupportTickets())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.question,
              label: translator.help,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Help())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.doc_text_search,
              label: translator.termsConditions,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const CGU())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.lock_shield,
              label: translator.settings_privacy_security,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicy())),
            ),
            const _AppLockSection(),
            _SettingsTile(
              icon: CupertinoIcons.heart_circle_fill,
              label: translator.about,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => About())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.arrowshape_turn_up_right,
              label: translator.logout,
              color: Colors.redAccent,
              onTap: () => _confirmLogout(context, ref, translator),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(
      BuildContext context, WidgetRef ref, AppLocalizations translator) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.logout),
        content: Text(translator.logout),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translator.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const Login()),
                  (_) => false,
                );
              }
            },
            child: Text(translator.logout,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

/// Toggle + PIN management for the local biometric/PIN app lock. Kept as
/// its own small stateful widget (rather than lifting state into the
/// otherwise-stateless [Settings]) since it's the only tile needing to load
/// async state (enabled flag, whether a PIN already exists) and react to
/// its own toggle.
class _AppLockSection extends StatefulWidget {
  const _AppLockSection();

  @override
  State<_AppLockSection> createState() => _AppLockSectionState();
}

class _AppLockSectionState extends State<_AppLockSection> {
  final _service = AppLockService();
  bool _loading = true;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _service.isEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _loading = false;
    });
  }

  Future<void> _onToggle(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    if (!value) {
      await _service.disableAndClear();
      if (!mounted) return;
      setState(() => _enabled = false);
      return;
    }

    // Turning it on requires a PIN first (the fallback when biometrics
    // aren't available/enrolled or are cancelled) — set it up right away
    // rather than leaving the toggle on with no fallback possible.
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AppLockPinScreen(isSetup: true)),
    );
    if (created != true) return;
    await _service.setEnabled(true);
    if (!mounted) return;
    setState(() => _enabled = true);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.applock_enabled_confirmation)));
  }

  Future<void> _changePin() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AppLockPinScreen(isSetup: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _SettingsTile(
          icon: CupertinoIcons.lock_rotation,
          label: translator.applock_toggle_label,
          trailing: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Switch(
                  value: _enabled,
                  activeColor: colorScheme.primary,
                  inactiveTrackColor: Colors.transparent,
                  onChanged: _onToggle,
                ),
        ),
        if (_enabled)
          _SettingsTile(
            icon: CupertinoIcons.number,
            label: translator.applock_change_pin,
            onTap: _changePin,
          ),
      ],
    );
  }
}

/// Reusable settings row tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: appStyle.H5(
                      weight: 'bold',
                      color: color ?? Theme.of(context).colorScheme.onSurface)),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
