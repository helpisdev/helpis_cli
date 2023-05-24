import 'package:helpis_cli/src/commands/colorgen/theme.dart';

import 'models.dart';
import 'utils.dart';

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

extension GroupGeneration on ColorGroup {
  String get _baseGroupName => '${name.toPascalCase}Group';
  String _qualifiedGroupName(final EnhancedTheme theme) =>
      '${theme.qualifiedName}$_baseGroupName';

  String get _stubMessage => "=> throw UnimplementedError('This stub method is "
      "not ment to be called directly.',);";

  String _colorGetter(final ColorTag tag) =>
      'EnhancedColor get ${tag.toCamelCase}';

  String generateBase() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('abstract class $_baseGroupName extends ColorGroup {')
      ..writeln(
        'const $_baseGroupName(super.name, {super.colors,}) : super();',
      )
      ..writeln();

    for (final EnhancedColorRegistrar color in colors.entries) {
      for (final ColorTag tag in color.value.tags) {
        buffer
          ..writeln('${_colorGetter(tag)} $_stubMessage')
          ..writeln();
      }
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  String generate(final EnhancedTheme theme) {
    final String qualifiedGroupName = _qualifiedGroupName(theme);
    final StringBuffer buffer = StringBuffer()
      ..writeln('class $qualifiedGroupName extends $_baseGroupName {')
      ..writeln(
        'const $qualifiedGroupName(super.name, {super.colors,}) : super();',
      )
      ..writeln();

    for (final EnhancedColorRegistrar color in colors.entries) {
      final String colorName = color.key;
      for (final ColorTag tag in color.value.tags) {
        buffer
          ..writeln('@override')
          ..writeln("${_colorGetter(tag)} => super.colors['$colorName']!;")
          ..writeln();
      }
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}
