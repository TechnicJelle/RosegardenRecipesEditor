import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:reorderables/reorderables.dart";

import "../models/recipe.dart";
import "../components/my_text_field.dart";
import "../components/add_button.dart";
import "../components/list_entry.dart";
import "../components/stats.dart";
import "../components/tag_chip.dart";
import "../provider.dart";

class RecipeView extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeView({required this.recipe, super.key});

  @override
  ConsumerState<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends ConsumerState<RecipeView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    widget.recipe.save();
    print("Auto-saved ${widget.recipe.name}");
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
                Text(widget.recipe.name, style: Theme.of(context).textTheme.headlineLarge),
                MyTextField(
                  // key: ValueKey("${widget.recipe.name} description"),
                  hintText: "Enter recipe description here",
                  startText: widget.recipe.intro,
                  onChanged: (value) => widget.recipe.intro = value,
                ),
                const SizedBox(height: 16),
                Stats(recipe: widget.recipe),
                const SizedBox(height: 16),
                Text("Ingredients", style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            ReorderableSliverList(
              controller: _scrollController,
              delegate: ReorderableSliverChildBuilderDelegate(
                childCount: widget.recipe.ingredients.length + 1,
                (context, index) {
                  if (index == widget.recipe.ingredients.length) {
                    return AddButton(
                      trackedList: widget.recipe.ingredients,
                      parentSetState: setState,
                      hintText: "Add ingredient",
                      focusNode: ref.watch(lastAddedIngredientFocusNodeProvider),
                    );
                  }

                  return ListEntry(
                    key: UniqueKey(),
                    index: index,
                    trackedList: widget.recipe.ingredients,
                    hintText: "List an ingredient",
                    isOrdered: false,
                    parentSetState: setState,
                    focusNodeProvider: lastAddedIngredientFocusNodeProvider,
                  );
                },
              ),
              onReorder: (oldIndex, newIndex) {
                // Prevent reordering the "Add ingredient" button
                if (oldIndex >= widget.recipe.ingredients.length || newIndex >= widget.recipe.ingredients.length) {
                  return;
                }

                setState(() {
                  final item = widget.recipe.ingredients.removeAt(oldIndex);
                  widget.recipe.ingredients.insert(newIndex, item);
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
                childCount: widget.recipe.directions.length + 1,
                (context, index) {
                  if (index == widget.recipe.directions.length) {
                    return AddButton(
                      trackedList: widget.recipe.directions,
                      parentSetState: setState,
                      hintText: "Add direction",
                      focusNode: ref.watch(lastAddedDirectionFocusNodeProvider),
                    );
                  }

                  return ListEntry(
                    key: UniqueKey(),
                    index: index,
                    trackedList: widget.recipe.directions,
                    hintText: "Explain a step of the process",
                    isOrdered: true,
                    parentSetState: setState,
                    focusNodeProvider: lastAddedDirectionFocusNodeProvider,
                  );
                },
              ),
              onReorder: (oldIndex, newIndex) {
                // Prevent reordering the "Add direction" button
                if (oldIndex >= widget.recipe.directions.length || newIndex >= widget.recipe.directions.length) {
                  return;
                }

                setState(() {
                  final item = widget.recipe.directions.removeAt(oldIndex);
                  widget.recipe.directions.insert(newIndex, item);
                });
              },
            ),
            SliverList.list(
              children: [
                const SizedBox(height: 16),
                Text("Recipe source", style: Theme.of(context).textTheme.titleLarge),
                MyTextField(
                  // key: ValueKey("${widget.recipe.name} recipe source"),
                  hintText: "Where did you find this recipe? How did you create it?",
                  startText: widget.recipe.recipeSource,
                  onChanged: (value) => widget.recipe.recipeSource = value,
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
                    if (oldIndex >= widget.recipe.tags.length || newIndex >= widget.recipe.tags.length) return;

                    setState(() {
                      final item = widget.recipe.tags.removeAt(oldIndex);
                      widget.recipe.tags.insert(newIndex, item);
                    });
                  },
                  children: [
                    for (int i = 0; i < widget.recipe.tags.length; i++)
                      TagChip(
                        hintText: "tag",
                        startText: widget.recipe.tags[i],
                        onChanged: (value) => widget.recipe.tags[i] = value,
                        onDeleted: () => setState(() => widget.recipe.tags.removeAt(i)),
                        focusNode: i == widget.recipe.tags.length - 1 ? ref.watch(lastAddedTagFocusNodeProvider) : null,
                      ),
                    ActionChip(
                      label: const Text("Add tag"),
                      avatar: const Icon(Icons.add),
                      tooltip: "Add tag",
                      onPressed: () {
                        setState(() => widget.recipe.tags.add(""));
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
