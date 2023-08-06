# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2023-08-06

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`helpis_cli` - `v0.2.1`](#helpis_cli---v021)

---

#### `helpis_cli` - `v0.2.1`

 - **REFACTOR**(colorgen): Rename app theme typedef to a more readable name. ([a84cff01](https://github.com/helpisdev/helpis_cli.git/commit/a84cff01c620eb5495447125c93040c9f6e3ae15))
 - **FIX**(createStore): Initialize store value only if it doesn't already exist. ([0dc8372b](https://github.com/helpisdev/helpis_cli.git/commit/0dc8372b36c47981171a9ecbd0995fdedc65bfb7))
 - **FEAT**(colorgen): Add method to get the enhanced theme mode based on the current brightness and use that to initialize the enhanced theme mode on theme provider. ([9f3c62c6](https://github.com/helpisdev/helpis_cli.git/commit/9f3c62c637fc600de8abd06036c584a275922a78))

## 0.2.1

 - **REFACTOR**(colorgen): Rename app theme typedef to a more readable name. ([a84cff01](https://github.com/helpisdev/helpis_cli.git/commit/a84cff01c620eb5495447125c93040c9f6e3ae15))
 - **FIX**(createStore): Initialize store value only if it doesn't already exist. ([0dc8372b](https://github.com/helpisdev/helpis_cli.git/commit/0dc8372b36c47981171a9ecbd0995fdedc65bfb7))
 - **FEAT**(colorgen): Add method to get the enhanced theme mode based on the current brightness and use that to initialize the enhanced theme mode on theme provider. ([9f3c62c6](https://github.com/helpisdev/helpis_cli.git/commit/9f3c62c637fc600de8abd06036c584a275922a78))


## 2023-05-30

### Changes

---

Packages with breaking changes:

 - [`helpis_cli` - `v0.2.0`](#helpis_cli---v020)

Packages with other changes:

 - There are no other changes in this release.

---

#### `helpis_cli` - `v0.2.0`

 - **FIX**(create): Comment out and add desc for generate: true option in pubspec since we don't create a synthetic package as of l10n.yaml in mason template. ([79c60fad](https://github.com/helpisdev/helpis_cli.git/commit/79c60fad3e3000eb0e35e0208e08372502939036))
 - **FIX**(create): Respect user choice not to include flutter_gen for flutter_gen_runner as well. ([1a50a986](https://github.com/helpisdev/helpis_cli.git/commit/1a50a9861cee74262ef0f8c3d320e23abb35ddc1))
 - **FIX**(colorgen): Make sure generated names have correct camelCase casing. ([56bbfb11](https://github.com/helpisdev/helpis_cli.git/commit/56bbfb11e705a8ad9d736f703077683b48457a87))
 - **FEAT**(create): Add melos as a dep dependency in generated projects. ([0e8d9187](https://github.com/helpisdev/helpis_cli.git/commit/0e8d9187e54be4dcb8e5b5fa2031e0b9cd52d546))
 - **FEAT**(theme_provider): Change the default theme mode from system to light for more predictability. ([67143c2e](https://github.com/helpisdev/helpis_cli.git/commit/67143c2e3dcd236249f1baab3ab4e8e581e6f9c7))
 - **FEAT**(theme_provider): Enable theme provider only if there is at least one dual light/dark theme available. ([c3d0a79f](https://github.com/helpisdev/helpis_cli.git/commit/c3d0a79f6ce028263978d8ecb5aba19e6fbc4ec3))
 - **BREAKING** **FEAT**(theme_provider): Add switch theme helper, change API so that theme can be changed through mode as well. ([ef3b1e15](https://github.com/helpisdev/helpis_cli.git/commit/ef3b1e15e9b75551eb43c50053746a5e9f297075))

## 0.2.0

> Note: This release has breaking changes.

 - **FIX**(create): Comment out and add desc for generate: true option in pubspec since we don't create a synthetic package as of l10n.yaml in mason template. ([79c60fad](https://github.com/helpisdev/helpis_cli.git/commit/79c60fad3e3000eb0e35e0208e08372502939036))
 - **FIX**(create): Respect user choice not to include flutter_gen for flutter_gen_runner as well. ([1a50a986](https://github.com/helpisdev/helpis_cli.git/commit/1a50a9861cee74262ef0f8c3d320e23abb35ddc1))
 - **FIX**(colorgen): Make sure generated names have correct camelCase casing. ([56bbfb11](https://github.com/helpisdev/helpis_cli.git/commit/56bbfb11e705a8ad9d736f703077683b48457a87))
 - **FEAT**(create): Add melos as a dep dependency in generated projects. ([0e8d9187](https://github.com/helpisdev/helpis_cli.git/commit/0e8d9187e54be4dcb8e5b5fa2031e0b9cd52d546))
 - **FEAT**(theme_provider): Change the default theme mode from system to light for more predictability. ([67143c2e](https://github.com/helpisdev/helpis_cli.git/commit/67143c2e3dcd236249f1baab3ab4e8e581e6f9c7))
 - **FEAT**(theme_provider): Enable theme provider only if there is at least one dual light/dark theme available. ([c3d0a79f](https://github.com/helpisdev/helpis_cli.git/commit/c3d0a79f6ce028263978d8ecb5aba19e6fbc4ec3))
 - **BREAKING** **FEAT**(theme_provider): Add switch theme helper, change API so that theme can be changed through mode as well. ([ef3b1e15](https://github.com/helpisdev/helpis_cli.git/commit/ef3b1e15e9b75551eb43c50053746a5e9f297075))


## 2023-05-25

### Changes

---

Packages with breaking changes:

 - [`helpis_cli` - `v0.1.0`](#helpis_cli---v010)

Packages with other changes:

 - There are no other changes in this release.

---

#### `helpis_cli` - `v0.1.0`

 - **REFACTOR**(create): Make variables mutable instead of late to avoid potentional late initialization errors. ([87de861c](https://github.com/helpisdev/helpis_cli.git/commit/87de861c3ba1b4789eac75b9d2fa5bc73b4123c6))
 - **REFACTOR**(create_store): Improve supported types error message's readability. ([1159ff93](https://github.com/helpisdev/helpis_cli.git/commit/1159ff93db120cd9f1e20ec5e5473dfb81ae1d09))
 - **REFACTOR**(create_store): Use Dart 3.0 style switch expressions. ([9dfaf58f](https://github.com/helpisdev/helpis_cli.git/commit/9dfaf58fb3de4fb0609b585433e1d6ed551afe7a))
 - **REFACTOR**(create_store): Change casing utility from external to local package impl. ([151599f2](https://github.com/helpisdev/helpis_cli.git/commit/151599f26511a5a0e63f9a402fffe6da05277293))
 - **FIX**(create): Make sure to delete generated .mason directory when no longer needed. ([a116c64e](https://github.com/helpisdev/helpis_cli.git/commit/a116c64ec4d75e97a8cf57943e584c778c08d982))
 - **FIX**(create): Remove 'org != null' requirement from conditional since the value wasn't needed. ([b62e173e](https://github.com/helpisdev/helpis_cli.git/commit/b62e173e9beb3566077fc69664711d6ea47ea084))
 - **FIX**(create): Add 'any' version in generated dependencies to ensure compatibility and be explicit. ([c4eb0e00](https://github.com/helpisdev/helpis_cli.git/commit/c4eb0e003263df997c03c2cbb97a2e2b7da0d8b5))
 - **FIX**(create): Un-indent conditional expression which resulted in wrongly formatted generated pubspec.yaml. ([6aaf4944](https://github.com/helpisdev/helpis_cli.git/commit/6aaf4944c9e16da3ddff381e781e26f4823082a5))
 - **FIX**(create_store): Make sure that target exists before trying to write to it. ([12a16139](https://github.com/helpisdev/helpis_cli.git/commit/12a16139d039ac83109f52cc981006c817b54e01))
 - **FIX**(create_store): Accept 'null' as a value for part instead of stringifying the value which lead to a generated 'part of null;'. ([a9943f41](https://github.com/helpisdev/helpis_cli.git/commit/a9943f419df7cb5b3b1decfa94858632107f035f))
 - **FIX**(command_interface): Utilize mason bricks locally instead of globally to avoid .mason-cache errors. ([3c1cdc86](https://github.com/helpisdev/helpis_cli.git/commit/3c1cdc86cb8c30fc3aeb5ba8ed336fc402cf0678))
 - **FIX**(utils): Re-implement casing utilities (previous implementation suddenly stopped working). ([6d53b8d6](https://github.com/helpisdev/helpis_cli.git/commit/6d53b8d6d4bd963657cda24a160f0bbcc665eb5d))
 - **FEAT**(create): Add option to provide a custom l10n.yaml. ([6b2a441a](https://github.com/helpisdev/helpis_cli.git/commit/6b2a441ae7ca78160d4205e8e17b8a85aa2e8457))
 - **FEAT**(create): Add option to provide a custom colors.xml to colorgen command. ([7accd0cf](https://github.com/helpisdev/helpis_cli.git/commit/7accd0cf967622312c39e25abe6df3387833701e))
 - **FEAT**(create): Add option to provide custom icons_launcher.yaml. ([5a54f2cd](https://github.com/helpisdev/helpis_cli.git/commit/5a54f2cd4ed199a5737ad42331502ba9877b7288))
 - **FEAT**(create): Add option to enable/disable the usage of fluttergen. ([01974492](https://github.com/helpisdev/helpis_cli.git/commit/01974492abf66975ccef2fe123681a26721a53bc))
 - **FEAT**(create_store): Add default values for default keys. ([7e837c41](https://github.com/helpisdev/helpis_cli.git/commit/7e837c41dbea4018c3bdf60214bfc277e4df0b48))
 - **FEAT**(colorgen): Add theme provider generation. ([19370b78](https://github.com/helpisdev/helpis_cli.git/commit/19370b78f40fa9df4a240a43ecba65e9230fd78b))
 - **BREAKING** **REFACTOR**(create): Change 'IDE' option to 'ide'. ([61a391ce](https://github.com/helpisdev/helpis_cli.git/commit/61a391ce737791bbf9f3e827ea2dba3d994cf978))
 - **BREAKING** **FEAT**(commands): Remove shorthand abbreviations for commands since they ended up more confusing than helping. ([23f8026c](https://github.com/helpisdev/helpis_cli.git/commit/23f8026c158a9615346e7d22babaf12a615bd19d))

## 0.1.0

> Note: This release has breaking changes.

 - **REFACTOR**(create): Make variables mutable instead of late to avoid potentional late initialization errors. ([87de861c](https://github.com/helpisdev/helpis_cli.git/commit/87de861c3ba1b4789eac75b9d2fa5bc73b4123c6))
 - **REFACTOR**(create_store): Improve supported types error message's readability. ([1159ff93](https://github.com/helpisdev/helpis_cli.git/commit/1159ff93db120cd9f1e20ec5e5473dfb81ae1d09))
 - **REFACTOR**(create_store): Use Dart 3.0 style switch expressions. ([9dfaf58f](https://github.com/helpisdev/helpis_cli.git/commit/9dfaf58fb3de4fb0609b585433e1d6ed551afe7a))
 - **REFACTOR**(create_store): Change casing utility from external to local package impl. ([151599f2](https://github.com/helpisdev/helpis_cli.git/commit/151599f26511a5a0e63f9a402fffe6da05277293))
 - **FIX**(create): Make sure to delete generated .mason directory when no longer needed. ([a116c64e](https://github.com/helpisdev/helpis_cli.git/commit/a116c64ec4d75e97a8cf57943e584c778c08d982))
 - **FIX**(create): Remove 'org != null' requirement from conditional since the value wasn't needed. ([b62e173e](https://github.com/helpisdev/helpis_cli.git/commit/b62e173e9beb3566077fc69664711d6ea47ea084))
 - **FIX**(create): Add 'any' version in generated dependencies to ensure compatibility and be explicit. ([c4eb0e00](https://github.com/helpisdev/helpis_cli.git/commit/c4eb0e003263df997c03c2cbb97a2e2b7da0d8b5))
 - **FIX**(create): Un-indent conditional expression which resulted in wrongly formatted generated pubspec.yaml. ([6aaf4944](https://github.com/helpisdev/helpis_cli.git/commit/6aaf4944c9e16da3ddff381e781e26f4823082a5))
 - **FIX**(create_store): Make sure that target exists before trying to write to it. ([12a16139](https://github.com/helpisdev/helpis_cli.git/commit/12a16139d039ac83109f52cc981006c817b54e01))
 - **FIX**(create_store): Accept 'null' as a value for part instead of stringifying the value which lead to a generated 'part of null;'. ([a9943f41](https://github.com/helpisdev/helpis_cli.git/commit/a9943f419df7cb5b3b1decfa94858632107f035f))
 - **FIX**(command_interface): Utilize mason bricks locally instead of globally to avoid .mason-cache errors. ([3c1cdc86](https://github.com/helpisdev/helpis_cli.git/commit/3c1cdc86cb8c30fc3aeb5ba8ed336fc402cf0678))
 - **FIX**(utils): Re-implement casing utilities (previous implementation suddenly stopped working). ([6d53b8d6](https://github.com/helpisdev/helpis_cli.git/commit/6d53b8d6d4bd963657cda24a160f0bbcc665eb5d))
 - **FEAT**(create): Add option to provide a custom l10n.yaml. ([6b2a441a](https://github.com/helpisdev/helpis_cli.git/commit/6b2a441ae7ca78160d4205e8e17b8a85aa2e8457))
 - **FEAT**(create): Add option to provide a custom colors.xml to colorgen command. ([7accd0cf](https://github.com/helpisdev/helpis_cli.git/commit/7accd0cf967622312c39e25abe6df3387833701e))
 - **FEAT**(create): Add option to provide custom icons_launcher.yaml. ([5a54f2cd](https://github.com/helpisdev/helpis_cli.git/commit/5a54f2cd4ed199a5737ad42331502ba9877b7288))
 - **FEAT**(create): Add option to enable/disable the usage of fluttergen. ([01974492](https://github.com/helpisdev/helpis_cli.git/commit/01974492abf66975ccef2fe123681a26721a53bc))
 - **FEAT**(create_store): Add default values for default keys. ([7e837c41](https://github.com/helpisdev/helpis_cli.git/commit/7e837c41dbea4018c3bdf60214bfc277e4df0b48))
 - **FEAT**(colorgen): Add theme provider generation. ([19370b78](https://github.com/helpisdev/helpis_cli.git/commit/19370b78f40fa9df4a240a43ecba65e9230fd78b))
 - **BREAKING** **REFACTOR**(create): Change 'IDE' option to 'ide'. ([61a391ce](https://github.com/helpisdev/helpis_cli.git/commit/61a391ce737791bbf9f3e827ea2dba3d994cf978))
 - **BREAKING** **FEAT**(commands): Remove shorthand abbreviations for commands since they ended up more confusing than helping. ([23f8026c](https://github.com/helpisdev/helpis_cli.git/commit/23f8026c158a9615346e7d22babaf12a615bd19d))

