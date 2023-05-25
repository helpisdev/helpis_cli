// ignore_for_file: leading_newlines_in_multiline_strings

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

void pubspecTemplate({
  required final String name,
  required final String version,
  required final String ide,
  final String? org,
  final String? description,
  final String? repository,
  final String? homepage,
  final List<String> submodules = const <String>[],
  final List<dynamic> flavors = const <String>[],
  final bool isDart = false,
}) {
  const String lvl0 = '\n';
  const String lvl1 = '\n  ';
  const String lvl2 = '\n    ';
  const String lvl3 = '\n      ';
  const String lvl4 = '\n        ';
  final String submods = submodules
      .map((final String path) => '${path.split('/').last}:${lvl2}path: $path')
      .fold('', (final String prev, final String cur) => '$prev$lvl1$cur');
  final String flvrs = flavors
      .map(
        (final Object? flavor) => '$lvl2$flavor:${lvl3}app:${lvl4}name: '
            '$flavor${lvl3}android:${lvl4}applicationId: '
            '"$org.$name"${lvl3}ios:${lvl4}bundleId: "$org.$name"',
      )
      .fold('', (final Object? prev, final String cur) => '$prev$lvl0$cur');
  final String pubspec = '''
name: $name
version: $version
${description != null ? 'description: "$description"' : ''}
${repository != null ? 'repository: "$repository"' : ''}
${homepage != null ? 'homepage: "$homepage"' : ''}
${homepage != null ? 'documentation: "$homepage/docs"' : ''}
${repository != null ? 'issueTracker: "$repository/issues"' : ''}
publish_to: none

# dart pub global activate derry
scripts:
  ${flavors.isNotEmpty ? 'flavors: flutter pub run flutter_flavorizr' : ''}
  ${!isDart ? 'regenerate_goldens: flutter test --update-goldens --tags=golden' : ''}
  gen:build:prepare: "flutter clean && flutter packages pub get"
  gen:build: ${isDart ? 'dart' : 'flutter'} pub run build_runner build --delete-conflicting-outputs
  gen:build:post: flutter pub get
  gen:build:complete: "derry gen:build:prepare && derry gen:build && derry gen:build:post"
  gen:watch: ${isDart ? 'dart' : 'flutter'} pub run build_runner watch --delete-conflicting-outputs
  git:init: derry git:pull && derry git:submodule:init
  git:push: git push --recurse-submodules=on-demand --follow-tags
  git:pull: git pull origin main
  git:submodule:init: git submodule init && git submodule update && derry git:submodule:pull
  git:submodule:push: git submodule foreach 'git push'
  git:submodule:pull: git submodule update --remote --rebase
  git:submodule:checkout: git submodule foreach 'git checkout -b main'
  project:setup: derry git:init && melos bs && melos run get && derry gen:build:complete

environment:
  sdk: ">=3.0.0 <4.0.0"
  ${!isDart ? 'flutter: ">=3.10.0"' : ''}

dependencies:
${!isDart ? '''
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_web_plugins:
    sdk: flutter
  accessibility_tools: any
  app_links: any
  cupertino_icons: any
  flex_color_scheme: any
  flutter_svg: any
  rive: any
  lottie: any
  flutter_riverpod: any
  go_router: any
  google_fonts: any
  handy_window: any
  ''' : '''riverpod: any'''}
  collection: any
  intl: any
  path_provider: any
  path: any
  platform: any
  riverpod_annotation: any
  shared_preferences: any
  universal_io: any
  upgrader: any
  url_launcher: any
  uuid: any
  $submods

dev_dependencies:
  mocktail: any
  test: any
  build_web_compilers: any
  build_test: any
  build_runner: any
  ${!isDart ? '''flutter_gen_runner: any
  bdd_widget_test: any
  go_router_builder: any
  ${flavors.isNotEmpty ? 'flutter_flavorizr: any' : ''}
  flutter_driver:
    sdk: flutter
  flutter_test:
    sdk: flutter
  alchemist: any
  flutter_goldens:
    sdk: flutter
  integration_test:
    sdk: flutter
  ''' : ''}
  spec: any
  icons_launcher: any
  checked_yaml: any
  riverpod_generator: any

${!isDart ? '''
flutter:
  uses-material-design: true
  # Enable generation of localized Strings from arb files.
  generate: true
  assets:
    - assets/
    - assets/image/
    - assets/image/vector/
    - assets/image/raster/
    - assets/multimedia/
    - assets/multimedia/audio/
    - assets/multimedia/video/
    - assets/pdf/
    - assets/font/
    - assets/color/
    - assets/txt/
    - assets/animation/
    - assets/animation/rive/
    - assets/animation/lottie/
    - assets/l10n/
#  fonts:
#    - family: Comfortaa
#      fonts:
#        - asset: assets/fonts/comfortaa.ttf
''' : ''}
${flavors.isNotEmpty ? '''
flavorizr:
  ide: $ide
  instructions: [
      assets:download,
      assets:extract,
      assets:clean,
      android:buildGradle,
      android:androidManifest,
      android:icons,
      ios:icons,
      ios:plist
  ]
  app:
    android:
      flavorDimensions: "flavor-type"
    ios:
  flavors:
$flvrs
''' : ''}
${!isDart ? '''
flutter_gen:
  output: lib/src/gen
  line_length: 80
  gen_for_package: true
  integrations:
    flutter_svg: true
    rive: true
    lottie: true
  assets:
    enabled: true
  fonts:
    enabled: true
  colors:
    enabled: true
    inputs:
      - assets/color/colors.xml
  ''' : ''}
''';
  join(pwd, 'pubspec.yaml').write(pubspec);
}
