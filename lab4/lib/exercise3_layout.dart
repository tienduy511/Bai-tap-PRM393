import 'package:flutter/material.dart';

/// Exercise 3 – Layout Basics: Column, Row, Padding, ListView
/// Goal: Build a sectioned UI layout similar to a real app Home screen.
class LayoutDemo extends StatelessWidget {
  const LayoutDemo({super.key});

  // Sample movie data for the list
  static const List<Map<String, String>> _movies = [
    {'title': 'Avatar', 'description': 'Sample description'},
    {'title': 'Inception', 'description': 'Sample description'},
    {'title': 'Interstellar', 'description': 'Sample description'},
    {'title': 'Joker', 'description': 'Sample description'},
    {'title': 'Dune', 'description': 'Sample description'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 3 – Layout'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header section ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.movie, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Now Playing',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // "See all" button in the header row
                TextButton(
                  onPressed: () {},
                  child: const Text('See all'),
                ),
              ],
            ),
          ),

          // Divider for visual separation
          const Divider(height: 1),

          // ── Scrollable movie list (ListView.builder) ───────────────────
          // Wrap in Expanded so ListView can fill the remaining space
          Expanded(
            child: ListView.builder(
              // Apply consistent 8px padding around the list
              padding: const EdgeInsets.all(8),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                // Each row has a leading avatar, title, and subtitle
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(
                        movie['title']![0], // First letter of title
                        style: const TextStyle(color: Colors.indigo),
                      ),
                    ),
                    title: Text(movie['title']!),
                    subtitle: Text(movie['description']!),
                    tileColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Footer section with SizedBox spacing ──────────────────────
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${_movies.length} movies loaded',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}