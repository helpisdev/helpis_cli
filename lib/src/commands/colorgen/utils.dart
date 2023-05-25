import 'models.dart';

extension Utils on String {
  static const String _hexValidNumbers = '0-9a-fA-F';
  static final RegExp _hexPattern = RegExp(
    '#([$_hexValidNumbers]{8}|[$_hexValidNumbers]{6}|[$_hexValidNumbers]{3})',
  );

  String get toHex {
    if (!_hexPattern.hasMatch(this)) {
      throw FormatException('Invalid HEX format: $this');
    }

    final String removeHashtag = replaceFirst('#', '');
    String res = removeHashtag;
    if (removeHashtag.length == 8) {
      // Hex format in Flutter uses alpha transparency in the beginning, while
      // FlexColorScheme and in general other generators put alpha transparency
      // in the end. We assume it is in the end, so we flip it. Maybe add
      // parameter?
      final String opacity = removeHashtag.substring(6);
      final String value = removeHashtag.substring(0, 6);
      res = '$opacity$value';
    }

    return res.padLeft(8, '0');
  }

  /// Tranforms a [String] to camelCase.
  String get toCamelCase => split('-')
      .map((final String e) => e.split('_'))
      .expand((final List<String> e) => e)
      .map((final String e) => e.toFirstCapital)
      .join()
      .toFirstLower;

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

extension MatchingTags on Iterable<EnhancedColor> {
  bool match(final Iterable<EnhancedColor> colors) {
    final ColorTagBucket tags = <ColorTag>{};
    final ColorTagBucket otherTags = <ColorTag>{};

    for (final EnhancedColor color in this) {
      tags.addAll(color.tags);
    }

    for (final EnhancedColor color in colors) {
      otherTags.addAll(color.tags);
    }

    return tags.every(otherTags.contains);
  }
}

extension Uniquetags on EnhancedColor {
  void ensureUniqueTags() {
    final ColorTagBucket unique = <ColorTag>{};
    for (final ColorTag tag in tags) {
      if (!unique.any((final ColorTag el) => el == tag)) {
        unique.add(tag);
      } else {
        throw StateError('Duplicate tag "$tag" in $name color.');
      }
    }
  }
}

// ColorThemeName, ColorGroupName, ColorName, ColorTag
extension NameValidation on String {
  static const String _regex = r'^([a-zA-Z_$][a-zA-Z_$0-9]*)$';

  void validate() {
    if (!RegExp(_regex).hasMatch(this)) {
      throw StateError(
        'Property name "$this" must be a valid Dart identifier.',
      );
    }
  }
}

extension EnhancedThemeBucketValidation on EnhancedThemeBucket {
  void ensureValid() {
    final List<EnhancedTheme> themeList = toList();
    for (int i = 0; i < themeList.length - 1; ++i) {
      final EnhancedTheme curTheme = themeList[i];
      themeList
          .sublist(i + 1, themeList.length)
          .where((final EnhancedTheme theme) => theme.name == curTheme.name)
          .forEach(curTheme.ensurePropertyMatching);
    }
  }
}

extension EnhancedThemeValidation on EnhancedTheme {
  void ensurePropertyMatching(final EnhancedTheme other) {
    if (other.name == name) {
      bool ungroupedPropertiesMatch = true;
      bool groupedPropertiesMatch = true;
      bool groupsMatch = true;

      if (!other.ungroupedColors.colors.values
          .match(ungroupedColors.colors.values)) {
        ungroupedPropertiesMatch = false;
      }

      if (ungroupedPropertiesMatch) {
        for (final ColorGroup group in groups) {
          if (!other.groups.any(
            (final ColorGroup otherGroup) => otherGroup.name == group.name,
          )) {
            groupsMatch = false;
            break;
          }
          final ColorGroup otherGroup = other.groups.singleWhere(
            (final ColorGroup otherGroup) => otherGroup.name == group.name,
          );
          if (!otherGroup.colors.values.match(group.colors.values)) {
            groupedPropertiesMatch = false;
            break;
          }
        }
      }

      if (ungroupedPropertiesMatch && groupedPropertiesMatch && groupsMatch) {
        return;
      }

      throw UnsupportedError(
        'Themes of the same name with independent tags and '
        'groups are not currenlty supported.',
      );
    }
  }
}
