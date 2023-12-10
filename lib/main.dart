import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:multi_split_view/multi_split_view.dart";
import "package:window_manager/window_manager.dart";

import "git/commit_dialog.dart";
import "git/refresh_status.dart";
import "models/recipe.dart";
import "pages/recipe_view.dart";
import "pages/recipes_list.dart";
import "prefs.dart";
import "provider.dart";
import "tech_app.dart";

const String appTitle = "Rosegarden Recipes Editor";
const String commit = String.fromEnvironment("commit", defaultValue: "local");

void main() async {
  await Prefs.init();

  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle("$appTitle ($commit)");
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
    final Directory projectPath = ref.watch(projectPathProvider);
    final Recipe? openRecipe = ref.watch(openRecipeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          const GitRefreshStatus(),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () async {
              showDialog(context: context, builder: (context) => const GitCommitDialog());
            },
          ),
          if (openRecipe != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => openRecipe.save(isAutoSave: false, reason: "save button clicked"),
            ),
        ],
      ),
      body: projectPath.path.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: () async {
                  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                  if (selectedDirectory == null) return; // User canceled the picker

                  Prefs.instance.projectPath = selectedDirectory;
                  ref.invalidate(projectPathProvider);
                },
                child: const Text("Set project path"),
              ),
            )
          : MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                dividerPainter: DividerPainters.grooved1(
                  size: 9999,
                  highlightedSize: 9999,
                ),
              ),
              child: MultiSplitView(
                axis: Axis.horizontal,
                controller: MultiSplitViewController(
                  areas: [
                    Area(
                      minimalSize: 200,
                      weight: 0,
                    ),
                  ],
                ),
                children: [
                  const ExcludeFocus(child: RecipesList()),
                  if (openRecipe != null) RecipeView(recipe: openRecipe, key: ValueKey(openRecipe)),
                ],
              ),
            ),
    );
  }
}
