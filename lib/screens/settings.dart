import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/screens/abonnement.dart';
import 'package:munturai/screens/coins.dart';
import 'package:munturai/screens/profile.dart';
import 'package:munturai/screens/switchlanguage.dart';
import 'package:munturai/screens/about.dart';
import 'package:munturai/screens/cgu.dart';
import 'package:munturai/screens/help.dart';
import 'package:munturai/screens/login.dart';

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
      body: userAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (user) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            const SizedBox(height: 60),

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
              icon: CupertinoIcons.question,
              label: translator.help,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Help())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.doc_text_search,
              label: translator.termsConditions,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => CGU())),
            ),
            _SettingsTile(
              icon: CupertinoIcons.arrowshape_turn_up_right,
              label: translator.logout,
              color: Colors.redAccent,
              onTap: () => _confirmLogout(context, ref, translator),
            ),
            _SettingsTile(
              icon: CupertinoIcons.heart_circle_fill,
              label: translator.about,
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => About())),
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
              child: const Text('Annuler')),
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
