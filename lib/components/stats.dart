import "package:flutter/material.dart";

import "../models/recipe.dart";

class Stats extends StatelessWidget {
  const Stats({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("⏲", style: TextStyle(fontFamily: "NotoEmoji")),
            Text("Prep time: ${recipe.prepTime} minutes"),
          ],
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🍳", style: TextStyle(fontFamily: "NotoEmoji")),
            Text("Cook time: ${recipe.cookTime} minutes"),
          ],
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🍽", style: TextStyle(fontFamily: "NotoEmoji")),
            Text("Servings: ${recipe.servings}"),
          ],
        ),
      ],
    );
  }
}
