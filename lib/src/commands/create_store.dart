import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

import 'colorgen/utils.dart';
import 'commands.dart' as commands;

/// Creates a storage cache with shared_preferences.
class CreateStoreCommand extends Command<void> with commands.CommandMixin {
  /// Adds specific flags to [commands.Command.createStore]
  CreateStoreCommand() {
    argParser
      ..addFlag(
        'unedited',
        help: "Use this flag to use the app's name unedited.",
        negatable: false,
      )
      ..addOption(
        'name',
        defaultsTo: 'App',
        help: "The project's name. Used in naming classes and fields. "
            '\nInterpreted as PascalCase. Can be overridden using the -u flag.',
        valueHelp: 'AppName',
      )
      ..addOption(
        'part',
        help: r'''Use this option to add a 'part of __$part__' directive.''',
        valueHelp: 'helpis',
      )
      ..addOption(
        'target',
        help: 'The path to generate the dart file.',
        valueHelp: 'lib/src/service/cache',
        defaultsTo: 'lib/src/service/cache',
      )
      ..addMultiOption(
        'imports',
        help: 'User defined imports.',
        defaultsTo: <String>[],
        valueHelp: 'package:flutter/material.dart',
      )
      ..addMultiOption(
        'keys',
        defaultsTo: <String>['isDarkMode-true', "locale-'en'"],
        help: 'Storage retrieval keys. '
            'You can specify a default value by appending a - and the value.',
        valueHelp: "isDarkMode-true,locale-'en'",
      );
  }

  late final String appName;
  late final String target;
  late final String? part;
  late final List<Map<String, Object?>>? keys;
  late final List<String>? imports;

  /// Generates the storage dart code
  Future<void> _createStore() async {
    final StringBuffer buffer = StringBuffer();
    _arguments();
    final String name = args['name'].toString();
    part = args['part']?.toString();
    appName = bool.tryParse(args['unedited'].toString()) ?? false
        ? name
        : name.toPascalCase;
    keys = args['keys'] as List<Map<String, Object?>>?;
    if (args['imports'] is String) {
      args['imports'] = <String>[(args['imports'] as String?)!];
    }
    imports = args['imports'] as List<String>?;
    buffer
      ..writeln(_imports())
      ..writeln(_controller());
    target = (args['target'] as String?)!;
    if (!exists(target)) {
      createDir(target, recursive: true);
    }
    join(target, 'storage_service.helpis.dart').write(buffer.toString());
    executeProcess('dart', args: <String>['format', 'lib']);
  }

  /// Required imports
  String _imports() {
    final StringBuffer import = StringBuffer('''
library storage_service;

import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
''');
    for (final String i in imports ?? <String>[]) {
      import
        ..write("import '")
        ..write(i)
        ..write("';");
    }

    import
      ..writeln()
      ..writeln("export 'storage_service.helpis.dart';");

    if (part != null) {
      import
        ..clear()
        ..writeln('part of $part;');
    }

    return import.toString();
  }

  /// Constructs translations controller
  String _controller() {
    final StringBuffer buffer = StringBuffer()..writeln('''
/// Caching service
class StorageService {
  /// Storage instance
  factory StorageService.instance() => _instance ??= StorageService._();

  StorageService._();

  /// Initialize shared preferences
  Future<void> init() async {
    _box = await SharedPreferences.getInstance();
  ''');
    for (final Map<String, Object?> pair in keys ?? <Map<String, Object?>>{}) {
      final String storageKey = pair.keys.first;
      final Object? storageValue = pair.values.first;
      final String writeMethod = storageValue == null ? 'write' : 'writeIfNull';
      buffer
        ..writeln(
          'if (!_box!.containsKey(StorageKey.$storageKey.name)) {',
        )
        ..writeln(
          'await _box!.$writeMethod(StorageKey.$storageKey.name, '
          '$storageValue);',
        )
        ..writeln('}')
        ..writeln();
    }
    buffer.writeln(r'''
  }

  SharedPreferences? _box;
  static StorageService? _instance;

  /// Reads a value from the cache
  T? read<T>(final String key) => storage._box?.get(key) as T?;

  /// Writes a value to the cache
  Future<bool> write(final String key, final Object? value) async =>
      storage._box?.write(key, value) ?? Future<bool>.value(false);
}

/// Storage getter
StorageService get storage => StorageService.instance();

typedef ListString = List<String>;

/// Utilities to safely access cache or null
extension SafeReadWrite on SharedPreferences {
  /// Write a value if it doesn't exist already or is null
  Future<bool> writeIfNull(final String key, final Object val) async {
    if (!containsKey(key) || get(key) == null) {
      return write(key, val);
    }

    return false;
  }

  /// Write alias
  Future<bool> write(final String key, final Object? val) async {
    if (val == null) {
      // Assigning null is not supported, but trying to access a non-existant
      // key will also return null, so we remove the key if it exists.
      if (containsKey(key)) {
        return remove(key);
      }
      return true;
    }
    return switch (val.runtimeType) {
      bool => await setBool(key, bool.parse(val.toString())),
      int => await setInt(key, int.parse(val.toString())),
      double => await setDouble(key, double.parse(val.toString())),
      String => await setString(key, val.toString()),
      ListString => await setStringList(key, val as ListString),
      _ => throw StateError(
          'Unsupported type ${objectRuntimeType(val, 'unknown')}.'
          '\nSupported value types are:'
          '\n  - bool'
          '\n  - int'
          '\n  - double'
          '\n  - String'
          '\n  - List<String>',
        ),
    };
  }
}

/// Keys of cached values
enum StorageKey {
''');
    for (final Map<String, Object?> pair in keys ?? <Map<String, Object?>>{}) {
      buffer
        ..writeln(pair.keys.first)
        ..writeln(',');
    }
    buffer
      ..writeln('}')
      ..writeln();

    return buffer.toString();
  }

  void _arguments() {
    arguments(
      argParser: argParser,
      argResults: argResults,
    );
    final List<Map<String, Object?>> keys = <Map<String, Object?>>[];
    if (args['keys'] is String) {
      args['keys'] = <String>[(args['keys'] as String?)!];
    }
    final List<String> current = args['keys'] as List<String>? ?? <String>[];

    for (final String key in current) {
      final List<String> keyValuePair = key.split('-');
      final String keyName = keyValuePair.first;
      final Object? value = keyValuePair.length == 2 ? keyValuePair.last : null;
      keys.add(<String, Object?>{keyName: value});
    }

    args['keys'] = keys;
  }

  /// Executes [commands.Command.createStore]
  @override
  Future<void> run() async => runCommand(command: _createStore);

  /// The [description] of the command
  @override
  String get description => commands.Command.createStore.description;

  /// The [name] of the command
  @override
  String get name => commands.Command.createStore.name;
}
