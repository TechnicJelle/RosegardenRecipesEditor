import "package:flutter/material.dart";

class MultilineTextField extends StatefulWidget {
  final String hintText;
  final String startText;
  final Function(String) onChanged;

  const MultilineTextField({
    super.key,
    required this.hintText,
    required this.startText,
    required this.onChanged,
  });

  @override
  State<MultilineTextField> createState() => _MultilineTextFieldState();
}

class _MultilineTextFieldState extends State<MultilineTextField> {
  late final TextEditingController _controller = TextEditingController(text: widget.startText);

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: Theme.of(context).textTheme.bodyLarge,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.hintText,
        isCollapsed: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      textCapitalization: TextCapitalization.sentences,
      onChanged: widget.onChanged,
    );
  }
}
