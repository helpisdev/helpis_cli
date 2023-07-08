import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart';
import 'package:xml/xml.dart';

import '../commands.dart' as cmd;
import 'models.dart';
import 'serialized_code_contents.dart';
import 'theme.dart';
import 'theme_provider.dart';
import 'utils.dart';
import 'xml.dart';

class ColorGenCommand extends Command<void> with cmd.CommandMixin {
  ColorGenCommand() {
    argParser
      ..addOption(
        'target',
        help: 'The location of the .xml file '
            'that specifies the color properties.',
        defaultsTo: 'assets/color/colors.xml',
      )
      ..addOption(
        'out',
        help: 'The location of the generated code file.',
        defaultsTo: 'lib/src/gen/theme/colors.helpis.dart',
        aliases: <String>['output'],
      )
      ..addOption(
        'name',
        help: 'Application name to use in the generated code.',
        defaultsTo: 'app',
      );
  }

  Future<void> _colorgen() async {
    arguments(argParser: argParser, argResults: argResults);
    final String name = args['name']! as String;
    final String targetPath = join(pwd, args['target']! as String);
    final String outputPath = cmd.maybeTrim(
      subject: join(pwd, args['out']! as String),
      pattern: '/',
      edge: cmd.StringEdge.end,
    );

    final String outputDir = (outputPath.split('/')..removeLast()).join('/');
    if (!exists(outputDir)) {
      createDir(outputDir, recursive: true);
    }

    final String xml = File(targetPath).readAsStringSync();
    final XmlDocument colorsDoc = XmlDocument.parse(xml);

    final EnhancedThemeBucket themes = colorsDoc.extractThemes()..ensureValid();
    final EnhancedTheme? dualTheme = themes.firstWhereOrNull(
      (final EnhancedTheme theme) => themes.any(
        (final EnhancedTheme other) =>
            other.name == theme.name &&
            other.mode == theme.mode.oppositeEnhanced,
      ),
    );

    final String out = '''
// GENERATED CODE FILE -- DO NOT EDIT BY HAND!!!

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:utilities/extensions.dart';

$enhancedColorContents
$colorGroupContents
$enhancedThemeContents

${ThemeTemplate.themeEnum(name, themes)}
${ThemeTemplate.themes(themes)}
${themes.groups}
${ThemeTemplate.themeExtension(name, themes)}
${dualTheme != null ? themeProvider(name, dualTheme.name.toCamelCase) : ''}
''';
    outputPath.write(out);
    _runFixing(outputPath);
  }

  void _runFixing(final String path) {
    executeProcess('dart', args: <String>['format', '--fix', path]);
    executeProcess('dart', args: <String>['fix', '--apply', path]);
    executeProcess('dart', args: <String>['format', '--fix', path]);
  }

  /// Executes [cmd.Command.colorgen]
  @override
  Future<void> run() async => runCommand(command: _colorgen);

  @override
  String get description => cmd.Command.colorgen.description;

  @override
  String get name => cmd.Command.colorgen.name;
}
