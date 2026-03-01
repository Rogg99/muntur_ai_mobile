import 'dart:math';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

enum colorEnum{
  primary,
  secondary,
  tertiary,
  error,
  success,
  background,
  surface,
  onPrimary,
  onSecondary,
  onTertiary,
  onError,
  onBackground,
  onSurface,
}

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return child;
  }
}

class ThemeSettingChange extends Notification {
  ThemeSettingChange({required this.settings});
  final ThemeSettings settings;
}

class ThemeProvider extends InheritedWidget {

  const ThemeProvider({
    super.key,
    required this.settings,
    required this.lightDynamic,
    required this.darkDynamic,
    required super.child,
  });
  // Helper to convert hex color string to Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
  static Color fromColorEnum(colorEnum color, bool lightMode) {
    switch (color) {
      case colorEnum.primary:
        return lightMode ? fromHex('#7F4EC4') : fromHex('#7F4EC4');
      case colorEnum.secondary:
        return lightMode ? fromHex('#C6B1E3') : fromHex('#9C7DD8');
      case colorEnum.tertiary:
        return lightMode ? fromHex('#F19101') : fromHex('#F7B84B');
      case colorEnum.error:
        return lightMode ? fromHex('#E53935') : fromHex('#EF5350');
      case colorEnum.success:
        return lightMode ? fromHex('#00C48C') : fromHex('#1EE0A0');
      case colorEnum.onPrimary:
        return lightMode ? Colors.white : Colors.black;
      case colorEnum.background:
        return lightMode ? Colors.white : fromHex('#121212');
      case colorEnum.surface:
        return lightMode ? fromHex('#F9F9FB') : fromHex('#121212');
      case colorEnum.onBackground:
        return lightMode ? Colors.black : Colors.white;
      case colorEnum.onSurface:
        return lightMode ? Colors.black : Colors.white;
      default:
        return lightMode ? primary : primary;
    }
  }

  // Base Colors
  static const String _primaryHex = '#7F4EC4';
  static final Color primary = fromHex(_primaryHex);
  static final Color secondary = fromHex('#C6B1E3');
  static final Color tertiary = fromHex('#F19101');
  static final Color error = fromHex('#E53935');
  static final Color success = fromHex('#00C48C');

  final ValueNotifier<ThemeSettings> settings;
  final ColorScheme? lightDynamic;
  final ColorScheme? darkDynamic;

  final pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
      TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
      TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
    },
  );

  Color custom(CustomColor custom) {
    return custom.blend ? blend(custom.color) : custom.color;
  }

  Color blend(Color targetColor) {
    return Color(
      Blend.harmonize(targetColor.value, settings.value.sourceColor.value),
    );
  }

  Color source(Color? target) {
    return target != null ? blend(target) : settings.value.sourceColor;
  }

  ColorScheme colors(Brightness brightness, Color? targetColor) {
    final dynamicPrimary = brightness == Brightness.light
        ? lightDynamic?.primary
        : darkDynamic?.primary;

    final base = ColorScheme.fromSeed(
      seedColor: dynamicPrimary ?? source(targetColor),
      brightness: brightness,
    );

    return base.copyWith(
      brightness: Brightness.light,
      primary: fromColorEnum(colorEnum.primary, brightness == Brightness.light),
      onPrimary: fromColorEnum(colorEnum.onPrimary, brightness == Brightness.light),
      secondary: fromColorEnum(colorEnum.secondary, brightness == Brightness.light),
      onSecondary: fromColorEnum(colorEnum.onSecondary, brightness == Brightness.light),
      tertiary: fromColorEnum(colorEnum.tertiary, brightness == Brightness.light),
      onTertiary: fromColorEnum(colorEnum.onTertiary, brightness == Brightness.light),
      error: fromColorEnum(colorEnum.error, brightness == Brightness.light),
      onError: fromColorEnum(colorEnum.onError, brightness == Brightness.light),
      background: fromColorEnum(colorEnum.background, brightness == Brightness.light),
      surface: fromColorEnum(colorEnum.surface, brightness == Brightness.light),
      onSurface: brightness == Brightness.light ? Colors.black : Colors.white, // text/icon color
      onSurfaceVariant: brightness == Brightness.light ? Colors.grey : Colors.grey[400],
    );
  }

  ShapeBorder get shapeMedium => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );

  get colorScheme => colors( this.themeMode() == ThemeMode.light ? Brightness.light : Brightness.dark, null);

  CardTheme cardTheme() {
    return CardTheme(
      elevation: 0,
      shape: shapeMedium,
      clipBehavior: Clip.antiAlias,
    );
  }

  ListTileThemeData listTileTheme(ColorScheme colors) {
    return ListTileThemeData(
      shape: shapeMedium,
      selectedColor: colors.secondary,
    );
  }

  AppBarTheme appBarTheme(ColorScheme colors) {
    return AppBarTheme(
      elevation: 0,
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
    );
  }

  TabBarTheme tabBarTheme(ColorScheme colors) {
    return TabBarTheme(
      labelColor: colors.secondary,
      unselectedLabelColor: colors.onSurfaceVariant,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.secondary,
            width: 2,
          ),
        ),
      ),
    );
  }

  BottomAppBarTheme bottomAppBarTheme(ColorScheme colors) {
    return BottomAppBarTheme(
      color: colors.surface,
      elevation: 0,
    );
  }

  BottomNavigationBarThemeData bottomNavigationBarTheme(ColorScheme colors) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: colors.surfaceVariant,
      selectedItemColor: colors.onSurface,
      unselectedItemColor: colors.onSurfaceVariant,
      elevation: 0,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    );
  }

  NavigationRailThemeData navigationRailTheme(ColorScheme colors) {
    return const NavigationRailThemeData();
  }

  DrawerThemeData drawerTheme(ColorScheme colors) {
    return DrawerThemeData(
      backgroundColor: colors.surface,
    );
  }

  ThemeData light([Color? targetColor]) {
    final _colors = colors(Brightness.light, targetColor);
    return ThemeData.light(useMaterial3: true).copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: _colors,
      appBarTheme: appBarTheme(_colors),
      cardTheme: cardTheme(),
      listTileTheme: listTileTheme(_colors),
      bottomAppBarTheme: bottomAppBarTheme(_colors),
      bottomNavigationBarTheme: bottomNavigationBarTheme(_colors),
      navigationRailTheme: navigationRailTheme(_colors),
      tabBarTheme: tabBarTheme(_colors),
      drawerTheme: drawerTheme(_colors),
      scaffoldBackgroundColor: _colors.background,
      textTheme: ThemeData.light(useMaterial3: true)
          .textTheme
          .apply(fontFamily: 'Sk-Modernist'),
    );
  }

  ThemeData dark([Color? targetColor]) {
    final _colors = colors(Brightness.dark, targetColor);
    return ThemeData.dark(useMaterial3: true).copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: _colors,
      appBarTheme: appBarTheme(_colors),
      cardTheme: cardTheme(),
      listTileTheme: listTileTheme(_colors),
      bottomAppBarTheme: bottomAppBarTheme(_colors),
      bottomNavigationBarTheme: bottomNavigationBarTheme(_colors),
      navigationRailTheme: navigationRailTheme(_colors),
      tabBarTheme: tabBarTheme(_colors),
      drawerTheme: drawerTheme(_colors),
      scaffoldBackgroundColor: _colors.background,
      textTheme: ThemeData.light(useMaterial3: true)
          .textTheme
          .apply(fontFamily: 'Sk-Modernist'),
    );
  }

  ThemeMode themeMode() {
    return settings.value.themeMode;
  }

  ThemeData theme(BuildContext context, [Color? targetColor]) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? light(targetColor)
        : dark(targetColor);
  }

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(covariant ThemeProvider oldWidget) {
    return oldWidget.settings != settings;
  }
}

class ThemeSettings {
  ThemeSettings({
    required this.sourceColor,
    required this.themeMode,
  });

  final Color sourceColor;
  final ThemeMode themeMode;
}

Color randomColor() {
  return Color(Random().nextInt(0xFFFFFFFF));
}

// Custom Colors
const linkColor = CustomColor(
  name: 'Link Color',
  color: Color(0xFF00B0FF),
);

const highlightGold = CustomColor(
  name: 'Elegant Gold',
  color: Color(0xFFFFD700),
);

class CustomColor {
  const CustomColor({
    required this.name,
    required this.color,
    this.blend = true,
  });

  final String name;
  final Color color;
  final bool blend;

  Color value(ThemeProvider provider) {
    return provider.custom(this);
  }

}
