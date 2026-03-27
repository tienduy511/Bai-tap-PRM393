import 'package:flutter/material.dart';
import '../models/destination.dart';

class CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const CategoryFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final all = ['Overview', ...kCategories];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = all[i];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onChanged(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                    : (isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                      : (isDark
                      ? Colors.white.withOpacity(0.12)
                      : const Color(0xFFE0E0E0)),
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? (isDark
                      ? const Color(0xFF1A1A1A)
                      : Colors.white)
                      : (isDark
                      ? Colors.white54
                      : const Color(0xFF666666)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}