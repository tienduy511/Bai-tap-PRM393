// ============================================================
// screens/home_screen.dart
// Home Screen — shows scrollable list of movies
// ============================================================

import 'package:flutter/material.dart';
import '../data/Sample data.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Optional: search filter state
  String _searchQuery = '';

  List<Movie> get _filteredMovies => sampleMovies
      .where((m) =>
      m.title.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  void _navigateToDetail(Movie movie) {
    // Navigator.push + MaterialPageRoute navigation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movies',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // ── Optional search bar ──────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search movies…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // ── Movie list ───────────────────────────────────────
          Expanded(
            child: _filteredMovies.isEmpty
                ? const Center(child: Text('No movies found'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = _filteredMovies[index];
                return MovieCard(
                  movie: movie,
                  onTap: () => _navigateToDetail(movie),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}