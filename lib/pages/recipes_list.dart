import "dart:io";

import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../extensions.dart";
import "../models/recipe.dart";
import "../provider.dart";

class RecipesList extends ConsumerStatefulWidget {
  const RecipesList({super.key});

  @override
  ConsumerState<RecipesList> createState() => _RecipesListState();
}

class _RecipesListState extends ConsumerState<RecipesList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _newRecipePopup(BuildContext context) {
    String newRecipeName = "";
    bool popped = false; // Prevents the validator from running after the dialog is popped

    final nameVerificationKey = GlobalKey<FormFieldState>();

    void createNewRecipeAndPop(BuildContext context) {
      if (!nameVerificationKey.currentState!.validate()) return;

      Navigator.pop(context);
      popped = true;

      final Directory projectPath = ref.read(projectPathProvider);
      final String cleanName = cleanRecipeName(newRecipeName);
      final newRecipeDir = Directory("${projectPath.path}${Platform.pathSeparator}$cleanName");
      newRecipeDir.createSync();
      final File newRecipeFile = File("${newRecipeDir.path}${Platform.pathSeparator}recipe.md");
      final recipe = Recipe.empty(newRecipeFile, newRecipeName)..save(isAutoSave: false, reason: "new recipe");

      ref.read(openRecipeProvider.notifier).state = recipe;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Recipe"),
          content: TextFormField(
            key: nameVerificationKey,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Recipe name",
            ),
            onChanged: (String value) => newRecipeName = value,
            onFieldSubmitted: (String value) => createNewRecipeAndPop(context),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String? recipeName) {
              if (popped) return null;

              if (recipeName == null || recipeName.isEmpty) {
                return "Recipe name cannot be empty";
              }

              final String cleanName = cleanRecipeName(recipeName);

              final Directory projectPath = ref.read(projectPathProvider);
              final contents = projectPath.listSync(recursive: false).whereType<Directory>();

              if (contents.any((dir) => dir.name == cleanName)) {
                return "Recipe already exists";
              }
              return null;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => createNewRecipeAndPop(context),
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Directory projectPath = ref.watch(projectPathProvider);

    return Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("New Recipe"),
              onPressed: () => _newRecipePopup(context),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            //TODO: recreating a stream in the build method? bad
            stream: projectPath.watch(),
            builder: (context, _) {
              //TODO: reading the file system in the build method? extremely bad.
              final List<Directory> contents = projectPath
                  .listSync(recursive: false)
                  .whereType<Directory>()
                  .where((dir) => !dir.name.startsWith(RegExp(r"[!._]")))
                  .toList();

              contents.sort((a, b) => compareNatural(a.name, b.name));

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: false,
                  itemCount: contents.length,
                  itemBuilder: (context, index) {
                    final Directory recipeDir = contents[index];
                    return ListTile(
                      title: Text(prettifyRecipeName(recipeDir.name)),
                      onTap: () => ref.read(openRecipeProvider.notifier).state = Recipe.fromDirectory(recipeDir),
                      selected: ref.watch(openRecipeProvider)?.file.parent.path == recipeDir.path,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

String cleanRecipeName(String dirtyRecipeName) {
  dirtyRecipeName = dirtyRecipeName.trim().toLowerCase();
  RegExp removeCharsRegex = RegExp(r"[^a-z0-9/ -]");
  RegExp recipeNameRegex = RegExp(r"[^a-z]");
  RegExp multipleSpacesRegex = RegExp(r"\s+");
  return dirtyRecipeName
      .replaceAll(removeCharsRegex, "")
      .replaceAll(recipeNameRegex, " ")
      .replaceAll(multipleSpacesRegex, " ")
      .trim()
      .replaceAll(" ", "-");
}

String prettifyRecipeName(String dirtyRecipeName) {
  return dirtyRecipeName.replaceAll("-", " ").toTitleCase();
}
