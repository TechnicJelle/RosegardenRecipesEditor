import "dart:io";

import "package:flutter/foundation.dart";

class Recipe {
  File file;
  String name;
  String intro;
  String prepTime;
  String waitTime;
  String cookTime;
  String servings;
  List<String> ingredients;
  List<String> directions;
  String recipeSource;
  List<String> tags;

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

  Recipe(
    this.file,
    this.name,
    this.intro,
    this.prepTime,
    this.waitTime,
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

    RegExp introRegex = RegExp(r"^# .*?\n+([\S\s]*)- ⏲️ Prep time:");
    String intro = (introRegex.firstMatch(contents)?.group(1) ?? "").trim();
    debugPrint("Intro:\n$intro");

    String prepTime = extractProperty(contents, "Prep time");
    debugPrint("Prep time:\n$prepTime");

    String waitTime = extractProperty(contents, "Wait time");
    debugPrint("Wait time:\n$waitTime");

    String cookTime = extractProperty(contents, "Cook time");
    debugPrint("Cook time:\n$cookTime");

    String servings = extractProperty(contents, "Servings");
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

    return Recipe(
      file,
      name,
      intro,
      prepTime,
      waitTime,
      cookTime,
      servings,
      ingredients,
      directions,
      recipeSource,
      tags,
    );
  }

  void save(String reason, {required bool autoSave}) {
    if (autoSave) {
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
