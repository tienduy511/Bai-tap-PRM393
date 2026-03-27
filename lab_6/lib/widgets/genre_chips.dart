import 'package:flutter/material.dart';

class GenreChips extends StatelessWidget {
  final List<String> genres;
  final Set<String> selectedGenres;
  final Function(String) onToggle;

  const GenreChips({
    super.key,
    required this.genres,
    required this.selectedGenres,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) {
        final isSelected = selectedGenres.contains(genre);

        return ChoiceChip(
          label: Text(
            genre,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          selected: isSelected,
          selectedColor: Colors.deepPurple,
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onSelected: (_) => onToggle(genre),
        );
      }).toList(),
    );
  }
}