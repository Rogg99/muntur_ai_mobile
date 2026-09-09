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
  // Brand palette, from the AUTOSYNX logotype (assets/images/logo AUTOSYNX FIN-01.jpg.jpeg):
  // purple #7B2CBF, navy #0C2745, white #FFFFFF.
  static Color fromColorEnum(colorEnum color, bool lightMode) {
    switch (color) {
      case colorEnum.primary:
        return fromHex('#7B2CBF');
      case colorEnum.onPrimary:
        return Colors.white;
      case colorEnum.secondary:
        // Light mode pairs the navy "AX" wordmark with the purple swoosh;
        // dark mode swaps navy (now the background) for a lighter purple tint.
        return lightMode ? fromHex('#0C2745') : fromHex('#A566E0');
      case colorEnum.onSecondary:
        return Colors.white;
      case colorEnum.tertiary:
        return lightMode ? fromHex('#F19101') : fromHex('#F7B84B');
      case colorEnum.onTertiary:
        return Colors.white;
      case colorEnum.error:
        return lightMode ? fromHex('#E53935') : fromHex('#EF5350');
      case colorEnum.onError:
        return Colors.white;
      case colorEnum.success:
        return lightMode ? fromHex('#00C48C') : fromHex('#1EE0A0');
      case colorEnum.background:
        return lightMode ? Colors.white : fromHex('#0C2745');
      case colorEnum.surface:
        return lightMode ? fromHex('#F6F2FB') : fromHex('#13315B');
      case colorEnum.onBackground:
        return lightMode ? fromHex('#0C2745') : Colors.white;
      case colorEnum.onSurface:
        return lightMode ? fromHex('#0C2745') : Colors.white;
    }
  }

  // Base Colors
  static const String _primaryHex = '#7B2CBF';
  static final Color primary = fromHex(_primaryHex);
  static final Color secondary = fromHex('#0C2745');
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
      brightness: brightness,
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

  CardThemeData cardTheme() {
    return CardThemeData(
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

  TabBarThemeData tabBarTheme(ColorScheme colors) {
    return TabBarThemeData(
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

  BottomAppBarThemeData bottomAppBarTheme(ColorScheme colors) {
    return BottomAppBarThemeData(
      color: colors.surface,
      elevation: 0,
    );
  }

  // Replaces the old BottomNavigationBarThemeData (Material2-style bottom
  // bar: flat, no selection highlight, abrupt icon swap) now that
  // home.dart uses NavigationBar instead — Material3's redesigned bottom
  // nav with a pill-shaped indicator behind the selected icon.
  NavigationBarThemeData navigationBarTheme(ColorScheme colors) {
    return NavigationBarThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: colors.primary.withValues(alpha: 0.16),
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Sk-Modernist',
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? colors.onSurface : colors.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? colors.primary : colors.onSurfaceVariant,
        );
      }),
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

  // No dialogTheme was set anywhere, so every AlertDialog/Dialog fell back
  // to Material3's default: backgroundColor comes from the *unthemed*
  // surfaceContainerHigh (only surface/background/onSurface etc. are
  // overridden in colors() above, not the surface-container tones — those
  // stay whatever ColorScheme.fromSeed() generated), and a surfaceTintColor
  // elevation overlay is painted on top of that. Both combine into a flat
  // grey that doesn't match the app's actual navy/purple surfaces and
  // washes out contrast against onSurface text, especially in dark mode.
  DialogThemeData dialogTheme(ColorScheme colors) {
    return DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: shapeMedium,
      titleTextStyle: TextStyle(
        color: colors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontFamily: 'Sk-Modernist',
      ),
      contentTextStyle: TextStyle(
        color: colors.onSurface,
        fontSize: 15,
        fontFamily: 'Sk-Modernist',
      ),
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
      navigationBarTheme: navigationBarTheme(_colors),
      navigationRailTheme: navigationRailTheme(_colors),
      tabBarTheme: tabBarTheme(_colors),
      drawerTheme: drawerTheme(_colors),
      dialogTheme: dialogTheme(_colors),
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
      navigationBarTheme: navigationBarTheme(_colors),
      navigationRailTheme: navigationRailTheme(_colors),
      tabBarTheme: tabBarTheme(_colors),
      drawerTheme: drawerTheme(_colors),
      dialogTheme: dialogTheme(_colors),
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
