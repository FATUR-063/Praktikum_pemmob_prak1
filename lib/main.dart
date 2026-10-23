import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bisque = Color(0xFFFFE4C4);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: bisque),
        scaffoldBackgroundColor: bisque,
        appBarTheme: const AppBarTheme(
          backgroundColor: bisque,
          surfaceTintColor: Colors.transparent,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
