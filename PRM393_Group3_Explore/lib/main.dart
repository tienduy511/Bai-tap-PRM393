import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  final isDark = prefs.getBool('dark_mode') ?? false;

  runApp(CultureTripApp(
    onboardingDone: onboardingDone,
    initialDark: isDark,
  ));
}

class CultureTripApp extends StatefulWidget {
  final bool onboardingDone;
  final bool initialDark;

  const CultureTripApp({
    super.key,
    required this.onboardingDone,
    required this.initialDark,
  });

  static CultureTripAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<CultureTripAppState>();

  @override
  State<CultureTripApp> createState() => CultureTripAppState();
}

class CultureTripAppState extends State<CultureTripApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode =
    widget.initialDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleDarkMode(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Culture Trip — The 100',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: widget.onboardingDone
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}