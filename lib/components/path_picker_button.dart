import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../prefs.dart";
import "../provider.dart";

class ProjectPathPickerButton extends ConsumerWidget {
  const ProjectPathPickerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
          if (selectedDirectory == null) return; // User canceled the picker

          Prefs.instance.projectPath = selectedDirectory;
          ref.invalidate(projectPathProvider);
        },
        child: const Text("Set project path"),
      ),
    );
  }
}
