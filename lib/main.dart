import 'package:flutter/material.dart';
import 'package:smile_reader/ui/screens/main_screen.dart';

void main() {
  runApp(const SmileReaderApp());
}

class SmileReaderApp extends StatelessWidget {
  const SmileReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}