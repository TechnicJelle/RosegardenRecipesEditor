import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:window_manager/window_manager.dart";

import "components/path_picker_button.dart";
import "git/commit_dialog.dart";
import "git/refresh_status.dart";
import "models/recipe.dart";
import "pages/dual_pane.dart";
import "pages/recipes_list.dart";
import "prefs.dart";
import "provider.dart";
import "tech_app.dart";

const String appTitle = "Rosegarden Recipes Editor";
const String commit = String.fromEnvironment("commit", defaultValue: "local");

void main() async {
  await Prefs.init();

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    title: "$appTitle ($commit)",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TechApp(
      title: appTitle,
      primary: Colors.green,
      secondary: Colors.lightGreen,
      themeMode: ThemeMode.light,
      home: const MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Directory? projectPath = ref.watch(projectPathProvider);
    final Recipe? openRecipe = ref.watch(openRecipeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: projectPath == null
            ? null
            : [
                const GitRefreshStatus(),
                IconButton(
                  tooltip: "Maximize window",
                  icon: const Icon(Icons.window),
                  onPressed: () => windowManager.maximize(),
                ),
                IconButton(
                  tooltip: "Commit changes",
                  icon: const Icon(Icons.upload),
                  onPressed: () async {
                    showDialog(context: context, builder: (context) => const GitCommitDialog());
                  },
                ),
                IconButton(
                  tooltip: "Save current recipe",
                  icon: const Icon(Icons.save),
                  onPressed: openRecipe == null
                      ? null
                      : () => openRecipe.save(isAutoSave: false, reason: "save button clicked"),
                ),
                PopupMenuButton(
                  tooltip: "Extra options",
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.folder_delete, color: Colors.black54),
                          SizedBox(width: 8),
                          Text("Clear project path"),
                        ],
                      ),
                      onTap: () {
                        Prefs.instance.projectPath = null;
                        ref.invalidate(projectPathProvider);
                      },
                    ),
                  ],
                )
              ],
      ),
      body: projectPath == null
          ? const ProjectPathPickerButton()
          : openRecipe == null
              ? const RecipesList()
              : const DualPane(),
    );
  }
}
