import 'package:flutter/material.dart';
import 'package:smile_reader/core/services/settings_service.dart';
import 'package:smile_reader/ui/screens/bookshelf_screen.dart';
import 'package:smile_reader/ui/screens/file_manager_screen.dart';
import 'package:smile_reader/ui/screens/settings_screen.dart';
import 'package:smile_reader/ui/theme/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final SettingsService _settingsService = SettingsService();
  int _currentIndex = 0;
  String _appTheme = 'light';

  final List<Widget> _screens = [
    const BookshelfScreen(),
    const FileManagerScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    '书架',
    '文件',
    '设置',
  ];

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _appTheme = await _settingsService.getAppTheme();
    setState(() {});
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmileReader',
      theme: AppTheme.getTheme(_appTheme),
      home: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: '书架',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: '文件',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
