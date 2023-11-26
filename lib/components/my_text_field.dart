import "package:flutter/material.dart";

class MyTextField extends StatefulWidget {
  final String hintText;
  final String startText;
  final Function(String) onChanged;
  final FocusNode? focusNode;
  final bool multiline;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.startText,
    required this.onChanged,
    this.focusNode,
    this.multiline = true,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
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
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.hintText,
        isCollapsed: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      textCapitalization: TextCapitalization.sentences,
      onChanged: (str) {
        if (!widget.multiline) {
          if (str.endsWith("\n")) {
            _controller.text = str.substring(0, str.length - 1);
            FocusScope.of(context).nextFocus();
          }
        }
        widget.onChanged(_controller.text);
      },
    );
  }
}
