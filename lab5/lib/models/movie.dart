// ============================================================
// models/movie.dart
// Data model for Movie and Trailer
// ============================================================

class Trailer {
  final String name;

  const Trailer({required this.name});
}

class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String overview;
  final List<String> genres;
  final double rating;
  final List<Trailer> trailers;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.overview,
    required this.genres,
    required this.rating,
    required this.trailers,
  });
}