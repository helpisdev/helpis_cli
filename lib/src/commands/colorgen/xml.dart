import 'package:xml/xml.dart';

import 'models.dart';
import 'utils.dart';

extension Extraction on XmlDocument {
  EnhancedThemeBucket extractThemes() {
    final EnhancedThemeBucket themes = <EnhancedTheme>{};
    final Iterable<XmlElement> xmlThemes =
        findElements('resources').firstOrNull?.findElements('theme') ??
            <XmlElement>[];

    for (final XmlElement xmlTheme in xmlThemes) {
      final Iterable<XmlElement> xmlGroups = xmlTheme.findElements('group');
      final Iterable<XmlElement> xmlUngrouped = xmlTheme.findElements('color');
      final EnhancedColorRegistry ungroupedColors = extractColors(xmlUngrouped);
      final ColorGroupBucket groups = extractGroups(xmlGroups, xmlTheme);

      final ColorThemeName themeName =
          xmlTheme.getAttribute('name')!.toCamelCase..validate();
      final EnhancedThemeMode mode = EnhancedThemeMode.of(
        xmlTheme.getAttribute('mode'),
      );

      themes.add(
        EnhancedThemeProxy(
          groups: groups,
          mode: mode,
          name: themeName,
          ungroupedColors: ColorGroup('ungrouped', colors: ungroupedColors),
        ),
      );
    }

    return themes;
  }

  ColorGroupBucket extractGroups(
    final Iterable<XmlElement> xmlGroups,
    final XmlElement xmlTheme,
  ) {
    final ColorGroupBucket groups = <ColorGroup>{};
    for (final XmlElement xmlGroup in xmlGroups) {
      final Iterable<XmlElement> xmlColors = xmlGroup.findElements('color');
      final EnhancedColorRegistry colors = extractColors(xmlColors);
      final ColorGroupName groupName =
          xmlGroup.getAttribute('name')!.toCamelCase..validate();
      groups.add(ColorGroup(groupName, colors: colors));
    }

    return groups;
  }

  EnhancedColorRegistry extractColors(final Iterable<XmlElement> xmlColors) {
    final EnhancedColorRegistry colors = <ColorName, EnhancedColor>{};
    for (final XmlElement xmlColor in xmlColors) {
      final ColorName colorName = xmlColor.getAttribute('name')!.toCamelCase
        ..validate();
      final ColorValue colorValue = int.parse(
        xmlColor.innerText.toHex,
        radix: 16,
      );
      final ColorTagBucket colorTags = <ColorTag>{};
      final XmlAttribute? xmlColorTags = xmlColor.getAttributeNode('tags');
      if (xmlColorTags != null) {
        colorTags.addAll(
          xmlColorTags.value
              .split(RegExp(r'\s+'))
              .map((final ColorTag tag) => tag.trim().toCamelCase)
            ..forEach(
              (final ColorTag tag) => tag.validate(),
            ),
        );
      }
      if (colorTags.isEmpty) {
        colorTags.add(colorName);
      }
      colors[colorName] = EnhancedColor(
        colorValue,
        name: colorName,
        tags: colorTags,
      )..ensureUniqueTags();
    }

    return colors;
  }
}
