// import 'package:flutter/material.dart';

import 'enhanced_color.dart';
import 'utils.dart';

/// Signature for the integer value of a color.
typedef ColorValue = int;

/// Signature for a string representing a color name.
typedef ColorName = String;

/// Signature for a string representing a color tag.
typedef ColorTag = String;

/// Signature for a set of color tags.
typedef ColorTagBucket = Set<ColorTag>;

/// Signature for a set of enhanced colors.
typedef EnhancedColorRegistry = Map<ColorName, EnhancedColor>;

/// Signature for an entry in a [EnhancedColorRegistry].
typedef EnhancedColorRegistrar = MapEntry<ColorName, EnhancedColor>;

/// A color with an attached value and a list of identifiers.
class EnhancedColor {
  /// Attaches a provided name and various identifiers to a color.
  const EnhancedColor(
    this.value, {
    required this.name,
    final ColorTagBucket? tags,
  }) : tags = tags ?? const <ColorTag>{};

  /// Value of the color.
  final ColorValue value;

  /// Name of the color.
  final ColorName name;

  /// List of color identifiers.
  final ColorTagBucket tags;

  @override
  String toString() =>
      "EnhancedColor(${value.toHex}, name: '${name.toCamelCase}', "
      'tags: ${tags.pretty},)';
}

/// Signature for a string representing a color group name.
typedef ColorGroupName = String;

/// Signature for a set of color group names.
typedef ColorGroupNameBucket = Set<ColorGroupName>;

/// Signature for a set of color groups.
typedef ColorGroupBucket = Set<ColorGroup>;

/// A named [EnhancedColorRegistry].
class ColorGroup {
  /// Attaches a name to an [EnhancedColorRegistry].
  const ColorGroup(
    this.name, {
    final EnhancedColorRegistry? colors,
  }) : colors = colors ?? const <ColorName, EnhancedColor>{};

  /// Group's name.
  final ColorGroupName name;

  /// Group's associated colors.
  final EnhancedColorRegistry colors;

  /// Converts class to a [String] with an optional prefix.
  String stringify([final ColorThemeName? prefix]) =>
      "${prefix != null ? '$prefix${name.toPascalCase}' : 'Color'}"
      "Group('$name', colors: ${colors.pretty},)";
}

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

  /// The opposite [EnhancedThemeMode].
  EnhancedThemeMode get oppositeEnhanced => this == dark ? light : dark;

  /// Transforms a [String] to a valid [EnhancedThemeMode].
  static EnhancedThemeMode of(final String? name) {
    if (name == null || name.isEmpty) {
      throw StateError('Theme mode name must a non-empty non-null value.');
    }
    return switch (name.toLowerCase()) {
      'light' => light,
      'dark' => dark,
      _ => throw UnsupportedError('Theme mode must either be light or dark.'),
    };
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

class EnhancedThemeProxy extends EnhancedTheme {
  const EnhancedThemeProxy({
    required this.groups,
    required this.mode,
    required this.name,
    required this.ungroupedColors,
  }) : super();

  @override
  final ColorGroupBucket groups;

  @override
  final EnhancedThemeMode mode;

  @override
  final ColorThemeName name;

  @override
  final ColorGroup ungroupedColors;
}
