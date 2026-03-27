// Mục đích: Entry point, điều hướng giữa 3 lab bằng BottomNavigationBar

import 'package:flutter/material.dart';
import 'screens/lab91_asset_screen.dart';
import 'screens/lab92_save_load_screen.dart';
import 'screens/lab93_crud_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:  'Lab 9 – JSON Storage',
      theme:  ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home:   const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Danh sách 3 màn hình tương ứng 3 lab
  final List<Widget> _screens = const [
    Lab91AssetScreen(),
    Lab92SaveLoadScreen(),
    Lab93CrudScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder),   label: 'Lab 9.1'),
          BottomNavigationBarItem(icon: Icon(Icons.save),     label: 'Lab 9.2'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Lab 9.3'),
        ],
      ),
    );
  }
}