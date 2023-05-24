# Helpis CLI

This CLI provides various commands to help with Dart/Flutter development.

## Commands

### helpis

The `helpis` command provides an interface for the other commands. Running `helpis` will display usage information for the available commands.

### create

The `create` command creates a new Dart project with a predefined structure. Some of the options include:

- `-n` or `--name`: The name of the project. This option is mandatory.
- `-D` or `--description`: The project's description.
- `-a` or `--author`: The name of the code owner.

For example, to create a project named `MyProject`, run:

```bash
helpis create -n MyProject -a user1 -D "My first Dart package."
```

### createStore

The `createStore` command creates a caching service using `SharedPreferences`. It has the following options:

- `-n` or `--name`: The name of the project. Default is `App`. Used in field naming/prefixing.
- `-u` or `--unedited`: Use this flag to use the app's name unedited.
- `-p` or `--part`: Adds a `part of` directive.
- `-t` or `--target`: The path to generate the dart file. Default is `lib/src/service/cache` .
- `-i` or `--imports`: Additional imports.
- `-k` or `--keys`: Cache keys and optional default values. Format is `key1-default1,key2,key3-default3`.

For example, to create a `StorageApp` with keys `isDarkMode` and `locale-en_us` and an import of `package:flutter/material.dart`, run:

```bash
helpis createStore -i package:flutter/material.dart -k isDarkMode,locale-en_us -n StorageApp
```

### colorgen

The `colorgen` command creates aliases and theming features for `FlexColorScheme` colors from an `XML`
asset file. See the command description for details on the `XML` format.

For example, with an `assets/colors.xml` file, run:

```bash
helpis colorgen -t assets/colors.xml
```

This will generate a `lib/src/gen/theme/colors.helpis.dart` file with the color aliases.
