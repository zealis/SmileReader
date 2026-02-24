import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smile_reader/core/services/settings_service.dart';
import 'package:smile_reader/core/utils/file_utils.dart';
import 'package:smile_reader/ui/theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  Map<String, dynamic> _readingSettings = {};
  String _appTheme = 'light';
  Map<String, dynamic> _storageSettings = {};
  int _cacheSize = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _calculateCacheSize();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _readingSettings = await _settingsService.getReadingSettings();
      _appTheme = await _settingsService.getAppTheme();
      _storageSettings = await _settingsService.getStorageSettings();
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateCacheSize() async {
    Directory cacheDir = await FileUtils.getCacheDirectory();
    int size = await FileUtils.getDirectorySize(cacheDir.path);
    setState(() {
      _cacheSize = size;
    });
  }

  void _saveReadingSettings() {
    _settingsService.saveReadingSettings(_readingSettings);
  }

  void _saveAppTheme(String theme) {
    _settingsService.saveAppTheme(theme);
    setState(() {
      _appTheme = theme;
    });
  }

  void _saveStorageSettings() {
    _settingsService.saveStorageSettings(_storageSettings);
  }

  Future<void> _clearCache() async {
    Directory cacheDir = await FileUtils.getCacheDirectory();
    await FileUtils.clearDirectory(cacheDir.path);
    await _calculateCacheSize();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('缓存已清理')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // 阅读设置
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '阅读偏好',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // 字体大小
                      ListTile(
                        title: const Text('字体大小'),
                        trailing: DropdownButton<int>(
                          value: _readingSettings['fontSize'],
                          onChanged: (value) {
                            setState(() {
                              _readingSettings['fontSize'] = value;
                              _saveReadingSettings();
                            });
                          },
                          items: [
                            for (int size = 12; size <= 24; size += 2)
                              DropdownMenuItem(value: size, child: Text('$size')),
                          ],
                        ),
                      ),
                      
                      // 行间距
                      ListTile(
                        title: const Text('行间距'),
                        trailing: DropdownButton<double>(
                          value: _readingSettings['lineSpacing'],
                          onChanged: (value) {
                            setState(() {
                              _readingSettings['lineSpacing'] = value;
                              _saveReadingSettings();
                            });
                          },
                          items: [
                            DropdownMenuItem(value: 1.0, child: const Text('1.0')),
                            DropdownMenuItem(value: 1.2, child: const Text('1.2')),
                            DropdownMenuItem(value: 1.4, child: const Text('1.4')),
                            DropdownMenuItem(value: 1.5, child: const Text('1.5')),
                            DropdownMenuItem(value: 1.6, child: const Text('1.6')),
                            DropdownMenuItem(value: 1.8, child: const Text('1.8')),
                            DropdownMenuItem(value: 2.0, child: const Text('2.0')),
                          ],
                        ),
                      ),
                      
                      // 页面布局
                      ListTile(
                        title: const Text('页面布局'),
                        trailing: DropdownButton<String>(
                          value: _readingSettings['pageLayout'],
                          onChanged: (value) {
                            setState(() {
                              _readingSettings['pageLayout'] = value;
                              _saveReadingSettings();
                            });
                          },
                          items: [
                            DropdownMenuItem(value: 'vertical', child: const Text('垂直')),
                            DropdownMenuItem(value: 'horizontal', child: const Text('水平')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 应用主题
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '应用主题',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _saveAppTheme('light'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _appTheme == 'light' ? AppTheme.primaryColor : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '浅色',
                                    style: TextStyle(
                                      color: _appTheme == 'light' ? AppTheme.white : Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _saveAppTheme('dark'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _appTheme == 'dark' ? AppTheme.primaryColor : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '深色',
                                    style: TextStyle(
                                      color: _appTheme == 'dark' ? AppTheme.white : Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 存储设置
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '存储管理',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      ListTile(
                        title: const Text('缓存大小'),
                        trailing: Text(FileUtils.formatFileSize(_cacheSize)),
                      ),
                      ListTile(
                        title: const Text('自动备份'),
                        trailing: Switch(
                          value: _storageSettings['autoBackup'] ?? false,
                          onChanged: (value) {
                            setState(() {
                              _storageSettings['autoBackup'] = value;
                              _saveStorageSettings();
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _clearCache,
                        child: const Text('清理缓存'),
                      ),
                    ],
                  ),
                ),
                
                // 关于应用
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '关于应用',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('版本'),
                        trailing: const Text('1.0.0'),
                      ),
                      ListTile(
                        title: const Text('开发者'),
                        trailing: const Text('SmileReader Team'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
