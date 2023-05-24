import 'dart:async';
import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart';

import 'command_mixin.dart';
import 'commands_enum.dart' as cmd;
import 'templates/android.dart';
import 'templates/arb.dart';
import 'templates/ios.dart';
import 'templates/linux_config.dart';
import 'templates/macos.dart';
import 'templates/mason_config.dart';
import 'templates/pubspec.dart';
import 'templates/windows.dart';

/// Creates a new project with the internal helpis structure.
class CreateCommand extends Command<void> with CommandMixin {
  /// Adds specific flags to [cmd.Command.create]
  CreateCommand() {
    argParser
      ..addFlag(
        'dart',
        abbr: 'd',
        help: 'Raw Dart project. Defaults to false.',
        negatable: false,
      )
      ..addOption(
        'name',
        abbr: 'n',
        help: "The project's name. The package's name should follow Dart's "
            'naming guidelines.',
        valueHelp: 'my_awesome_project',
        mandatory: true,
      )
      ..addOption(
        'description',
        abbr: 'D',
        help: "The project's description.",
        valueHelp: 'My cool description',
      )
      ..addOption(
        'author',
        abbr: 'a',
        help: 'The name of the code owner.',
        valueHelp: 'John Doe',
      )
      ..addOption(
        'authorUsername',
        abbr: 'A',
        help: 'The user github handle.',
        valueHelp: 'helpisdev',
      )
      ..addOption(
        'version',
        abbr: 'v',
        defaultsTo: '1.0.0+1',
        help: "The project's version",
        valueHelp: '0.21.7-0.beta+1.3324',
      )
      ..addOption(
        'repository',
        abbr: 'r',
        help: "The project's repository.",
        valueHelp: 'https://github.com/author/my_project',
      )
      ..addOption(
        'homepage',
        abbr: 'H',
        help: "The project's homepage.",
        valueHelp: 'https://my_project.github.io',
      )
      ..addOption(
        'org',
        abbr: 'o',
        help: 'The organization domain. Used for bundle IDs.',
        valueHelp: 'com.example',
      )
      ..addOption(
        'revolt',
        abbr: 'R',
        help: 'The Revolt chat server for the project.',
        valueHelp: 'revolt.example.com/my_project',
      )
      ..addOption(
        'IDE',
        abbr: 'i',
        help: 'Choose your development IDE. Defaults to "idea"',
        defaultsTo: 'vscode',
        allowedHelp: <String, String>{
          'idea': 'Android Studio',
          'vscode': 'Visual Studio Code'
        },
        valueHelp: 'idea|vscode',
      )
      ..addMultiOption(
        'platforms',
        abbr: 'p',
        help: 'Platforms to configure',
        allowedHelp: <String, String>{
          'web': 'Support for the web platform',
          'linux': 'Support for the linux platform',
          'windows': 'Support for the windows platform',
          'macos': 'Support for the macos platform',
          'android': 'Support for the android platform',
          'ios': 'Support for the ios platform',
        },
        defaultsTo: <String>[
          'android',
          'ios',
          'web',
          'windows',
          'macos',
          'linux',
        ],
        valueHelp: 'android,ios',
      )
      ..addMultiOption(
        'submodules',
        abbr: 's',
        help: 'Packages configured as Git submodules. If the module starts '
            'with "http", then it is added as a url, otherwise it is treated '
            'as a local git repository and `git init` is run in it. Submodules '
            'are added under "packages/features/". To specify a different '
            'path, separate the module with a pipe (|) and the path.',
        valueHelp: 'https://github.com/usr/module|pckgs/feats/mod,'
            'module,'
            'https://github.com/user/mod,'
            'submodule|path',
      )
      ..addMultiOption(
        'flavors',
        abbr: 'f',
        help: 'Generate different flavors for the package.',
        valueHelp: 'development,production',
      )
      ..addMultiOption(
        'locales',
        abbr: 'L',
        help: 'Translation locales used in the project '
            'to generate template .arb files.',
        valueHelp: 'en,el',
        defaultsTo: <String>['en'],
      );
  }

  void _setup() {
    final List<String> activate = <String>['pub', 'global', 'activate'];

    executeProcess('dart', args: <String>[...activate, 'melos']);
    executeProcess('dart', args: <String>[...activate, 'derry']);
    executeProcess('dart', args: <String>[...activate, 'mason']);
    executeProcess('dart', args: <String>[...activate, 'mason_cli']);
    executeProcess('dart', args: <String>[...activate, 'webdev']);
    if (!isDart) {
      executeProcess('dart', args: <String>[...activate, 'flutter_gen']);
    }
  }

  void _initGit() {
    executeProcess('git', args: <String>['init']);
    executeProcess('git', args: <String>['checkout', '-b', 'main']);
    executeProcess('git', args: <String>['add', '.']);
    executeProcess('git', args: <String>['commit', '-m', '"Initial commit"']);
  }

  List<String> _initGitSubmodules() {
    final List<String> submodulePaths = <String>[];
    for (final dynamic s in submodules) {
      final List<String> subAndMaybePath = s.toString().split('|');
      final String submodule = subAndMaybePath.first;
      final String path = maybeTrim(
        // either the specified path or the submodule if no path is specified
        subject: subAndMaybePath.last,
        pattern: '/',
        edge: StringEdge.end,
      );
      if (submodule.isUrl) {
        final String packageName = maybeTrim(
          subject: path.split('/').last,
          pattern: '.git',
          edge: StringEdge.end,
        ).split('-').first;
        final String providedPathOrDefault = path.isUrl
            ? 'packages/features/$packageName'
            : maybeTrim(subject: path, pattern: './');
        executeProcess(
          'git',
          args: <String>[
            'submodule',
            'add',
            submodule,
            providedPathOrDefault,
          ],
        );
        submodulePaths.add(providedPathOrDefault);
      } else {
        final String providedPathOrDefault = path == submodule
            ? 'packages/features/$submodule'
            : maybeTrim(subject: path, pattern: './');
        _initModuleAsLocalPackage(
          path: providedPathOrDefault,
          submodule: submodule.split('/').last,
        );
        submodulePaths.add(providedPathOrDefault);
      }
    }
    try {
      executeProcess(
        'git',
        args: <String>['submodule', 'foreach', "'git checkout main'"],
      );
    } on Exception catch (e) {
      _onError(e);
    }
    return submodulePaths;
  }

  void _initModuleAsLocalPackage({
    required final String submodule,
    required final String path,
  }) {
    final String projectRootDir = Directory.current.path;
    final String submoduleDir = join(Directory.current.path, path);
    createDir(submoduleDir, recursive: true);
    Directory.current = submoduleDir;
    executeProcess(
      'flutter',
      args: <String>[
        'create',
        '.',
        '-t',
        'package',
        if (org != null) ...<String>['--org', '$org'],
        '--project-name',
        submodule,
      ],
    );
    _initGit();
    Directory.current = projectRootDir;
    executeProcess(
      'git',
      args: <String>['submodule', 'add', './$path$submodule', './$path'],
    );
  }

  void _configLocalization() {
    final String arbDir = join(pwd, 'assets', 'l10n');
    if (!exists(arbDir)) {
      createDir(arbDir, recursive: true);
    }
    for (final dynamic locale in locales) {
      final String arb = arbTemplate(locale.toString(), _name);
      join(arbDir, 'app_$locale.arb').write(arb);
    }
  }

  Future<void> _runMason() async {
    const String brick = 'project_template';
    executeProcess(
      'git',
      args: <String>[
        'clone',
        'https://github.com/helpisdev/mason_templates.git'
      ],
    );
    final String path = join(pwd, 'config.json')
      ..write(
        jsonEncode(
          mason(
            isDart: isDart,
            flavors: flavors,
            name: _name,
            author: author ?? '',
            username: authorUsername ?? '',
            desc: _description ?? '',
            version: version,
            repo: repository ?? '',
            homepage: homepage ?? '',
            org: org ?? '',
            ide: ide,
            platforms: platforms,
            revolt: revolt ?? '',
          ),
        ),
      );
    activateBrick(brickName: brick);
    runMason(brick: brick, path: path);
    await Directory('$pwd${separator}mason_templates').delete(recursive: true);
    Directory.current = join(pwd, _name);
  }

  void _runMelos() {
    executeProcess('melos', args: <String>['bs']);
    executeProcess('melos', args: <String>['run', 'get']);
    executeProcess('melos', args: <String>['run', 'upgrade']);
    executeProcess('melos', args: <String>['run', 'upgrade:major']);

    // Run flutter clean && flutter packages pub get again in order for
    // build_runner to work with flutter_gen when using `generate: true` in
    // pubspec.yaml and `synthetic-package: false` in l10n.yaml
    // So far this is the only automated solution that works as tracked here:
    // https://github.com/dart-lang/build/issues/2835
    executeProcess('melos', args: <String>['run', 'flutter:clean']);
    executeProcess('melos', args: <String>['run', 'get']);
  }

  void _config() {
    if (!isDart) {
      final List<String> configPlatforms = platforms.map(
        (final dynamic e) {
          String platform = '--enable-$e';
          if (platform.contains('macos') ||
              platform.contains('linux') ||
              platform.contains('windows')) {
            platform += '-desktop';
          }
          return platform;
        },
      ).toList();
      final _PlatformDependentConfig p = _PlatformDependentConfig(
        version: version,
        ide: ide,
        name: _name,
        description: _description,
        org: org,
        repository: repository,
        homepage: homepage,
        isDart: isDart,
        locales: locales,
        flavors: flavors,
        submodules: submodules,
        platforms: platforms,
      );
      executeProcess(
        'flutter',
        args: <String>[
          'config',
          ...configPlatforms,
          '--single-widget-reload-optimization',
        ],
      );
      executeProcess(
        'flutter',
        args: <String>[
          'create',
          '.',
          '--platforms=${platforms.join(',')}',
          if (org != null) ...<String>['--org', '$org'],
          '--project-name',
          _name,
        ],
      );
      if (platforms.contains('linux')) {
        p.linux();
      }
      if (platforms.contains('android')) {
        unawaited(p.android());
      }
      if (platforms.contains('ios')) {
        p.ios();
      }
      if (platforms.contains('macos')) {
        p.macos();
      }
      if (platforms.contains('windows')) {
        p.windows();
      }
    } else {
      executeProcess('dart', args: <String>['create', '.', '--force']);
    }
  }

  void _runCodeGen() {
    executeProcess('derry', args: <String>['gen:build:complete']);

    if (!isDart) {
      if (flavors.isNotEmpty) {
        executeProcess('derry', args: <String>['flavors']);
      }

      executeProcess('flutter', args: <String>['gen-l10n']);
      executeProcess(
        'flutter',
        args: <String>['pub', 'run', 'icons_launcher:create'],
      );
      try {
        executeProcess('fluttergen');
      } on Exception catch (e) {
        _onError(e, customMessage: 'fluttergen failed with message:');
      }
      join('android', 'app', 'build.gradle').write(
        _PlatformDependentConfig(
          version: version,
          ide: ide,
          name: _name,
          description: _description,
          org: org,
          repository: repository,
          homepage: homepage,
          isDart: isDart,
          locales: locales,
          flavors: flavors,
          submodules: submodules,
          platforms: platforms,
        ).appLevelBuildGradle,
      );
      executeProcess('helpis', args: <String>['colorgen', '-n', _name]);
    }
  }

  void _runApp() {
    if (!isDart) {
      String platform = Platform.isWindows
          ? 'windows'
          : Platform.isMacOS
              ? 'macos'
              : 'linux';

      if (platforms.isNotEmpty) {
        if (!platforms.contains(platform)) {
          if (platforms.contains('android')) {
            platform = 'android';
          } else if (platforms.contains('ios')) {
            platform = 'ios';
          } else {
            platform = 'web';
          }
        }
        executeProcess('flutter', args: <String>['run', '-d', platform]);
      }
    } else {
      executeProcess('dart', args: <String>['run']);
    }
  }

  void _runFixing() {
    executeProcess('melos', args: <String>['run', 'format:fix']);
    executeProcess('melos', args: <String>['run', 'fix']);
  }

  void _createBinDir() {
    if (isDart) {
      final String bin = '$pwd/bin';
      if (!exists(bin)) {
        createDir(bin, recursive: true);
      }
    }
  }

  Future<void> _create() async {
    _configArguments();
    _setup();
    await _runMason();
    _createBinDir();
    _config();
    _initGit();
    _configLocalization();
    pubspecTemplate(
      submodules: _initGitSubmodules(),
      name: _name,
      org: org,
      description: _description,
      repository: repository,
      homepage: homepage,
      version: version,
      ide: ide,
      flavors: flavors,
      isDart: isDart,
    );
    _runMelos();
    _runCodeGen();
    _runFixing();
    _runApp();
  }

  void _configArguments() {
    arguments(argParser: argParser, argResults: argResults);

    final Object? flvrs = args['flavors'];
    if (flvrs != null && flvrs is List && flvrs.isNotEmpty) {
      flavors = flvrs;
    }

    final Object? submods = args['submodules'];
    if (submods is String) {
      args['submodules'] = <String>[submods];
    }

    isDart = args['dart'] as bool? ?? false;
    _name = args['name']?.toString() ?? '';
    org = args['org']?.toString();
    _description = args['description']?.toString();
    repository = args['repository']?.toString();
    author = args['author']?.toString();
    authorUsername = args['authorUsername']?.toString();
    revolt = args['revolt']?.toString();
    homepage = args['homepage']?.toString();
    version = args['version']?.toString() ?? '0.1.0';
    ide = args['IDE']?.toString() ?? '';
    submodules = (args['submodules'] ?? <String>[]) as List<dynamic>;
    locales = (args['locales'] ?? <String>[]) as List<dynamic>;
    platforms = args['platforms'] as List<dynamic>? ?? <String>[];
  }

  @override
  Future<void> run() async => runCommand(command: _create);

  @override
  String get description => cmd.Command.create.description;

  @override
  String get name => cmd.Command.create.name;

  late final String version;
  late final String ide;
  late final String _name;
  late final String? _description;
  late final String? org;
  late final String? repository;
  late final String? homepage;
  late final String? author;
  late final String? authorUsername;
  late final String? revolt;
  late final bool isDart;
  late final List<dynamic> locales;
  late final List<dynamic> flavors;
  late final List<dynamic> submodules;
  late final List<dynamic> platforms;
}

class _PlatformDependentConfig {
  _PlatformDependentConfig({
    required this.version,
    required this.ide,
    required this.name,
    required this.description,
    required this.org,
    required this.repository,
    required this.homepage,
    required this.isDart,
    required this.locales,
    required this.flavors,
    required this.submodules,
    required this.platforms,
  });

  final String version;
  final String ide;
  final String name;
  final String? description;
  final String? org;
  final String? repository;
  final String? homepage;
  final bool isDart;
  final List<dynamic> locales;
  final List<dynamic> flavors;
  final List<dynamic> submodules;
  final List<dynamic> platforms;

  void windows() {
    final String runnerPath = 'windows${separator}runner';
    if (!exists(runnerPath)) {
      createDir('windows${separator}runner', recursive: true);
    }
    const String win32prefix = 'win32_window';
    join(runnerPath, '$win32prefix.h').write(windowsWin32WindowsHeader);
    join(runnerPath, '$win32prefix.cpp').write(windowsWin32WindowsCpp);
  }

  void linux() => configLinux(name);

  Future<void> android() async {
    try {
      await File(join('android', 'gradle.properties')).delete();
      join('android', 'key.properties').write(keyProperties);
      join('android', 'proguard-rules.pro').write(proguardRules);
      join('android', 'settings.gradle').write(settingsGradle);
      join('android', 'build.gradle').write(topLevelBuildGradle);
      join('android', 'gradle', 'wrapper', 'gradle-wrapper.properties').write(
        gradleWrapperProperties,
      );
      join('android', 'app', 'src', 'main', 'AndroidManifest.xml').write(
        androidManifest(name: name, org: org),
      );
    } on Exception catch (e) {
      _onError(e);
    }
  }

  void ios() {
    final String iOS = join(pwd, 'ios');
    join(iOS, 'Podfile').write(iOSPodfile);
    final String runner = join(iOS, 'Runner');
    if (!exists(runner)) {
      createDir(runner, recursive: true);
    }
    join(runner, 'Info.plist').write(iOSInfoPlist(locales));
  }

  void macos() {
    join('macos', 'Podfile').write(macOSPodfile);
    join('macos', 'Runner', 'Release.entitlements').write(
      macOSReleaseEntitlements,
    );
    join('macos', 'Runner', 'Info.plist').write(macOSInfoPlist(name));
    join('macos', 'Runner', 'DebugProfile.entitlements').write(
      macOSDebugEntitlements,
    );
  }

  String get appLevelBuildGradle => appLevelBuildGradleConfig(
        flavors: flavors,
        name: name,
        org: org,
      );
}

void _onError(final Exception e, {final String customMessage = ''}) {
  stderr
    ..writeln(customMessage)
    ..writeln(e.toString());
}

String maybeTrim({
  required final String subject,
  required final String pattern,
  final StringEdge edge = StringEdge.start,
}) {
  switch (edge) {
    case StringEdge.start:
      if (subject.startsWith(pattern)) {
        return subject.substring(pattern.length);
      }
      break;
    case StringEdge.end:
      if (subject.endsWith(pattern)) {
        return subject.substring(0, subject.length - pattern.length);
      }
      break;
    case StringEdge.both:
      final StringBuffer mutatedSubject = StringBuffer(subject);
      if (subject.startsWith(pattern)) {
        mutatedSubject
          ..clear()
          ..write(subject.substring(pattern.length));
      }
      if (subject.endsWith(pattern)) {
        final String snapshot = mutatedSubject.toString();
        mutatedSubject
          ..clear()
          ..write(
            subject.substring(
              subject.length - snapshot.length,
              subject.length - pattern.length,
            ),
          );
      }
      return mutatedSubject.toString();
  }
  return subject;
}

enum StringEdge {
  start,
  end,
  both;
}

extension _Utils on String {
  // https://regex101.com/r/UPmLBl/1
  // https://stackoverflow.com/questions/59444837/flutter-dart-regex-to-extract-urls-from-a-string
  // Accepted answer from user: https://stackoverflow.com/users/229044/user229044
  static final RegExp _urlPattern = RegExp(
    r'''\s*((?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?:(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-zA-Z0-9\u00a1-\uffff]+-?)*[a-zA-Z0-9\u00a1-\uffff]+)(?:\.(?:[a-zA-Z0-9\u00a1-\uffff]+-?)*[a-zA-Z0-9\u00a1-\uffff]+)*(?:\.(?:[a-zA-Z\u00a1-\uffff]{2,})))|localhost)(?::\d{2,5})?(?:\/(?:[/._\-#a-zA-Z0-9\u00a1-\uffff]*)*)?)''',
  );
  bool get isUrl => _urlPattern.hasMatch(this);
}
