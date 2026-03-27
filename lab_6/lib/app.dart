import 'package:flutter/material.dart';
import 'screens/genre_screen.dart';

class ResponsiveMovieApp extends StatelessWidget {
  const ResponsiveMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Browser',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),

        scaffoldBackgroundColor: const Color(0xFFF5F5F7),

        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
          ),
        ),
      ),

      home: const GenreScreen(),
    );
  }
}