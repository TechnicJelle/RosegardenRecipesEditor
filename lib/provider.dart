import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "models/recipe.dart";
import "prefs.dart";

final projectPathProvider = Provider((ref) => Directory(prefs.getString("project_path") ?? ""));

final openRecipeProvider = StateProvider<Recipe?>((ref) => null);

final lastAddedIngredientFocusNodeProvider = Provider<FocusNode>((ref) => FocusNode());
final lastAddedDirectionFocusNodeProvider = Provider<FocusNode>((ref) => FocusNode());
final lastAddedTagFocusNodeProvider = Provider<FocusNode>((ref) => FocusNode());

Timer? _gitRefresherTimer;
final gitRefresher = StreamProvider<String>((ref) {
  final streamController = StreamController<String>();
  final directory = ref.watch(projectPathProvider);

  void pull() async {
    var process = await Process.start(
      "git",
      ["pull", "--rebase", "--autostash"],
      workingDirectory: directory.path,
    );
    process.stdout.transform(utf8.decoder).listen((data) {
      DateFormat formatter = DateFormat(DateFormat.HOUR24_MINUTE_SECOND);
      streamController.add("${formatter.format(DateTime.now())}\n${data.trim()}");
    });
  }

  pull();

  _gitRefresherTimer?.cancel();
  _gitRefresherTimer = Timer.periodic(const Duration(minutes: 5), (_) => pull());

  return streamController.stream;
});
