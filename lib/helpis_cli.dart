library helpis_cli;

import 'package:args/command_runner.dart';
import 'package:universal_io/io.dart';

import 'src/helpis.dart' as commands;

export 'src/helpis.dart';

Future<void> execute(final List<String> args) async {
  int exitCode = 0; // suppose success

  try {
    final CommandRunner<void> runner = CommandRunner<void>(
      commands.Command.helpis.name,
      commands.Command.helpis.description,
    )
      ..addCommand(
        commands.CreateCommand(),
      )
      ..addCommand(
        commands.ColorGenCommand(),
      )
      ..addCommand(
        commands.CreateStoreCommand(),
      );
    await runner.run(args);
  } on UsageException catch (e) {
    exitCode = 64;
    stderr
      ..write('Error: $e')
      ..write('This is not the intended usage.');
  } on FormatException catch (e) {
    exitCode = 2;
    stderr
      ..write('Error: $e')
      ..write('Wrong format.');
  } on Exception catch (e) {
    exitCode = 1;
    stderr.write(e);
  }

  await _flushThenExit(exitCode);
}

/// ___CODE ORIGINATES FROM VERY GOOD CLI___
/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future<void> _flushThenExit(final int status) async {
  await Future.wait<void>(<Future<void>>[stdout.close(), stderr.close()])
      .then<void>((final _) => exit(status));
}
