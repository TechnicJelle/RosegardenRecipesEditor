import "package:flutter/material.dart";

import "../models/recipe.dart";

class Stats extends StatelessWidget {
  const Stats({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    //TODO: Make these editable
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("⏲", style: TextStyle(fontFamily: "NotoEmoji")),
            Text(" Prep time: ${recipe.prepTime} minutes"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("⏳", style: TextStyle(fontFamily: "NotoEmoji")),
            Text(" Wait time: ${recipe.waitTime} minutes"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🍳", style: TextStyle(fontFamily: "NotoEmoji")),
            Text(" Cook time: ${recipe.cookTime} minutes"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🍽", style: TextStyle(fontFamily: "NotoEmoji")),
            Text(" Servings: ${recipe.servings}"),
          ],
        ),
      ],
    );
  }
}
