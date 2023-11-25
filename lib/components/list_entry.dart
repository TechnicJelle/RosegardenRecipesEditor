import "package:flutter/material.dart";

import "multiline_text_field.dart";

class ListEntry extends StatefulWidget {
  final int index;
  final List<String> trackedList;
  final String hintText;
  final bool isOrdered;
  final StateSetter parentSetState;

  const ListEntry({
    super.key,
    required this.index,
    required this.trackedList,
    required this.hintText,
    required this.isOrdered,
    required this.parentSetState,
  });

  @override
  State<ListEntry> createState() => _ListEntryState();
}

class _ListEntryState extends State<ListEntry> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: widget.index,
      child: InkWell(
        canRequestFocus: false,
        onTap: () {}, // For the highlight,
        onHover: (value) => setState(() => _isHovering = value),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                widget.isOrdered ? Text("${widget.index + 1}.") : const Text("- "),
                const SizedBox(width: 8),
                Expanded(
                  child: MultilineTextField(
                    // key: widget.key,
                    hintText: widget.hintText,
                    startText: widget.trackedList[widget.index],
                    onChanged: (value) => widget.trackedList[widget.index] = value,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            Visibility(
              visible: _isHovering,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    child: const Icon(Icons.copy),
                    onTap: () => widget.parentSetState(() {
                      widget.trackedList.insert(widget.index, widget.trackedList[widget.index]);
                    }),
                  ),
                  InkWell(
                    onTap: () => widget.parentSetState(() {
                      widget.trackedList.removeAt(widget.index);
                    }),
                    child: const Icon(Icons.delete),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
