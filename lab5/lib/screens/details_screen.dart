// ============================================================
// screens/detail_screen.dart
// Movie Detail Screen — poster, genres, overview, actions, trailers
// ============================================================

import 'package:flutter/material.dart';
import '../models/movie.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Optional: favorite toggle state
  bool _isFavorite = false;

  void _toggleFavorite() => setState(() => _isFavorite = !_isFavorite);

  void _onRate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating feature coming soon!')),
    );
  }

  void _onShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing "${widget.movie.title}"…')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      // ── AppBar ─────────────────────────────────────────────
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      // ── Scrollable body ────────────────────────────────────
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Banner (Stack + Image + gradient)
            _buildHeroBanner(movie),

            const SizedBox(height: 16),

            // 2. Title & Genres (Column + Wrap + Chip)
            _buildTitleAndGenres(movie),

            const SizedBox(height: 12),

            // 3. Overview text with Padding
            _buildOverview(movie),

            const SizedBox(height: 16),

            // 4. Row of IconButtons (Favorite, Rate, Share)
            _buildActionButtons(),

            const SizedBox(height: 16),

            // 5. Trailer list using ListView.builder
            _buildTrailerList(movie),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Hero Banner ──────────────────────────────────
  Widget _buildHeroBanner(Movie movie) {
    return Stack(
      children: [
        // Poster image
        SizedBox(
          width: double.infinity,
          height: 260,
          child: Image.network(
            movie.posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.movie, size: 80, color: Colors.grey),
            ),
          ),
        ),

        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),

        // Movie title over the gradient
        Positioned(
          bottom: 16,
          left: 16,
          child: Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 2: Title & Genres ───────────────────────────────
  Widget _buildTitleAndGenres(Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Star + rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                movie.rating.toString(),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Genre chips
          Wrap(
            spacing: 8,
            children: movie.genres
                .map((g) => Chip(
              label: Text(g),
              backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Overview ────────────────────────────────────
  Widget _buildOverview(Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        movie.overview,
        style: const TextStyle(fontSize: 15, height: 1.5),
      ),
    );
  }

  // ── Step 4: Action Buttons ───────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Favorite toggle
        _ActionButton(
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
          label: 'Favorite',
          color: _isFavorite ? Colors.red : null,
          onTap: _toggleFavorite,
        ),

        _ActionButton(
          icon: Icons.star_border,
          label: 'Rate',
          onTap: _onRate,
        ),

        _ActionButton(
          icon: Icons.share,
          label: 'Share',
          onTap: _onShare,
        ),
      ],
    );
  }

  // ── Step 5: Trailer List ─────────────────────────────────
  Widget _buildTrailerList(Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trailers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movie.trailers.length,
            itemBuilder: (context, index) {
              final trailer = movie.trailers[index];
              return ListTile(
                leading: const Icon(Icons.play_circle_outline,
                    color: Colors.deepPurple),
                title: Text(trailer.name),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                        Text('Playing "${trailer.name}"…')),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Reusable action button widget ───────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color ?? Colors.deepPurple, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}