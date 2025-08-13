// widgets/search_box.dart
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onUseLocation;
  final TextEditingController controller;

  /// NEW: pass an error message to show under the box
  final String? errorText;

  /// NEW: disable buttons while loading
  final bool isLoading;

  const SearchBox({
    super.key,
    required this.onSearch,
    required this.onUseLocation,
    required this.controller,
    this.errorText,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF5A7BD0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onSubmitted: (_) => onSearch(), // Enter to search
          decoration: InputDecoration(
            hintText: "E.g., New York, London, Tokyo",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(errorText!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSearch,
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
            onPressed: isLoading ? null : onUseLocation,
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
