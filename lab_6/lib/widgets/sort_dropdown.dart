import 'package:flutter/material.dart';

class SortDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final Function(String?) onChanged;

  const SortDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}