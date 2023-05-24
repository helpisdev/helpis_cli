// ignore_for_file: public_member_api_docs

import 'color_group.dart';
import 'models.dart';
import 'utils.dart';

extension ThemeTemplate on EnhancedTheme {
  ColorThemeName get qualifiedName =>
      '$name${mode.name.toPascalCase}Theme'.toPascalCase;

  String get _ungroupedColors {
    final StringBuffer buffer = StringBuffer();
    for (final EnhancedColor color in ungroupedColors.colors.values) {
      for (final ColorTag tag in color.tags) {
        buffer
          ..writeln()
          ..writeln(
            '@override\n'
            'EnhancedColor get ${tag.toCamelCase} => '
            "ungroupedColors.colors['${color.name.toCamelCase}']!;",
          );
      }
    }
    return buffer.toString();
  }

  String get _groups {
    final StringBuffer buffer = StringBuffer();
    for (final ColorGroup group in groups) {
      final String type = '$qualifiedName${group.name.toPascalCase}Group';
      buffer
        ..writeln()
        ..writeln(
          '@override\n'
          '$type get '
          '${group.name.toCamelCase} => '
          'groups.singleWhere((final ColorGroup group) => '
          "group.name == '${group.name}') as $type;",
        );
    }
    return buffer.toString();
  }

  String get _abstractUngroupedColors {
    final StringBuffer buffer = StringBuffer();
    for (final EnhancedColor color in ungroupedColors.colors.values) {
      for (final ColorTag tag in color.tags) {
        buffer
          ..writeln()
          ..writeln(
            'EnhancedColor get ${tag.toCamelCase} => '
            "throw UnimplementedError('This"
            " stub method is not ment to be called directly.',);",
          );
      }
    }
    return buffer.toString();
  }

  String get _abstractGroups {
    final StringBuffer buffer = StringBuffer();
    for (final ColorGroup group in groups) {
      final String type = '${group.name.toPascalCase}Group';
      buffer.writeln(
        '$type get '
        '${group.name.toCamelCase} => '
        "throw UnimplementedError('This"
        " stub method is not ment to be called directly.',);",
      );
    }
    return buffer.toString();
  }

  static String themeExtension(
    final String appName,
    final EnhancedThemeBucket themes,
  ) {
    final String name = appName.toPascalCase;
    final String extensionName = '${name}Colors';
    final String themeName = '${name}Theme';
    return '''
/// Theme color properties of $name.
class $extensionName extends ThemeExtension<$extensionName> {
  const $extensionName(this.theme);

  const $extensionName.withLerp({required this.theme});

  final $themeName<AllTagsAndGroupsEnhancedTheme> theme;

  @override
  $extensionName copyWith() =>
        throw UnsupportedError('copyWith() is not supported.');

  @override
  $extensionName lerp(final $extensionName? other, final double t) {
    if (other is! $extensionName) {
      return this;
    }
    return $extensionName(other.theme);
  }
}

extension CurrentTheme on BuildContext {
  AllTagsAndGroupsEnhancedTheme get currentTheme => Theme.of(this).extension<$extensionName>()!.theme.themeData;
}
''';
  }

  static String themeEnum(
    final String appName,
    final EnhancedThemeBucket themes,
  ) {
    final String name = appName.toPascalCase;
    final StringBuffer themeValues = StringBuffer();

    for (final EnhancedTheme theme in themes) {
      final ColorThemeName type = theme.qualifiedName;
      themeValues
        ..writeln('${type.toCamelCase}<$type>(')
        ..writeln('const $type(')
        ..writeln("name: '${theme.name}',")
        ..writeln('mode: ${theme.mode},')
        ..writeln('groups: ${theme.groups.pretty(theme.qualifiedName)},')
        ..writeln('ungroupedColors: ${theme.ungroupedColors.stringify()},')
        ..writeln('),)${theme == themes.last ? ';' : ','}');
    }

    return '''
enum ${name}Theme<T extends AllTagsAndGroupsEnhancedTheme> {
$themeValues
  const ${name}Theme(final AllTagsAndGroupsEnhancedTheme theme) : _theme = theme;

  final AllTagsAndGroupsEnhancedTheme _theme;

  T get themeData => _theme as T;
}
''';
  }

  static String themes(final EnhancedThemeBucket bucket) {
    final StringBuffer buffer = StringBuffer();
    final EnhancedThemeBucket abstractThemes = <EnhancedTheme>{};

    for (final EnhancedTheme theme in bucket) {
      if (!abstractThemes.any(
        (final EnhancedTheme el) => el.name == theme.name,
      )) {
        abstractThemes.add(theme);
      }
      buffer.write(theme.template);
    }

    final ColorTagBucket allTags = <ColorTag>{};
    final ColorGroupBucket allGroups = <ColorGroup>{};
    for (final EnhancedTheme theme in abstractThemes) {
      for (final EnhancedColor color in theme.ungroupedColors.colors.values) {
        allTags.addAll(color.tags);
      }
      theme.groups.forEach(allGroups.add);
    }

    buffer.write('mixin AllTagsAndGroups {');
    for (final ColorTag tag in allTags) {
      buffer
        ..writeln()
        ..writeln(
          'EnhancedColor get $tag => throw '
          "UnsupportedError('$tag is not supported by the current theme.',);",
        );
    }

    for (final ColorGroup group in allGroups) {
      final String type = '${group.name.toPascalCase}Group';
      buffer
        ..writeln(
          '$type get ${group.name.toCamelCase} => throw '
          "UnsupportedError('${group.name.toCamelCase} is not supported by the "
          "current theme.',);",
        )
        ..writeln();
    }

    buffer.write('''
}

abstract class AllTagsAndGroupsEnhancedTheme extends EnhancedTheme with AllTagsAndGroups {
  const AllTagsAndGroupsEnhancedTheme() : super();
}
''');

    for (final EnhancedTheme theme in abstractThemes) {
      final String abstractThemeName =
          '${theme.name.toPascalCase}EnhancedTheme';
      buffer.write('''
abstract class $abstractThemeName extends AllTagsAndGroupsEnhancedTheme {
  const $abstractThemeName({
    required this.name,
    required this.mode,
    required this.groups,
    required this.ungroupedColors,
  }) : super();

  @override
  final ColorThemeName name;

  @override
  final EnhancedThemeMode mode;

  @override
  final ColorGroupBucket groups;

  @override
  final ColorGroup ungroupedColors;

  ${theme._abstractGroups}
  ${theme._abstractUngroupedColors}
}
''');
    }

    return buffer.toString();
  }

  String get template {
    final String abstractThemeName = '${name.toPascalCase}EnhancedTheme';
    return '''
class $qualifiedName extends $abstractThemeName {
  const $qualifiedName({
    required super.name,
    required super.mode,
    required super.groups,
    required super.ungroupedColors,
  }) : super();

$_ungroupedColors
$_groups
}
''';
  }
}

extension ThemeGroups on EnhancedThemeBucket {
  String get groups {
    final ColorGroupBucket base = <ColorGroup>{};
    final StringBuffer buffer = StringBuffer();

    for (final EnhancedTheme theme in this) {
      for (final ColorGroup group in theme.groups) {
        if (!base.any((final ColorGroup el) => el.name == group.name)) {
          base.add(group);
          buffer.writeln(group.generateBase());
        }
        buffer.writeln(group.generate(theme));
      }
    }

    return buffer.toString();
  }
}
