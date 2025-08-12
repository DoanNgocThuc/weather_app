import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onUseLocation;
  final TextEditingController controller;

  const SearchBox({
    super.key,
    required this.onSearch,
    required this.onUseLocation,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF5A7BD0);

    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "E.g., New York, London, Tokyo",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Search"),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("or"),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onUseLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
            ),
            child: const Text("Use Current Location"),
          ),
        ),
      ],
    );
  }
}
