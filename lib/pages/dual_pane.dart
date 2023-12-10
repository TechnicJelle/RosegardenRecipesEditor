import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:multi_split_view/multi_split_view.dart";

import "../models/recipe.dart";
import "../provider.dart";
import "recipe_view.dart";
import "recipes_list.dart";

class DualPane extends ConsumerStatefulWidget {
  const DualPane({super.key});

  @override
  ConsumerState<DualPane> createState() => _DualPaneState();
}

class _DualPaneState extends ConsumerState<DualPane> {
  late final MultiSplitViewController splitViewController;

  @override
  void initState() {
    super.initState();

    splitViewController = MultiSplitViewController(
      areas: [
        Area(
          minimalSize: 200,
          weight: 0,
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    splitViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Recipe? openRecipe = ref.watch(openRecipeProvider);

    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerPainter: DividerPainters.grooved1(
          //TODO: See if I can make this less hacky. Use double.infinity, or other properties?
          size: 9999,
          highlightedSize: 9999,
        ),
      ),
      child: MultiSplitView(
        axis: Axis.horizontal,
        controller: splitViewController,
        children: [
          const ExcludeFocus(child: RecipesList()),
          //TODO: Figure out if I can make this work without explicitly specifying a key:
          if (openRecipe != null) RecipeView(recipe: openRecipe, key: ValueKey(openRecipe)),
        ],
      ),
    );
  }
}
