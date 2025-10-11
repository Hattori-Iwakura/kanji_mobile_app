import 'package:flutter/material.dart';

class KanjiSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String hintText;

  const KanjiSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search kanji, meaning, or reading...',
  }) : super(key: key);

  @override
  State<KanjiSearchBar> createState() => _KanjiSearchBarState();
}

class _KanjiSearchBarState extends State<KanjiSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        color: Colors.grey[50],
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onSearch,
        onSubmitted: widget.onSearch,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
