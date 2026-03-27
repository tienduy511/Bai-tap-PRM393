import 'package:flutter/material.dart';

/// Exercise 5 – Debug & Fix Common UI Errors
/// Goal: Understand common layout issues and fix them.
///
/// Fixes demonstrated:
///   1. ListView inside Column → use Expanded to avoid unbounded height error.
///   2. Overflow on small screens → wrap body in SingleChildScrollView.
///   3. State update issue → always call setState() when changing state.
///   4. DatePicker context error → call showDatePicker from a valid widget tree
///      (use BuildContext that is mounted, not a disposed context).
class CommonUIFixes extends StatefulWidget {
  const CommonUIFixes({super.key});

  @override
  State<CommonUIFixes> createState() => _CommonUIFixesState();
}

class _CommonUIFixesState extends State<CommonUIFixes> {
  // Fix 3: counter that requires setState() to update UI
  int _counter = 0;

  // Fix 4: selected date from DatePicker
  DateTime? _pickedDate;

  // Sample movie list for Fix 1
  final List<String> _movies = ['Movie A', 'Movie B', 'Movie C', 'Movie D'];

  /// Fix 3: increment counter and call setState so the widget rebuilds.
  void _incrementCounter() {
    // ✅ Correct: call setState to trigger a rebuild
    setState(() => _counter++);
    // ❌ Wrong (without setState): _counter++ would update the value
    //    but the UI would NOT reflect the change.
  }

  /// Fix 4: show DatePicker using the current BuildContext.
  Future<void> _showDatePicker(BuildContext context) async {
    // ✅ Correct: pass 'context' from the build method (valid widget tree).
    // ❌ Wrong: using a stored/stale context that may be unmounted.
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    // Guard: check mounted before calling setState to avoid errors
    if (picked != null && mounted) {
      setState(() => _pickedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 5 – Common UI Fixes'),
      ),
      // ── Fix 2: Wrap body in SingleChildScrollView ──────────────────────
      // Prevents RenderFlex overflow on small or narrow screens.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fix 1: ListView inside Column ────────────────────────────
            const Text(
              'Fix 1: ListView inside Column (using Expanded)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              '✅ Correct ListTile inside Column using Expanded',
              style: TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 8),
            // SizedBox with a fixed height acts like an Expanded equivalent
            // when we're already inside a SingleChildScrollView.
            SizedBox(
              height: 220,
              child: ListView.builder(
                // ✅ Add shrinkWrap or fixed SizedBox to avoid
                //    "unbounded height" error inside Column.
                itemCount: _movies.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.movie),
                  title: Text(_movies[index]),
                ),
              ),
            ),

            const Divider(height: 32),

            // ── Fix 3: setState ───────────────────────────────────────────
            const Text(
              'Fix 3: State update using setState()',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('Increment Counter'),
                ),
                const SizedBox(width: 16),
                Text('Count: $_counter', style: const TextStyle(fontSize: 16)),
              ],
            ),

            const Divider(height: 32),

            // ── Fix 4: DatePicker with valid context ──────────────────────
            const Text(
              'Fix 4: DatePicker from valid widget tree',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              // Pass context from Builder/build so it is always valid
              onPressed: () => _showDatePicker(context),
              child: const Text('Open DatePicker (correct context)'),
            ),
            if (_pickedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Picked: ${_pickedDate!.day}/${_pickedDate!.month}/${_pickedDate!.year}',
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}