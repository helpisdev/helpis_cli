/// Available helpis commands
enum Command {
  /// Provides an interface for common commands used in helpis
  helpis,

  /// This CLI command is used to create a new dart project based on the
  /// structure used internally in helpis.
  create,

  /// Creates a storage cache with shared preferences
  createStore,

  /// Creates aliases for FlexColorScheme colors from an XML asset file
  colorgen;
}

/// Extends [Command] by providing descriptions
extension Description on Command {
  /// Returns the help [description] of a [Command]
  String get description => switch (this) {
        Command.helpis => 'Generator for useful templates.',
        Command.create => 'Creates a new configurable structured project.',
        Command.createStore =>
          'Creates a storage cache using shared preferences.',
        Command.colorgen => '''
Creates aliases and theming features for FlexColorScheme colors from an XML asset file.

It assumes that color values are in valid HEX format, starting with a '#'.
HEX values can either be 3, 6, or 8 characters long, excluding the '#'.
Supported characters include 'A-Fa-f0-9'. If the color is 8 characters, the
generator assumes that the two last characters represent the alpha transparency
of the color.

Valid xml tags include:
- resources, which is the top level node. Its presence is mandatory.
- theme, which must be a direct child of 'resources'. Multiple theme elements
  are allowed, as long as their attributes do not match (i.e.: cannot have the
  same 'name' AND 'mode' attributes - at least one must differ). Supported theme
  attributes include:
    - name, the name of the theme,
    - mode, which can be either 'dark' or 'light'.
- group, which must be a direct child of a theme element. It must have a unique
  (in each theme) attribute 'name'. If a group is present in a theme of one
  mode, it must also be present in the other theme mode, if specified. Groups
  and themes are identified by their 'name' attribute.
- color, which must be a direct child of a group or a theme element. It must
  enclose a valid HEX value, as described above. Color must have a 'name'
  attribute, which must be unique. It can also include an optional 'tags'
  attribute, which specifies an identifier from which the color value can be
  retrieved. If no tag is specified, the 'name' attribute will be used as an
  identifier instead. Identifiers must be unique. Tag identifiers are separated
  by whitespace.

'name' and 'tags' must be valid Dart identifiers.

Example:

<?xml version="1.0" encoding="utf-8"?>
<resources>
  <theme name="appTheme" mode="light">
    <!-- ungrouped colors -->
    <color tags="primary surfaceTint" name="white">#ffffff</color>
    <color name="untagged">#12ABCC</color>
    <group name="themeData">
      <!--
        Tag names in a group won't clash with ungrouped colors or colors in
        other groups. In a sense they are namespaced.
      -->
      <color tags="primary elevatedButton" name="black">#000</color>
      <color tags="secondary" name="blackWithOpacity">#000000cc</color>
      <!--
        The following would be invalid - a color name must be unique
        i.e. not be specified twice.
        If you need to assign a color value to multiple tags in the same
        group, include them in a single entry, separated by whitespace.
        <color tags="tertiary" name="blackWithOpacity">#000000cc</color>
      -->
    </group>
  </theme>
  <theme name="appTheme" mode="dark">
    <color tags="primary surfaceTint" name="black">#000</color>
    <color name="untagged">#12ABCC</color>
    <group name="themeData">
      <color tags="primary elevatedButton" name="white">#fff</color>
      <color tags="secondary" name="whiteWithOpacity">#FFFFFFee</color>
    </group>
  </theme>
</resources>
''',
      };
}
