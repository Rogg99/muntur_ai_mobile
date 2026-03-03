import 'dart:async';
import 'dart:io' show HttpOverrides;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:munturai/screens/home.dart';
import 'package:munturai/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:munturai/screens/splashscreen.dart';
import 'package:munturai/services/api/cert_override.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/database/isar_db.dart';

import 'package:munturai/features/auth/data/models/user_model.dart';
import 'package:munturai/features/chatbot/data/models/discussion_model.dart';
import 'package:munturai/features/chatbot/data/models/message_model.dart';
import 'package:munturai/features/garages/data/models/garage_model.dart';
import 'package:munturai/core/services/sync_service.dart';

import 'core/fonctions.dart';
import 'core/theming/theme.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarDb.init([
    UserModelSchema,
    DiscussionModelSchema,
    MessageModelSchema,
    GarageModelSchema,
  ]);

  // Sync any pending offline messages in background
  SyncService().syncPendingData();

  final savedLocale = await LocaleManager.loadLocale();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  HttpOverrides.global = MyHttpOverrides(); // DEV ONLY

  runApp(ProviderScope(child: MyApp(savedLocale)));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  const MyApp(this.initialLocale, {super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final ValueNotifier<ThemeSettings> settings = ValueNotifier(
    ThemeSettings(
      sourceColor: const Color(0xFFF9A8D4),
      themeMode: ThemeMode.system, // default
    ),
  );

  Locale _locale = const Locale('en');
  Widget? startingWiget;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _loadThemeMode() async {
    final savedMode = await loadThemeMode();
    settings.value = ThemeSettings(
      sourceColor: settings.value.sourceColor,
      themeMode: savedMode,
    );
  }

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _loadThemeMode();
    WidgetsBinding.instance.addObserver(this);
    _checkPreviousState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
      print("App lifecycle state: $state");
    }

    if (state == AppLifecycleState.paused) {
      _saveAppState();
    } else if (state == AppLifecycleState.resumed) {
      _checkPreviousState();
    }
  }

  Future<void> _saveAppState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("wasRunning", true);
  }

  Future<void> _checkPreviousState() async {
    final prefs = await SharedPreferences.getInstance();
    final wasRunning = prefs.getBool("wasRunning") ?? false;
    final lastPage = await getKey("lastPage");

    if (wasRunning && lastPage.isNotEmpty) {
      if (kDebugMode) {
        print("App was not properly closed — restore state here.");
      }
      if (lastPage == 'home') {
        setState(() {
          startingWiget = HomeScreen();
        });
      } else if (lastPage == 'settings') {
        setState(() {
          startingWiget = const Settings();
        });
      }
      // Show dialog / restore form / go to last screens, etc.
      await prefs.setBool("wasRunning", false); // Reset after handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return ThemeProvider(
          lightDynamic: lightDynamic,
          darkDynamic: darkDynamic,
          settings: settings,
          child: NotificationListener<ThemeSettingChange>(
            onNotification: (notification) {
              settings.value = notification.settings;
              return true;
            },
            child: ValueListenableBuilder<ThemeSettings>(
              valueListenable: settings,
              builder: (context, value, _) {
                final theme = ThemeProvider.of(context);
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'MunturAi',
                  locale: _locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  themeMode: theme.themeMode(),
                  theme: theme.light(value.sourceColor),
                  darkTheme: theme.dark(value.sourceColor),
                  home: const SplashscreenScreen(), // Start screens
                  navigatorKey: MyApp.navigatorKey,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
