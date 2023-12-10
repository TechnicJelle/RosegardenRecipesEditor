import "dart:io";

import "package:flutter/foundation.dart";

class Recipe {
  final File file;
  final String name;
  final String intro;
  final String prepTime;
  final String waitTime;
  final String cookTime;
  final String servings;
  final List<String> ingredients;
  final List<String> directions;
  final String recipeSource;
  final List<String> tags;

  Recipe.empty(this.file, this.name)
      : intro = "",
        prepTime = "0 minutes",
        waitTime = "0 minutes",
        cookTime = "0 minutes",
        servings = "0",
        ingredients = [""],
        directions = [""],
        recipeSource = "",
        tags = [];

  const Recipe._({
    required this.file,
    required this.name,
    required this.intro,
    required this.prepTime,
    required this.waitTime,
    required this.cookTime,
    required this.servings,
    required this.ingredients,
    required this.directions,
    required this.recipeSource,
    required this.tags,
  });

  Recipe copyWith({
    String? intro,
    String? prepTime,
    String? waitTime,
    String? cookTime,
    String? servings,
    List<String>? ingredients,
    List<String>? directions,
    String? recipeSource,
    List<String>? tags,
  }) {
    return Recipe._(
      file: file,
      name: name,
      intro: intro ?? this.intro,
      prepTime: prepTime ?? this.prepTime,
      waitTime: waitTime ?? this.waitTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      directions: directions ?? this.directions,
      recipeSource: recipeSource ?? this.recipeSource,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return "Recipe(name: \"$name\")";
  }

  // ignore: dead_code
  static const bool fromFileDebugPrint = kDebugMode && false;

  static Recipe fromDirectory(Directory directory) {
    final file = File("${directory.path}${Platform.pathSeparator}recipe.md");
    return _fromFile(file);
  }

  static Recipe _fromFile(File file) {
    final String contents = file.readAsStringSync();

    RegExp titleRegex = RegExp(r"^# (.+)$", multiLine: true);
    String name = titleRegex.firstMatch(contents)?.group(1) ?? "";
    if (fromFileDebugPrint) debugPrint("Name:\n$name");

    RegExp introRegex = RegExp(r"^# .*?\n+([\S\s]*)- ⏲️ Prep time:");
    String intro = (introRegex.firstMatch(contents)?.group(1) ?? "").trim();
    if (fromFileDebugPrint) debugPrint("Intro:\n$intro");

    String prepTime = extractProperty(contents, "Prep time");
    if (fromFileDebugPrint) debugPrint("Prep time:\n$prepTime");

    String waitTime = extractProperty(contents, "Wait time");
    if (fromFileDebugPrint) debugPrint("Wait time:\n$waitTime");

    String cookTime = extractProperty(contents, "Cook time");
    if (fromFileDebugPrint) debugPrint("Cook time:\n$cookTime");

    String servings = extractProperty(contents, "Servings");
    if (fromFileDebugPrint) debugPrint("Servings:\n$servings");

    String ingredientsContent = extractSection(contents, "Ingredients");
    if (fromFileDebugPrint) debugPrint("Ingredients:\n$ingredientsContent");
    List<String> ingredients = ingredientsContent.split(RegExp(r"\n*- ")).toList();
    ingredients.removeAt(0); // Remove the empty string at the beginning
    final RegExp ingredientsRegex = RegExp(r"^- ");
    for (int i = 0; i < ingredients.length; i++) {
      ingredients[i] = ingredients[i].replaceFirst(ingredientsRegex, "");
    }

    String directionsContent = extractSection(contents, "Directions");
    if (fromFileDebugPrint) debugPrint("Directions:\n$directionsContent");
    List<String> directions = directionsContent.split(RegExp(r"\n*\d+\. ")).toList();
    directions.removeAt(0); // Remove the empty string at the beginning
    final RegExp directionsRegex = RegExp(r"^\d+\. ");
    for (int i = 0; i < directions.length; i++) {
      directions[i] = directions[i].replaceFirst(directionsRegex, "");
    }

    String recipeSource = extractSection(contents, "Recipe source");
    if (fromFileDebugPrint) debugPrint("Recipe Source:\n$recipeSource");

    RegExp tagsRegex = RegExp(r";tags: (.+)");
    String tagsContent = tagsRegex.firstMatch(contents)?.group(1) ?? "";
    List<String> tags = tagsContent.split(" ").map((tag) => tag.trim()).where((str) => str.isNotEmpty).toList();
    if (fromFileDebugPrint) debugPrint("Tags (${tags.length}):\n$tagsContent");

    return Recipe._(
      file: file,
      name: name,
      intro: intro,
      prepTime: prepTime,
      waitTime: waitTime,
      cookTime: cookTime,
      servings: servings,
      ingredients: ingredients,
      directions: directions,
      recipeSource: recipeSource,
      tags: tags,
    );
  }

  void save({required bool isAutoSave, required String reason}) {
    if (isAutoSave) {
      debugPrint("Auto-saving \"$name\" because $reason");
    } else {
      debugPrint("Saving \"$name\" because $reason");
    }
    var countedIngredients = ingredients.map((ingredient) => "- $ingredient");
    var countedDirections = List<String>.from(directions);
    for (int i = 0; i < countedDirections.length; i++) {
      countedDirections[i] = "${i + 1}. ${countedDirections[i]}";
    }

    String output = """
# $name

$intro

- ⏲️ Prep time: $prepTime
- ⏲️ Wait time: $waitTime
- 🍳 Cook time: $cookTime
- 🍽️ Servings: $servings

## Ingredients

${countedIngredients.join("\n")}

## Directions

${countedDirections.join("\n")}

## Recipe source

$recipeSource

;tags: ${tags.join(" ")}
"""
        .trim();

    file.writeAsStringSync("$output\n");
  }
}

String extractSection(String contents, String sectionName) {
  RegExp sectionRegex = RegExp(r"## " + sectionName + r"\n+([\S\s]*?)\n+(?:##|;)");
  return sectionRegex.firstMatch(contents)?.group(1) ?? "";
}

String extractProperty(String contents, String sectionName) {
  RegExp sectionRegex = RegExp(r"- .{0,3}\s" + sectionName + r": (.+)");
  return sectionRegex.firstMatch(contents)?.group(1) ?? "-";
}
