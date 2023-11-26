import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "status.dart";

class GitCommitDialog extends StatefulWidget {
  const GitCommitDialog({super.key});

  @override
  State<GitCommitDialog> createState() => _GitCommitDialogState();
}

class _GitCommitDialogState extends State<GitCommitDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Commit and push to GitHub"),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const GitStatus(),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Describe your changes (short)"),
                ),
                maxLines: 1,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                validator: (str) {
                  if (str == null || str.isEmpty) {
                    return "Please enter a commit message";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Longer description (Optional)"),
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text("Commit"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
