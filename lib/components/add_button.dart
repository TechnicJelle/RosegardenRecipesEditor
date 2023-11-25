import "package:flutter/material.dart";

class AddButton extends StatelessWidget {
  final List<String> trackedList;
  final StateSetter parentSetState;
  final String hintText;

  const AddButton({
    super.key,
    required this.trackedList,
    required this.parentSetState,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.add),
      label: Text(hintText),
      onPressed: () {
        parentSetState(() {
          trackedList.add("");
        });
      },
    );
  }
}
