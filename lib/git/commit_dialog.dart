import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "push_dialog.dart";
import "status.dart";

class GitCommitDialog extends ConsumerStatefulWidget {
  const GitCommitDialog({super.key});

  @override
  ConsumerState<GitCommitDialog> createState() => _GitCommitDialogState();
}

class _GitCommitDialogState extends ConsumerState<GitCommitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commitMessageController = TextEditingController();
  final _commitDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool gitAnyChanges = ref.watch(gitAnyChangesProvider);

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
              if (gitAnyChanges)
                Column(
                  children: [
                    TextFormField(
                      controller: _commitMessageController,
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
                      controller: _commitDescriptionController,
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
          onPressed: !gitAnyChanges
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => GitPushDialog(
                        commitMessage: _commitMessageController.text,
                        commitDescription:
                            _commitDescriptionController.text.isEmpty ? null : _commitDescriptionController.text,
                      ),
                    );
                  }
                },
          child: const Text("Commit"),
        ),
      ],
    );
  }
}
