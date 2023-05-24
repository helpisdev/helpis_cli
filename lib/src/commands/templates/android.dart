String get proguardRules => '''
# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# GooglePlay Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.common.** { *; }
-dontwarn com.google.common.**
''';

String get keyProperties => '''
keyAlias=androidreleasekey
keyPassword=
storeFile=/path/to/certificates/android_keystore.jks
storePassword=
''';

String get settingsGradle => r'''
include ':app'

final def localPropertiesFile = new File(
  rootProject.projectDir,
  'local.properties'
)
final def properties = new Properties()

assert localPropertiesFile.exists()
localPropertiesFile.withReader('UTF-8') {
  final reader -> properties.load(reader)
}

final def flutterSdkPath = properties.getProperty('flutter.sdk')
assert flutterSdkPath != null, 'flutter.sdk not set in local.properties'
apply from:
  "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"

final def flutterProjectRoot = rootProject.projectDir.parentFile.toPath()

final def plugins = new Properties()
final def pluginsFile = new File(
  flutterProjectRoot.toFile(),
  '.flutter-plugins'
)
if (pluginsFile.exists()) {
  pluginsFile.withInputStream { final stream -> plugins.load(stream) }
}

plugins.each { name, path ->
  final def pluginDirectory = flutterProjectRoot
    .resolve(path)
    .resolve('android')
    .toFile()
  include ":$name"
  project(":$name").projectDir = pluginDirectory
}
''';

String get topLevelBuildGradle => r'''
buildscript {
    ext.kotlin_version = '1.7.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.2.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.3.14'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
''';

String appLevelBuildGradleConfig({
  required final List<dynamic> flavors,
  required final String name,
  final String? org,
}) {
  final StringBuffer flavorsConfig = StringBuffer();
  if (flavors.isNotEmpty) {
    flavorsConfig
      ..writeln("flavorDimensions 'flavor-type'")
      ..writeln()
      ..writeln('productFlavors {')
      ..writeln();
    for (final dynamic flavor in flavors) {
      flavorsConfig.writeln('''
    $flavor {
      dimension 'flavor-type'
      applicationId '${org != null ? '$org.' : ''}$name'
      resValue 'string', 'app_name', '$name'
      applicationIdSuffix '$flavor'
      minSdkVersion flutter.minSdkVersion
      targetSdkVersion flutter.targetSdkVersion
      multiDexEnabled true
    }
''');
    }
    flavorsConfig.write('}');
  }
  return '''
final Properties localProperties = new Properties()
final def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
  localPropertiesFile.withReader('UTF-8') { final reader ->
    localProperties.load(reader)
  }
}

/**
 * Run Proguard to shrink the Java bytecode in release builds.
 */
final def enableProguardInReleaseBuilds = true

final def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
  throw new Exception('Flutter SDK not found. Define location with flutter.sdk in the local.properties file.')
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
  flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
  flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
dependencies {
  implementation 'com.google.android.gms:play-services-auth:20.4.0'
}

apply plugin: 'kotlin-android'
apply from: "\$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

final def keystoreProperties = new Properties()
final def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
  keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
  lintOptions {
    disable 'InvalidPackage'
    checkReleaseBuilds false
  }

  signingConfigs {
    debug {
      if (project.hasProperty('${name.toUpperCase()}_UPLOAD_STORE_FILE')) {
        storeFile file(${name.toUpperCase()}_UPLOAD_STORE_FILE)
        storePassword ${name.toUpperCase()}_UPLOAD_STORE_PASSWORD
        keyAlias ${name.toUpperCase()}_DEBUG_KEY_ALIAS
        keyPassword ${name.toUpperCase()}_UPLOAD_KEY_PASSWORD
      }
    }
    release {
      keyAlias keystoreProperties['keyAlias']
      keyPassword keystoreProperties['keyPassword']
      storeFile file(keystoreProperties['storeFile'])
      storePassword keystoreProperties['storePassword']
    }
  }

  buildTypes {
    debug {
      signingConfig signingConfigs.debug
    }
    release {
      signingConfig signingConfigs.release
      profile {
        matchingFallbacks = ['debug', 'release']
      }
      minifyEnabled true
      shrinkResources true
      proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
  }

  $flavorsConfig

  compileSdkVersion flutter.compileSdkVersion
  ndkVersion '25.1.8937393'

  compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
  }

  kotlinOptions {
    jvmTarget = '1.8'
  }

  sourceSets {
    main.java.srcDirs += 'src/main/kotlin'
  }

  defaultConfig {
    applicationId '${org != null ? '$org.' : ''}$name'
    minSdkVersion flutter.minSdkVersion
    targetSdkVersion flutter.targetSdkVersion
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
    multiDexEnabled true
  }

  buildToolsVersion '33.0.0'
}

flutter {
  source '../..'
}

dependencies {
  implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:\$kotlin_version"
  implementation 'com.android.support:multidex:1.0.3'
}

''';
}

String get gradleWrapperProperties => r'''
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6-all.zip
''';

String androidManifest({
  required final String name,
  final String? org,
}) =>
    '''
<manifest
  xmlns:android="http://schemas.android.com/apk/res/android"
  xmlns:tools="http://schemas.android.com/tools"
  package="${org != null ? '$org.' : ''}$name"
>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  <uses-permission android:name="android.permission.WAKE_LOCK" />
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
  <!-- Provide required visibility configuration for API level 30 and above -->
  <queries>
    <!-- If your app checks for SMS support -->
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="sms" />
    </intent>
    <!-- If your app checks for call support -->
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="tel" />
    </intent>
  </queries>
  <application
    android:label="@string/app_name"
    android:name="\${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:usesCleartextTraffic="true"
    tools:replace="android:extractNativeLibs"
    android:extractNativeLibs="true"
  >
    <activity
      android:name=".MainActivity"
      android:exported="true"
      android:launchMode="singleTop"
      android:theme="@style/LaunchTheme"
      android:configChanges="orientation|
      keyboardHidden|
      keyboard|
      screenSize|
      smallestScreenSize|
      &#xA;
      locale|
      layoutDirection|
      fontScale|
      screenLayout|
      density|
      uiMode"
      android:hardwareAccelerated="true"
      android:windowSoftInputMode="adjustResize"
    >
      <!-- Specifies an Android theme to apply to this Activity as soon as
         the Android process has started. This theme is visible to the user
         while the Flutter UI initializes. After that, this theme continues
         to determine the Window background behind the Flutter UI. -->
      <meta-data
        android:name="io.flutter.embedding.android.NormalTheme"
        android:resource="@style/NormalTheme"
      />
      <meta-data
        android:name="io.flutter.embedding.android.SplashScreenDrawable"
        android:resource="@drawable/launch_background"
      />
      <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>
    </activity>

    <!--
      Don't delete the meta-data below.
      This is used by the Flutter tool to
      generate GeneratedPluginRegistrant.java.
    -->
    <meta-data android:name="flutterEmbedding" android:value="2"/>
  </application>
</manifest>
''';
