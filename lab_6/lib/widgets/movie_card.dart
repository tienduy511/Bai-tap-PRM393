import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  Widget buildStars(double rating) {
    int fullStars = (rating / 2).floor();

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        }
        return const Icon(Icons.star_border, size: 16);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 200;

            return Row(
              children: [
                Image.network(
                  movie.posterUrl,
                  width: isWide ? 120 : 90,
                  height: isWide ? 180 : 130,
                  fit: BoxFit.cover,

                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: isWide ? 120 : 90,
                      height: isWide ? 180 : 130,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Year: ${movie.year}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),

                        const SizedBox(height: 6),

                        buildStars(movie.rating),

                        const SizedBox(height: 4),

                        Text(
                          "${movie.rating}/10",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}