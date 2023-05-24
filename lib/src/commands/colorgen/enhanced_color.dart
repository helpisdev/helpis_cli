import 'models.dart';
import 'utils.dart';

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

extension PrettifiedEnhancedColorBucket on EnhancedColorRegistry {
  /// Transforms a set of enhanced colors to a pretty string.
  static String enhancedColorsToString(final EnhancedColorRegistry colors) {
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
