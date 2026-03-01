import 'package:munturai/screens/onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/app_export.dart';
import '../main.dart';

class LanguageSwitcherView extends StatefulWidget {
  final bool initial;
  const LanguageSwitcherView({super.key, this.initial=true});

  @override
  _LanguageSwitcherViewState createState() => _LanguageSwitcherViewState();
}

class _LanguageSwitcherViewState extends State<LanguageSwitcherView> {
  Locale? _currentLocale;

  final List<Map<String, dynamic>> _locales = [
    {'locale': const Locale('en'), 'label': '🇬🇧 English'},
    {'locale': const Locale('fr'), 'label': '🇫🇷 Français'},
    {'locale': const Locale('es'), 'label': '🇪🇸 Español'},
    {'locale': const Locale('de'), 'label': '🇩🇪 Deutsch'},
    {'locale': const Locale('it'), 'label': '🇮🇹 Italiano'},
    {'locale': const Locale('pt'), 'label': '🇵🇹 Português'},
    {'locale': const Locale('ru'), 'label': '🇷🇺 Русский'},
    {'locale': const Locale('ar'), 'label': '🇸🇦 العربية'},
    {'locale': const Locale('zh'), 'label': '🇨🇳 中文'},
    {'locale': const Locale('ja'), 'label': '🇯🇵 日本語'},
    {'locale': const Locale('ko'), 'label': '🇰🇷 한국어'},
    {'locale': const Locale('hi'), 'label': '🇮🇳 हिंदी'},
  ];

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final theme = ThemeProvider.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Locale locale = Localizations.localeOf(context);
    AppLocalizations translator = AppLocalizations.of(context)!;
    final isDark = theme.themeMode() == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 90,
        leading:
            widget.initial ?
              SizedBox():
              Center(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios,color: isDark ? Colors.white : Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
        elevation: 0,
        centerTitle: true,
        title: Text(
          translator.language,
          style: appStyle.H3(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          widget.initial ?
          CupertinoButton(
            onPressed: () {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => OnBoarding()));
            },
            color: Colors.transparent,
            child: Text(
              translator.continue__,
              style: appStyle.H6(color: colorScheme.secondary),
            ),
          ):
          SizedBox(),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: _locales.length,
        separatorBuilder: (_, __) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final localeData = _locales[index];
          return _buildLocaleCard(context, localeData['locale'], localeData['label'], locale);
        },
      ),
    );
  }

  Widget _buildLocaleCard(BuildContext context, Locale locale, String label, Locale current) {
    bool isSelected = locale.languageCode == current.languageCode;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final appStyle = AppStyle.of(context);

    return GestureDetector(
      onTap: () => MyApp.setLocale(context,locale),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          border: Border.all(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(15)
        ),
        child: Row(
          children: [
            SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: appStyle.H5().copyWith(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.white)
          ],
        ),
      ),
    );
  }
}
