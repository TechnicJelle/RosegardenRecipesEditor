import "dart:io";

import "package:flutter/foundation.dart";

class Recipe {
  File file;
  String name;
  String intro;
  int prepTime;
  int cookTime;
  int servings;
  List<String> ingredients;
  List<String> directions;
  String recipeSource;
  List<String> tags;

  Recipe.empty(this.file, this.name)
      : intro = "",
        prepTime = 0,
        cookTime = 0,
        servings = 0,
        ingredients = [""],
        directions = [""],
        recipeSource = "",
        tags = [];

  Recipe(
    this.file,
    this.name,
    this.intro,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.ingredients,
    this.directions,
    this.recipeSource,
    this.tags,
  );

  static Recipe fromFile(File file) {
    final String contents = file.readAsStringSync();

    RegExp titleRegex = RegExp(r"^# (.+)$", multiLine: true);
    String name = titleRegex.firstMatch(contents)?.group(1) ?? "";
    debugPrint("Name:\n$name");

    RegExp introRegex = RegExp(r"^# .*?\n+([\S\s]*?)\n+- ⏲️");
    String intro = introRegex.firstMatch(contents)?.group(1) ?? "";
    debugPrint("Intro:\n$intro");

    int prepTime = extractNumber(contents, "Prep time");
    debugPrint("Prep time:\n$prepTime");

    int cookTime = extractNumber(contents, "Cook time");
    debugPrint("Cook time:\n$cookTime");

    int servings = extractNumber(contents, "Servings");
    debugPrint("Servings:\n$servings");

    String ingredientsContent = extractSection(contents, "Ingredients");
    debugPrint("Ingredients:\n$ingredientsContent");
    List<String> ingredients = ingredientsContent.split(RegExp(r"\n*- ")).toList();
    ingredients.removeAt(0); // Remove the empty string at the beginning
    final RegExp ingredientsRegex = RegExp(r"^- ");
    for (int i = 0; i < ingredients.length; i++) {
      ingredients[i] = ingredients[i].replaceFirst(ingredientsRegex, "");
    }

    String directionsContent = extractSection(contents, "Directions");
    debugPrint("Directions:\n$directionsContent");
    List<String> directions = directionsContent.split(RegExp(r"\n*\d+\. ")).toList();
    directions.removeAt(0); // Remove the empty string at the beginning
    final RegExp directionsRegex = RegExp(r"^\d+\. ");
    for (int i = 0; i < directions.length; i++) {
      directions[i] = directions[i].replaceFirst(directionsRegex, "");
    }

    String recipeSource = extractSection(contents, "Recipe source");
    debugPrint("Recipe Source:\n$recipeSource");

    RegExp tagsRegex = RegExp(r";tags: (.+)");
    String tagsContent = tagsRegex.firstMatch(contents)?.group(1) ?? "";
    List<String> tags = tagsContent.split(" ").map((tag) => tag.trim()).where((str) => str.isNotEmpty).toList();
    debugPrint("Tags (${tags.length}):\n$tagsContent");

    return Recipe(file, name, intro, prepTime, cookTime, servings, ingredients, directions, recipeSource, tags);
  }

  void save() {
    var countedIngredients = ingredients.map((ingredient) => "- $ingredient");
    var countedDirections = List<String>.from(directions);
    for (int i = 0; i < countedDirections.length; i++) {
      countedDirections[i] = "${i + 1}. ${countedDirections[i]}";
    }

    file.writeAsStringSync("""
# $name

$intro

- ⏲️ Prep time: $prepTime min
- 🍳 Cook time: $cookTime min
- 🍽️ Servings: $servings

## Ingredients

${countedIngredients.join("\n")}

## Directions

${countedDirections.join("\n")}

## Recipe source

$recipeSource

;tags: ${tags.join(" ")}
"""
        .trim());
  }
}

String extractSection(String contents, String sectionName) {
  RegExp sectionRegex = RegExp(r"## " + sectionName + r"\n+([\S\s]*?)\n+(?:##|;)");
  // print(sectionRegex.pattern);
  return sectionRegex.firstMatch(contents)?.group(1) ?? "";
}

int extractNumber(String contents, String sectionName) {
  RegExp sectionRegex = RegExp(r"- .*? " + sectionName + r": (\d+)");
  return int.parse(sectionRegex.firstMatch(contents)?.group(1) ?? "0");
}
