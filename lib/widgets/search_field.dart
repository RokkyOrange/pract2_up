import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final String initialText;
  final String hint;
  final ValueChanged<String> onSearch;

  const SearchField({
    super.key,
    required this.initialText,
    required this.hint,
    required this.onSearch,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != _controller.text &&
        widget.initialText != oldWidget.initialText) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: 'Поиск',
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            tooltip: 'Очистить',
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              widget.onSearch('');
            },
          ),
        ),
        onSubmitted: widget.onSearch,
      ),
    );
  }
}
