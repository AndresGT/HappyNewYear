import 'package:flutter/material.dart';

import 'pruebas/feliz_año_nuevo.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: NewYearScreen(),
      ),
    );
  }
}
