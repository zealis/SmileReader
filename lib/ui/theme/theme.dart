import 'package:flutter/material.dart';

class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF3498db);
  static const Color primaryDark = Color(0xFF2980b9);
  static const Color primaryLight = Color(0xFF5dade2);
  
  // 辅助色
  static const Color accentColor = Color(0xFFf39c12);
  static const Color accentDark = Color(0xFFe67e22);
  static const Color accentLight = Color(0xFFfdae6b);
  
  // 中性色
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFf5f5f5);
  static const Color mediumGray = Color(0xFF9e9e9e);
  static const Color darkGray = Color(0xFF333333);
  static const Color black = Color(0xFF000000);
  
  // 功能色
  static const Color success = Color(0xFF27ae60);
  static const Color warning = Color(0xFFf39c12);
  static const Color error = Color(0xFFe74c3c);
  static const Color info = Color(0xFF3498db);
  
  // 浅色主题
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    secondaryHeaderColor: accentColor,
    scaffoldBackgroundColor: white,
    cardColor: white,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      backgroundColor: lightGray,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkGray, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: darkGray, fontSize: 24, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: darkGray, fontSize: 20, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: darkGray, fontSize: 18, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: darkGray, fontSize: 16, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: darkGray, fontSize: 16, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(color: darkGray, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: darkGray, fontSize: 16),
      bodyMedium: TextStyle(color: mediumGray, fontSize: 14),
      bodySmall: TextStyle(color: mediumGray, fontSize: 12),
      labelLarge: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w500),
    ),
    iconTheme: const IconThemeData(
      color: darkGray,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: mediumGray,
    ),
  );
  
  // 深色主题
  static ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    secondaryHeaderColor: accentColor,
    scaffoldBackgroundColor: darkGray,
    cardColor: Color(0xFF2c2c2c),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      backgroundColor: Color(0xFF222222),
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: white, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: white, fontSize: 24, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: white, fontSize: 16),
      bodyMedium: TextStyle(color: mediumGray, fontSize: 14),
      bodySmall: TextStyle(color: mediumGray, fontSize: 12),
      labelLarge: TextStyle(color: primaryLight, fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: primaryLight, fontSize: 12, fontWeight: FontWeight.w500),
    ),
    iconTheme: const IconThemeData(
      color: white,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: mediumGray,
      backgroundColor: Color(0xFF222222),
    ),
  );
  
  // 获取主题
  static ThemeData getTheme(String theme) {
    return theme == 'dark' ? darkTheme : lightTheme;
  }
}
