import 'utils.dart';

String themeProvider(final String appName, final String themeName) => '''
class Theming extends StatefulWidget {
  const Theming({
    required this.child,
    GlobalThemeKey super.key = const GlobalThemeKey(),
  });

  @override
  GlobalThemeKey get key => super.key! as GlobalThemeKey;

  final Widget child;

  @override
  State<Theming> createState() => _ThemingState();
}

typedef ${appName.toPascalCase}EnhancedTheme = ${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme>;

class _ThemingState extends State<Theming> {
  ThemeMode mode = ThemeMode.light;
  EnhancedThemeMode _enhancedThemeMode = EnhancedThemeMode.light;
  ${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme> light = ${appName.toPascalCase}Theme.rustLightTheme;
  ${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme> dark = ${appName.toPascalCase}Theme.rustDarkTheme;

  void switchTheme([
    final ${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme>? theme,
  ]) {
    setState(
      () {
        if (theme != null) {
          final EnhancedThemeMode mode = theme.themeData.mode;
          switch (mode) {
            case EnhancedThemeMode.light:
              light = theme;
              break;
            case EnhancedThemeMode.dark:
              dark = theme;
              break;
          }
          this.mode = mode.equivalent;
        } else {
          mode = _enhancedThemeMode.opposite;
          _enhancedThemeMode = EnhancedThemeMode.of(mode.name);
        }
      },
    );
  }

  EnhancedThemeMode get enhancedThemeMode => _enhancedThemeMode;
  set enhancedThemeMode(final EnhancedThemeMode mode) =>
      setState(() => _enhancedThemeMode = mode);

  @override
  Widget build(final BuildContext context) => ThemeProvider(
        mode: mode,
        light: light,
        dark: dark,
        themingKey: widget.key,
        child: widget.child,
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme>>(
          'dark',
          dark,
        ),
      )
      ..add(
        DiagnosticsProperty<${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme>>(
          'light',
          light,
        ),
      )
      ..add(EnumProperty<ThemeMode>('mode', mode))
      ..add(
        EnumProperty<EnhancedThemeMode>(
          'enhancedThemeMode',
          enhancedThemeMode,
        ),
      );
  }
}

class ThemeProvider extends InheritedWidget {
  const ThemeProvider({
    required super.child,
    required this.mode,
    required this.light,
    required this.dark,
    required this.themingKey,
    super.key,
  });

  final GlobalThemeKey themingKey;

  final ThemeMode mode;
  final ${appName.toPascalCase}EnhancedTheme light;
  final ${appName.toPascalCase}EnhancedTheme dark;

  static ThemeProvider? maybeOf(final BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeProvider>();

  static ThemeProvider of(final BuildContext context) {
    final ThemeProvider? result = maybeOf(context);
    assert(result != null, 'No ThemeProvider found in context');
    return result!;
  }

  EnhancedThemeMode get enhancedThemeMode =>
      themingKey.currentState!.enhancedThemeMode;

  set enhancedThemeMode(final EnhancedThemeMode mode) =>
      themingKey.currentState?.enhancedThemeMode = mode;

  void switchTheme([
    final ${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme>? theme,
  ]) =>
      themingKey.currentState?.switchTheme(theme);

  @override
  bool updateShouldNotify(final ThemeProvider oldWidget) =>
      mode != oldWidget.mode ||
      light != oldWidget.light ||
      dark != oldWidget.dark;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme>>('light', light),
      )
      ..add(EnumProperty<ThemeMode>('mode', mode))
      ..add(
        EnumProperty<${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme>>('dark', dark),
      )
      ..add(DiagnosticsProperty<GlobalThemeKey>('themingKey', themingKey))
      ..add(
        EnumProperty<EnhancedThemeMode>(
          'enhancedThemeMode',
          enhancedThemeMode,
        ),
      );
  }
}

class GlobalThemeKey extends GlobalKey<_ThemingState> {
  const GlobalThemeKey() : super.constructor();
}
''';
