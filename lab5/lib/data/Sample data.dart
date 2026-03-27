// ============================================================
// data/sample_data.dart
// Static sample movie data (no API calls)
// ============================================================

import '../models/movie.dart';

final List<Movie> sampleMovies = [
  Movie(
    id: 1,
    title: 'Dune: Part Two',
    posterUrl:
    'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
    overview:
    'Paul Atreides unites with Chani and the Fremen while seeking revenge '
        'against the conspirators who destroyed his family.',
    genres: ['Sci-Fi', 'Adventure', 'Drama'],
    rating: 8.6,
    trailers: [
      Trailer(name: 'Official Trailer #1'),
      Trailer(name: 'IMAX Sneak Peek'),
    ],
  ),
  Movie(
    id: 2,
    title: 'Deadpool & Wolverine',
    posterUrl:
    'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
    overview:
    'The multiverse gets messy when Wade Wilson teams up with Wolverine '
        'for a not-so-family-friendly mission.',
    genres: ['Action', 'Comedy'],
    rating: 8.3,
    trailers: [
      Trailer(name: 'Red Band Trailer'),
      Trailer(name: 'Behind the Scenes'),
    ],
  ),
  Movie(
    id: 3,
    title: 'Inside Out 2',
    posterUrl:
    'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
    overview:
    'Riley enters adolescence and new emotions — including Anxiety — '
        'crash Headquarters, forcing Joy and the others to adapt.',
    genres: ['Animation', 'Family', 'Comedy'],
    rating: 7.9,
    trailers: [
      Trailer(name: 'Official Teaser'),
      Trailer(name: 'Full Trailer'),
    ],
  ),
];