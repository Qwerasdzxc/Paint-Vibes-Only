import 'package:flutter/material.dart';
import 'package:painter/core/navigation/app_routes.dart';

void main() {
  runApp(const PaintVibesApp());
}

class PaintVibesApp extends StatelessWidget {
  const PaintVibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paint Vibes Only',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.indigo, foregroundColor: Colors.white, elevation: 0),
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
