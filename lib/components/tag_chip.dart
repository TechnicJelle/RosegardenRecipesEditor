import "package:flutter/material.dart";

class TagChip extends StatefulWidget {
  final String hintText;
  final String startText;
  final Function(String) onChanged;
  final VoidCallback onDeleted;
  final FocusNode? focusNode;

  TagChip({
    required this.hintText,
    required this.startText,
    required this.onChanged,
    required this.onDeleted,
    this.focusNode,
  }) : super(key: UniqueKey());

  //TODO: UniqueKey in super? very bad

  @override
  State<TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<TagChip> {
  late final TextEditingController _controller = TextEditingController(text: widget.startText);

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: IntrinsicWidth(
        child: TextField(
          controller: _controller,
          style: Theme.of(context).textTheme.bodyLarge,
          expands: false,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: widget.onChanged,
        ),
      ),
      onDeleted: widget.onDeleted,
    );
  }
}
