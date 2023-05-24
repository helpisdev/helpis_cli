/// File's contents stringified.
String get enhancedThemeContents => """
/// Signature for a string representing a theme name.
typedef ColorThemeName = String;

/// Signature for a set of enhanced themes.
typedef EnhancedThemeBucket = Set<EnhancedTheme>;

/// Simple theme mode enum with light/dark values.
enum EnhancedThemeMode {
  /// Light theme mode.
  light,

  /// Dark theme mode.
  dark;

  /// The equivalent [ThemeMode].
  ThemeMode get equivalent => this == light ? ThemeMode.light : ThemeMode.dark;

  /// The opposite [ThemeMode].
  ThemeMode get opposite => this == dark ? ThemeMode.light : ThemeMode.dark;

  /// The opposite [EnhancedThemeMode].
  EnhancedThemeMode get oppositeEnhanced => this == dark ? light : dark;

  /// Transforms a [String] to a valid [EnhancedThemeMode].
  static EnhancedThemeMode of(final String? name) {
    if (name == null || name.isEmpty) {
      throw StateError('Theme mode name must a non-empty non-null value.');
    }
    switch (name.toLowerCase()) {
      case 'light':
        return light;
      case 'dark':
        return dark;
    }
    throw UnsupportedError('Theme mode must either be light or dark.');
  }
}

/// A named theme configuration with an [EnhancedThemeMode].
abstract class EnhancedTheme {
  const EnhancedTheme();

  /// Theme's name.
  abstract final ColorThemeName name;

  /// Theme mode.
  abstract final EnhancedThemeMode mode;

  /// Theme's defined groups of [EnhancedColor]s.
  abstract final ColorGroupBucket groups;

  /// Theme's ungrouped [EnhancedColor]s.
  abstract final ColorGroup ungroupedColors;
}

extension _Utils on String {
  /// Tranforms a [String] to camelCase.
  String get toCamelCase => splitMapJoin(
        '[-_]',
        onMatch: (final Match match) => match.input
            .substring(
              match.start,
              match.end,
            )
            .toLowerCase()
            .toFirstCapital,
      ).toFirstLower;

  /// Tranforms a [String] to PascalCase.
  String get toPascalCase => toCamelCase.toFirstCapital;

  /// Capitalizes string's first character.
  String get toFirstCapital => replaceRange(
        0,
        1,
        substring(0, 1).toUpperCase(),
      );

  /// Lowers string's first character.
  String get toFirstLower => replaceRange(
        0,
        1,
        substring(0, 1).toLowerCase(),
      );
}
""";

/// File's contents stringified.
String get colorGroupContents => r"""
/// Signature for a string representing a color group name.
typedef ColorGroupName = String;

/// Signature for a set of color groups.
typedef ColorGroupBucket = Set<ColorGroup>;

/// A named [EnhancedColorBucket].
class ColorGroup {
  /// Attaches a name to an [EnhancedColorBucket].
  const ColorGroup(
    this.name, {
    final EnhancedColorBucket? colors,
  }) : colors = colors ?? const <ColorName, EnhancedColor>{};

  /// Group's name.
  final ColorGroupName name;

  /// Group's associated colors.
  final EnhancedColorBucket colors;

  /// Converts class to a [String] with an optional prefix.
  String stringify([final ColorThemeName? prefix]) =>
      "${prefix != null ? '$prefix${name.toPascalCase}' : 'Color'}"
      "Group('$name', colors: ${colors.pretty},)";
}

extension PrettifiedColorGroupBucket on ColorGroupBucket {
  /// Transforms a set of enhanced colors to a pretty string.
  static String colorGroupsToString(
    final ColorGroupBucket groups, [
    final ColorThemeName? prefix,
  ]) {
    final StringBuffer buffer = StringBuffer(
      '<ColorGroup>{${groups.isEmpty ? '}' : '\n'}',
    );
    for (final ColorGroup group in groups) {
      buffer.writeln('const ${group.stringify(prefix)},');
    }
    if (groups.isNotEmpty) {
      buffer.writeln('}');
    }
    return buffer.toString();
  }

  /// Representation of a set of enhanced colors.
  String pretty([final ColorThemeName? prefix]) => colorGroupsToString(
        this,
        prefix,
      );
}
""";

/// File's contents stringified.
String get enhancedColorContents => r'''
/// Signature for the integer value of a color.
typedef ColorValue = int;

/// Signature for a string representing a color name.
typedef ColorName = String;

/// Signature for a string representing a color tag.
typedef ColorTag = String;

/// Signature for a set of color tags.
typedef ColorTagBucket = Set<ColorTag>;

/// Signature for a set of enhanced colors.
typedef EnhancedColorBucket = Map<ColorName, EnhancedColor>;

/// A color with an attached value and a list of identifiers.
@immutable
class EnhancedColor extends Color {
  /// Attaches a provided name and various identifiers to a color.
  const EnhancedColor(
    super.value, {
    required this.name,
    final ColorTagBucket? tags,
  })  : tags = tags ?? const <ColorTag>{},
        super();

  /// Construct a color from the lower 8 bits of four integers.
  ///
  /// * `a` is the alpha value, with 0 being transparent and 255 being fully
  ///   opaque.
  /// * `r` is [red], from 0 to 255.
  /// * `g` is [green], from 0 to 255.
  /// * `b` is [blue], from 0 to 255.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [EnhancedColor.fromRGBO], which takes the alpha value as a
  /// floating point value.
  const EnhancedColor.fromARGB(
    super.a,
    super.r,
    super.g,
    super.b, {
    required this.name,
    final ColorTagBucket? tags,
  })  : tags = tags ?? const <ColorTag>{},
        super.fromARGB();

  /// Create a color from red, green, blue, and opacity, similar to `rgba()` in
  /// CSS.
  ///
  /// * `r` is [red], from 0 to 255.
  /// * `g` is [green], from 0 to 255.
  /// * `b` is [blue], from 0 to 255.
  /// * `opacity` is alpha channel of this color as a double, with 0.0 being
  ///   transparent and 1.0 being fully opaque.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [EnhancedColor.fromARGB], which takes the opacity as an integer
  /// value.
  const EnhancedColor.fromRGBO(
    super.r,
    super.g,
    super.b,
    super.opacity, {
    required this.name,
    final ColorTagBucket? tags,
  })  : tags = tags ?? const <ColorTag>{},
        super.fromRGBO();

  /// Name of the color.
  final ColorName name;

  /// List of color identifiers.
  final ColorTagBucket tags;

  @override
  String toString() =>
      "EnhancedColor(${value.toHex}, name: '$name', tags: ${tags.pretty},)";

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is EnhancedColor &&
        (other.value == value && tags == other.tags);
  }

  @override
  int get hashCode => value.hashCode;
}

extension Hex on ColorValue {
  /// Transforms the integer color value to a hexadecimal string representation.
  String get toHex => '0x${toRadixString(16).padLeft(8, '0')}';
}

extension PrettifiedColorTagBucket on ColorTagBucket {
  /// Transforms a set of color tags to a pretty string.
  static String tagsToString(final ColorTagBucket tags) {
    final StringBuffer buffer = StringBuffer(
      '<ColorTag>{${tags.isEmpty ? '}' : '\n'}',
    );
    for (final ColorTag tag in tags) {
      buffer.writeln("'$tag',");
    }
    if (tags.isNotEmpty) {
      buffer.writeln('}');
    }
    return buffer.toString();
  }

  /// Representation of a color's tags.
  String get pretty => tagsToString(this);
}

extension PrettifiedEnhancedColorBucket on EnhancedColorBucket {
  /// Transforms a set of enhanced colors to a pretty string.
  static String enhancedColorsToString(final EnhancedColorBucket colors) {
    final StringBuffer buffer = StringBuffer(
      '<ColorName, EnhancedColor>{${colors.isEmpty ? '}' : '\n'}',
    );
    for (final MapEntry<ColorName, EnhancedColor> color in colors.entries) {
      buffer.writeln("'${color.key.toCamelCase}': const ${color.value},");
    }
    if (colors.isNotEmpty) {
      buffer.writeln('}');
    }
    return buffer.toString();
  }

  /// Representation of a set of enhanced colors.
  String get pretty => enhancedColorsToString(this);
}
''';
