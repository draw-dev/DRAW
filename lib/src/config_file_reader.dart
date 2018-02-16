import 'dart:io';
import 'package:path/path.dart' as path;
import 'exceptions.dart';

const String kLinuxEnvVar = 'XDG_CONFIG_HOME';
const String kLinuxHomeEnvVar = 'HOME';
const String kMacEnvVar = 'HOME';
const String kFileName = 'draw.ini';
const String kWindowsEnvVar = 'APPDATA';

class ConfigFileReader {
  /// Path to Local, User, Global Configuration Files, with matching precedence.
  Uri _localConfigPath;
  Uri _userConfigPath;

  String _configUrl;

  ConfigFileReader(String configUrl) {
    _configUrl = configUrl;
    _localConfigPath = _getLocalConfigPath();
    _userConfigPath = _getUserConfigPath();
  }

  /// Loads file from [_localConfigPath] or [_userConfigPath].
  File loadCorrectFile() {
    if (_configUrl != null) {
      final primaryFile = new File(_configUrl);
      if (primaryFile.existsSync()) {
        return primaryFile;
      }
    }
    // Check if file exists locally.
    var primaryFile = new File(_localConfigPath.toFilePath());
    if (primaryFile.existsSync()) {
      _configUrl = _localConfigPath.toString();
      return primaryFile;
    }

    // Check if file exists in user directory.
    primaryFile = new File(_userConfigPath.toFilePath());
    if (primaryFile.existsSync()) {
      _configUrl = _userConfigPath.toString();
      return primaryFile;
    }
    return null;
  }

  /// Returns path to user level configuration file.
  /// Special Behaviour: if User Config Environment var unset,
  /// uses [$HOME] or the corresponding root path for the os.
  Uri _getUserConfigPath() {
    final environment = Platform.environment;
    String osConfigPath;
    // Load correct path for user level configuration paths based on operating system.
    if (Platform.isMacOS) {
      osConfigPath = path.join(environment[kMacEnvVar], '.config');
    } else if (Platform.isLinux) {
      osConfigPath = environment[kLinuxEnvVar] ?? environment[kLinuxHomeEnvVar];
    } else if (Platform.isWindows) {
      osConfigPath = environment[kWindowsEnvVar];
    } else {
      throw new DRAWInternalError('OS not Recognized by DRAW');
    }
    if (osConfigPath == null) {
      // Sets osConfigPath to the corresponding root path
      // based on the os.
      final path.Context osDir = new path.Context();
      final cwd = osDir.current;
      osConfigPath = osDir.rootPrefix(cwd);
    }
    return path.toUri(path.join(osConfigPath, kFileName));
  }

  /// Returns path to local configuration file.
  Uri _getLocalConfigPath() {
    final path.Context osDir = new path.Context();
    final cwd = osDir.current;
    return path.toUri(path.join(cwd, kFileName));
  }
}
