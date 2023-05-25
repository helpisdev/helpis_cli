import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_console/dart_console.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

/// Helpis cli command argument definition
typedef HelpisCommand = Future<void> Function();

/// Provides a helper interface for all helpis cli commands
mixin CommandMixin {
  /// Console controller
  final Console console = Console();

  /// Arguments processed
  late Map<String, Object?> args;

  /// Executes a specified process with an optional list of arguments and
  /// displays progress.
  void executeProcess(
    final String process, {
    final List<String>? args,
    final bool detached = false,
  }) {
    '$process ${(args ?? <String>[]).join(' ')}'.start(
      runInShell: true,
      detached: detached,
      progress: Progress.print(),
    );
  }

  /// Executes a mason brick with a provided config.json
  void runMason({required final String brick, final String? path}) {
    final String config =
        path ?? (join(pwd, 'config.json')..write(jsonEncode(args)));
    executeProcess(
      'mason',
      args: <String>[
        'make',
        brick,
        '-c',
        'config.json',
        '--on-conflict',
        'overwrite',
      ],
    );
    delete(config);
    delete(join(pwd, 'mason.yaml'));
    delete(join(pwd, 'mason-lock.json'));
  }

  /// Activates a provided brick
  void activateBrick({
    required final String brickName,
    final bool local = true,
    final String? path,
  }) {
    executeProcess('mason', args: <String>['init']);
    executeProcess(
      'mason',
      args: <String>[
        'add',
        brickName,
        if (local) ...<String>[
          '--path',
          path ?? '$pwd${separator}mason_templates$separator$brickName',
        ]
      ],
    );
  }

  /// Initializes arguments with default and provided options
  void arguments({
    required final ArgParser argParser,
    final ArgResults? argResults,
    final Map<String, Object?>? predefinedDefaults,
  }) {
    final Map<String, Object?> defaults =
        predefinedDefaults ?? <String, Object?>{};
    final List<String> parameters = argResults?.arguments ?? <String>[];

    for (final MapEntry<String, Option> def in argParser.options.entries) {
      defaults[def.key] = def.value.defaultsTo;
    }

    bool shouldExit = false;
    final Map<String, Object?> result = defaults;
    for (int i = 0; i < parameters.length; ++i) {
      String key = parameters[i];

      Object? arg;
      if (key.contains('=')) {
        final List<String> separation = key.split('=');
        key = separation[0];
        arg = separation[1];
      }

      if (key.startsWith('--')) {
        key = key.replaceFirst('--', '');
      } else if (key.startsWith('-')) {
        key = key.replaceFirst('-', '');
        key = argParser.options.entries
            .firstWhere(
              (final MapEntry<String, Option> element) =>
                  element.value.abbr == key,
              orElse: () {
                console
                  ..writeLine('Did not find argument key: $key.')
                  ..writeLine('Wrong format.');
                shouldExit = true;
                return MapEntry<String, Option>(
                  key,
                  argParser.options.values.first,
                );
              },
            )
            .value
            .name;
      } else {
        continue;
      }

      if (shouldExit) {
        exit(-1);
      }

      if (arg == null) {
        if (i + 1 < parameters.length) {
          final String next = parameters[i + 1];
          if (!next.startsWith('-')) {
            arg = parameters[i + 1];
          } else {
            arg = 'true';
          }
        } else {
          arg = 'true';
        }
      }

      final String parsedArg = arg.toString();
      final bool isStringWithSpaces = parsedArg.contains(' ');
      if (parsedArg.contains(',') && !isStringWithSpaces) {
        result[key] = parsedArg.split(',');
      } else {
        result[key] = arg;
      }
    }

    args = result;
  }

  /// Runs the command and prints success message
  Future<void> runCommand({required final HelpisCommand command}) async {
    await command();
    console.writeLine('Completed successfully.');
  }
}
