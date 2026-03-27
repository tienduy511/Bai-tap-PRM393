import 'package:flutter/material.dart';

/// Exercise 4 – App Structure with Scaffold, AppBar, FAB & Theme
/// Goal: Practice building a complete screen structure with dark mode toggle.
class AppStructureDemo extends StatefulWidget {
  const AppStructureDemo({super.key});

  @override
  State<AppStructureDemo> createState() => _AppStructureDemoState();
}

class _AppStructureDemoState extends State<AppStructureDemo> {
  // Track whether dark mode is enabled
  bool _isDarkMode = false;

  /// Handles FAB press – shows a snackbar as a simple demonstration.
  void _onFabPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('FloatingActionButton pressed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Switch between light and dark ThemeData based on toggle state
    final ThemeData theme = _isDarkMode
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData(
      colorSchemeSeed: Colors.indigo,
      useMaterial3: true,
    );

    // Wrap with a Theme widget so children inherit the selected theme
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => Scaffold(
          // ── AppBar ───────────────────────────────────────────────────
          appBar: AppBar(
            title: const Text('Exercise 4 – App Structure & Theme'),
            actions: [
              // Dark mode toggle switch in the AppBar actions area
              Row(
                children: [
                  const Text('Dark'),
                  Switch(
                    value: _isDarkMode,
                    onChanged: (value) => setState(() => _isDarkMode = value),
                  ),
                ],
              ),
            ],
          ),

          // ── Body ─────────────────────────────────────────────────────
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 64,
                  color: _isDarkMode ? Colors.amber : Colors.indigo,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This is a simple screen with theme toggle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current mode: ${_isDarkMode ? 'Dark' : 'Light'}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          // ── FloatingActionButton ──────────────────────────────────────
          floatingActionButton: FloatingActionButton(
            onPressed: _onFabPressed,
            tooltip: 'Add',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}