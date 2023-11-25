// import "dart:async";
import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "prefs.dart";
import "models/recipe.dart";

final projectPathProvider = Provider((ref) => Directory(prefs.getString("project_path") ?? ""));

final openRecipeProvider = StateProvider<Recipe?>((ref) => null);

final autoSaveRecipe = Provider((ref) {
  // Timer.periodic(const Duration(seconds: 5), (timer) {
  //   final Recipe? recipe = ref.read(openRecipeProvider);
  //   if (recipe != null) {
  //     print("periodic save");
  //     recipe.save();
  //   }
  // });
  ref.listen<Recipe?>(openRecipeProvider, (oldRecipe, newRecipe) {
    oldRecipe?.save();
  });
});
