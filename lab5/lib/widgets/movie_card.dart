// ============================================================
// widgets/movie_card.dart
// Reusable MovieCard widget used in HomeScreen
// ============================================================

import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        onTap: onTap,

        // Poster thumbnail
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            movie.posterUrl,
            width: 56,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 56,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.movie, color: Colors.grey),
            ),
          ),
        ),

        // Title + rating + genres
        title: Text(
          movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${movie.rating}'),
              ],
            ),
            Text(
              movie.genres.join(' • '),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),

        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}