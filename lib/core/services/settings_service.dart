import 'package:shared_preferences/shared_preferences.dart';
import 'package:smile_reader/core/models/setting.dart';
import 'package:smile_reader/core/services/database_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  final DatabaseService _dbService = DatabaseService();
  SharedPreferences? _prefs;

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  // 初始化 SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 保存设置
  Future<void> saveSetting(String key, dynamic value) async {
    if (_prefs == null) await _initPrefs();

    // 保存到 SharedPreferences
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    }

    // 保存到数据库（可选，用于同步）
    Setting setting = Setting(
      userId: 'default',
      key: key,
      value: value,
    );

    List<Map<String, dynamic>> existing = await _dbService.query('settings', where: {'userId': 'default', 'key': key});
    if (existing.isEmpty) {
      await _dbService.insert('settings', setting.toMap());
    } else {
      await _dbService.update('settings', setting.toMap(), where: {'userId': 'default', 'key': key});
    }
  }

  // 获取设置
  Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    if (_prefs == null) await _initPrefs();

    // 从 SharedPreferences 获取
    dynamic value;
    if (_prefs!.containsKey(key)) {
      if (defaultValue is String) {
        value = _prefs!.getString(key);
      } else if (defaultValue is int) {
        value = _prefs!.getInt(key);
      } else if (defaultValue is bool) {
        value = _prefs!.getBool(key);
      } else if (defaultValue is double) {
        value = _prefs!.getDouble(key);
      } else if (defaultValue is List<String>) {
        value = _prefs!.getStringList(key);
      } else {
        value = _prefs!.get(key);
      }
    }

    if (value != null) return value;

    // 从数据库获取
    List<Map<String, dynamic>> existing = await _dbService.query('settings', where: {'userId': 'default', 'key': key});
    if (existing.isNotEmpty) {
      Setting setting = Setting.fromMap(existing.first);
      return setting.value;
    }

    return defaultValue;
  }

  // 保存阅读设置
  Future<void> saveReadingSettings(Map<String, dynamic> settings) async {
    for (MapEntry<String, dynamic> entry in settings.entries) {
      await saveSetting('reading_${entry.key}', entry.value);
    }
  }

  // 获取阅读设置
  Future<Map<String, dynamic>> getReadingSettings() async {
    return {
      'fontSize': await getSetting('reading_fontSize', defaultValue: 16),
      'fontFamily': await getSetting('reading_fontFamily', defaultValue: 'System'),
      'lineSpacing': await getSetting('reading_lineSpacing', defaultValue: 1.5),
      'theme': await getSetting('reading_theme', defaultValue: 'light'),
      'pageLayout': await getSetting('reading_pageLayout', defaultValue: 'vertical'),
    };
  }

  // 保存应用主题
  Future<void> saveAppTheme(String theme) async {
    await saveSetting('app_theme', theme);
  }

  // 获取应用主题
  Future<String> getAppTheme() async {
    return await getSetting('app_theme', defaultValue: 'light');
  }

  // 保存存储设置
  Future<void> saveStorageSettings(Map<String, dynamic> settings) async {
    for (MapEntry<String, dynamic> entry in settings.entries) {
      await saveSetting('storage_${entry.key}', entry.value);
    }
  }

  // 获取存储设置
  Future<Map<String, dynamic>> getStorageSettings() async {
    return {
      'autoBackup': await getSetting('storage_autoBackup', defaultValue: false),
      'backupInterval': await getSetting('storage_backupInterval', defaultValue: 7),
      'maxCacheSize': await getSetting('storage_maxCacheSize', defaultValue: 500),
    };
  }
}
