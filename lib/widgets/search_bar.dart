import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final Function(String) onChanged;
  const SearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Поиск цели...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}