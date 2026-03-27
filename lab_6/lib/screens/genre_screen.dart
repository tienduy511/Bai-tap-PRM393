import 'package:flutter/material.dart';
import '../data/movie_data.dart';
import '../models/movie.dart';
import '../utils/constants.dart';
import '../widgets/search_bar.dart';
import '../widgets/genre_chips.dart';
import '../widgets/sort_dropdown.dart';
import '../widgets/movie_card.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  String searchQuery = '';
  Set<String> selectedGenres = {};
  String selectedSort = "A-Z";

  void clearFilters() {
    setState(() {
      searchQuery = '';
      selectedGenres.clear();
      selectedSort = "A-Z";
    });
  }

  List<Movie> get filteredMovies {
    List<Movie> movies = allMovies.where((movie) {
      final matchSearch = movie.title
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchGenre = selectedGenres.isEmpty ||
          movie.genres.any((g) => selectedGenres.contains(g));

      return matchSearch && matchGenre;
    }).toList();

    switch (selectedSort) {
      case "A-Z":
        movies.sort((a, b) => a.title.compareTo(b.title));
        break;
      case "Z-A":
        movies.sort((a, b) => b.title.compareTo(a.title));
        break;
      case "Year":
        movies.sort((a, b) => b.year.compareTo(a.year));
        break;
      case "Rating":
        movies.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return movies;
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        searchQuery.isNotEmpty || selectedGenres.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text("Find a Movie",
                  style: TextStyle(fontSize: 24)),

              const SizedBox(height: 10),

              SearchBarWidget(
                onChanged: (value) =>
                    setState(() => searchQuery = value),
              ),

              const SizedBox(height: 10),

              GenreChips(
                genres: genres,
                selectedGenres: selectedGenres,
                onToggle: (genre) {
                  setState(() {
                    if (selectedGenres.contains(genre)) {
                      selectedGenres.remove(genre);
                    } else {
                      selectedGenres.add(genre);
                    }
                  });
                },
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SortDropdown(
                    value: selectedSort,
                    options: sortOptions,
                    onChanged: (val) =>
                        setState(() => selectedSort = val!),
                  ),

                  if (hasFilters)
                    TextButton(
                      onPressed: clearFilters,
                      child: const Text("Clear Filters"),
                    )
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 800) {
                      return ListView.builder(
                        itemCount: filteredMovies.length,
                        itemBuilder: (_, i) =>
                            MovieCard(movie: filteredMovies[i]),
                      );
                    } else {
                      return GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        children: filteredMovies
                            .map((m) => MovieCard(movie: m))
                            .toList(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}