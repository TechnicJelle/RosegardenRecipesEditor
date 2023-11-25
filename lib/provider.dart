// import "dart:async";
import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "prefs.dart";
import "models/recipe.dart";

final projectPathProvider = Provider((ref) => Directory(prefs.getString("project_path") ?? ""));

final openRecipeProvider = StateProvider<Recipe?>((ref) => null);
