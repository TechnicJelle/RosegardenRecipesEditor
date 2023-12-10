import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:reorderables/reorderables.dart";

import "../components/add_button.dart";
import "../components/list_entry.dart";
import "../components/my_text_field.dart";
import "../components/stats.dart";
import "../components/tag_chip.dart";
import "../models/recipe.dart";
import "../provider.dart";

class RecipeView extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeView({required this.recipe, super.key});

  @override
  ConsumerState<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends ConsumerState<RecipeView> {
  late Recipe recipe;

  final _scrollController = ScrollController();
  late final Timer autoSaveTimer;

  @override
  void initState() {
    super.initState();

    recipe = widget.recipe;

    const int seconds = 15;
    autoSaveTimer = Timer.periodic(const Duration(seconds: seconds), (timer) {
      recipe.save(isAutoSave: true, reason: "timer $seconds seconds");
    });
  }

  @override
  void dispose() {
    super.dispose();
    autoSaveTimer.cancel();
    _scrollController.dispose();
    recipe.save(isAutoSave: true, reason: "close");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverList.list(
              children: [
                Text(recipe.name, style: Theme.of(context).textTheme.headlineLarge),
                MyTextField(
                  hintText: "Enter recipe description here",
                  startText: recipe.intro,
                  onChanged: (value) => setState(() => recipe = recipe.copyWith(intro: value)),
                ),
                const SizedBox(height: 16),
                Stats(recipe: recipe),
                const SizedBox(height: 16),
                Text("Ingredients", style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            ReorderableSliverList(
              controller: _scrollController,
              delegate: ReorderableSliverChildBuilderDelegate(
                childCount: recipe.ingredients.length + 1,
                (context, index) {
                  if (index == recipe.ingredients.length) {
                    return AddButton(
                      trackedList: recipe.ingredients,
                      parentSetState: setState,
                      hintText: "Add ingredient",
                      focusNode: ref.watch(lastAddedIngredientFocusNodeProvider),
                    );
                  }

                  return ListEntry(
                    //TODO: UniqueKey that is not saved anywhere? very bad.
                    key: UniqueKey(),
                    index: index,
                    trackedList: recipe.ingredients,
                    hintText: "List an ingredient",
                    isOrdered: false,
                    parentSetState: setState,
                    focusNodeProvider: lastAddedIngredientFocusNodeProvider,
                  );
                },
              ),
              onReorder: (oldIndex, newIndex) {
                // Prevent reordering the "Add ingredient" button
                if (oldIndex >= recipe.ingredients.length || newIndex >= recipe.ingredients.length) {
                  return;
                }

                setState(() {
                  final item = recipe.ingredients.removeAt(oldIndex);
                  recipe.ingredients.insert(newIndex, item);
                });
              },
            ),
            SliverList.list(
              children: [
                const SizedBox(height: 16),
                Text("Directions", style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            ReorderableSliverList(
              controller: _scrollController,
              delegate: ReorderableSliverChildBuilderDelegate(
                childCount: recipe.directions.length + 1,
                (context, index) {
                  if (index == recipe.directions.length) {
                    return AddButton(
                      trackedList: recipe.directions,
                      parentSetState: setState,
                      hintText: "Add direction",
                      focusNode: ref.watch(lastAddedDirectionFocusNodeProvider),
                    );
                  }

                  return ListEntry(
                    //TODO: UniqueKey that is not saved anywhere? very bad.
                    key: UniqueKey(),
                    index: index,
                    trackedList: recipe.directions,
                    hintText: "Explain a step of the process",
                    isOrdered: true,
                    parentSetState: setState,
                    focusNodeProvider: lastAddedDirectionFocusNodeProvider,
                  );
                },
              ),
              onReorder: (oldIndex, newIndex) {
                // Prevent reordering the "Add direction" button
                if (oldIndex >= recipe.directions.length || newIndex >= recipe.directions.length) {
                  return;
                }

                setState(() {
                  final item = recipe.directions.removeAt(oldIndex);
                  recipe.directions.insert(newIndex, item);
                });
              },
            ),
            SliverList.list(
              children: [
                const SizedBox(height: 16),
                Text("Recipe source", style: Theme.of(context).textTheme.titleLarge),
                MyTextField(
                  hintText: "Where did you find this recipe? How did you create it?",
                  startText: recipe.recipeSource,
                  onChanged: (value) => setState(() => recipe = recipe.copyWith(recipeSource: value)),
                ),
                const SizedBox(height: 16),
                Text("Tags/Categories", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ReorderableWrap(
                  buildDraggableFeedback: (context, constraints, child) {
                    return Transform(
                      transform: Matrix4.rotationZ(0),
                      alignment: FractionalOffset.topLeft,
                      child: Material(
                        elevation: 6.0,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ConstrainedBox(constraints: constraints, child: child),
                        ),
                      ),
                    );
                  },
                  spacing: 8,
                  runSpacing: 8,
                  onReorder: (int oldIndex, int newIndex) {
                    // Prevent reordering the "Add tag" chip
                    if (oldIndex >= recipe.tags.length || newIndex >= recipe.tags.length) return;

                    setState(() {
                      final item = recipe.tags.removeAt(oldIndex);
                      recipe.tags.insert(newIndex, item);
                    });
                  },
                  children: [
                    for (int i = 0; i < recipe.tags.length; i++)
                      TagChip(
                        hintText: "tag",
                        startText: recipe.tags[i],
                        onChanged: (value) => recipe.tags[i] = value,
                        onDeleted: () => setState(() => recipe.tags.removeAt(i)),
                        focusNode: i == recipe.tags.length - 1 ? ref.watch(lastAddedTagFocusNodeProvider) : null,
                      ),
                    ActionChip(
                      label: const Text("Add tag"),
                      avatar: const Icon(Icons.add),
                      tooltip: "Add tag",
                      onPressed: () {
                        setState(() => recipe.tags.add(""));
                        Timer(const Duration(milliseconds: 100), () {
                          ref.read(lastAddedTagFocusNodeProvider).requestFocus();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
