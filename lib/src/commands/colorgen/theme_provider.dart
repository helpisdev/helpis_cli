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

@Deprecated('Use AppTheme typedef instead.')
typedef ${appName.toPascalCase}EnhancedTheme = ${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme>;
typedef AppTheme = ${appName.toPascalCase}Theme<AllTagsAndGroupsEnhancedTheme>;

class _ThemingState extends State<Theming> {
  late EnhancedThemeMode _enhancedThemeMode;
  late ThemeMode mode;
  AppTheme light = AppTheme.rustLightTheme;
  AppTheme dark = AppTheme.rustDarkTheme;

  @override
  void initState() {
    super.initState();
    _enhancedThemeMode = EnhancedThemeMode.fromBrightness(context);
    mode = _enhancedThemeMode.equivalent;
  }

  @override
  Widget build(final BuildContext context) => ThemeProvider(
        mode: mode,
        light: light,
        dark: dark,
        themingKey: widget.key,
        child: widget.child,
      );

  void changeTheme({
    final AppTheme? theme,
    final EnhancedThemeMode? mode,
  }) {
    if (theme != null) {
      setState(
        () {
          final EnhancedThemeMode themeMode = theme.themeData.mode;
          themeMode == EnhancedThemeMode.light ? light = theme : dark = theme;
          this.mode = themeMode.equivalent;
        },
      );
    }
    if (mode != null) {
      setState(
        () {
          _enhancedThemeMode = mode;
          this.mode = _enhancedThemeMode.equivalent;
        },
      );
    }
  }

  EnhancedThemeMode get enhancedThemeMode => _enhancedThemeMode;
  set enhancedThemeMode(final EnhancedThemeMode mode) {
    changeTheme(mode: mode);
  }

  void switchTheme() => changeTheme(mode: enhancedThemeMode.oppositeEnhanced);

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<AppTheme>('dark', dark))
      ..add(DiagnosticsProperty<AppTheme>('light', light))
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
  final AppTheme light;
  final AppTheme dark;

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

  void changeTheme({
    final AppTheme? theme,
    final EnhancedThemeMode? mode,
  }) =>
      themingKey.currentState?.changeTheme(theme: theme, mode: mode);

  void switchTheme() => themingKey.currentState?.switchTheme();

  @override
  bool updateShouldNotify(final ThemeProvider oldWidget) =>
      mode != oldWidget.mode ||
      light != oldWidget.light ||
      dark != oldWidget.dark;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<AppTheme>('dark', dark))
      ..add(DiagnosticsProperty<AppTheme>('light', light))
      ..add(EnumProperty<ThemeMode>('mode', mode))
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
