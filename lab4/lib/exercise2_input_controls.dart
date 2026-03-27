import 'package:flutter/material.dart';

/// Exercise 2 – Input Widgets: Slider, Switch, RadioListTile, DatePicker
/// Goal: Build an interactive UI that lets users control values.
class InputControlsDemo extends StatefulWidget {
  const InputControlsDemo({super.key});

  @override
  State<InputControlsDemo> createState() => _InputControlsDemoState();
}

class _InputControlsDemoState extends State<InputControlsDemo> {
  // State variables for each input widget
  double _sliderValue = 50;
  bool _isActive = false;
  String? _selectedGenre; // null = none selected
  DateTime? _selectedDate;

  /// Opens a DatePicker dialog and stores the selected date.
  Future<void> _openDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    // Only update state if the user actually selected a date
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 2 – Input Controls'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Slider ────────────────────────────────────────────────────
            const Text(
              'Rating (Slider)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 100,
              label: _sliderValue.round().toString(),
              onChanged: (value) => setState(() => _sliderValue = value),
            ),
            Text('Current value: ${_sliderValue.round()}'),

            const SizedBox(height: 24),

            // ── Switch ────────────────────────────────────────────────────
            const Text(
              'Active (Switch)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Is movie active?'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),

            const SizedBox(height: 24),

            // ── RadioListTile ─────────────────────────────────────────────
            const Text(
              'Genre (RadioListTile)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              title: const Text('Action'),
              value: 'Action',
              groupValue: _selectedGenre,
              onChanged: (value) => setState(() => _selectedGenre = value),
            ),
            RadioListTile<String>(
              title: const Text('Comedy'),
              value: 'Comedy',
              groupValue: _selectedGenre,
              onChanged: (value) => setState(() => _selectedGenre = value),
            ),
            RadioListTile<String>(
              title: const Text('Drama'),
              value: 'Drama',
              groupValue: _selectedGenre,
              onChanged: (value) => setState(() => _selectedGenre = value),
            ),
            Text('Selected genre: ${_selectedGenre ?? 'None'}'),

            const SizedBox(height: 24),

            // ── DatePicker ────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _openDatePicker,
              child: const Text('Open Date Picker'),
            ),
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Selected date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}