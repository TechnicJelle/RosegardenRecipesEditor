import "dart:async";

import "package:flutter/material.dart";

class AddButton extends StatelessWidget {
  final List<String> trackedList;
  final StateSetter parentSetState;
  final String hintText;
  final FocusNode focusNode;

  const AddButton({
    super.key,
    required this.trackedList,
    required this.parentSetState,
    required this.hintText,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.add),
      label: Text(hintText),
      onPressed: () {
        parentSetState(() {
          trackedList.add("");
          Timer(const Duration(milliseconds: 100), () => focusNode.requestFocus());
        });
      },
    );
  }
}
