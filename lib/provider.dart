import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "models/recipe.dart";
import "prefs.dart";

final projectPathProvider = Provider((ref) {
  final String? projectPath = Prefs.instance.projectPath;
  if (projectPath == null) {
    return null;
  } else {
    return Directory(projectPath);
  }
});

final openRecipeProvider = StateProvider<Recipe?>((ref) => null);

//TODO: FocusNodes in Providers? no good
final lastAddedIngredientFocusNodeProvider = Provider<FocusNode>((ref) => FocusNode());
final lastAddedDirectionFocusNodeProvider = Provider<FocusNode>((ref) => FocusNode());
final lastAddedTagFocusNodeProvider = Provider<FocusNode>((ref) => FocusNode());

//TODO: global mutable variable that's used inside a Provider? also no good
Timer? _gitRefresherTimer;
final gitRefresher = StreamProvider<String>((ref) {
  final streamController = StreamController<String>();
  final Directory? projectPath = ref.watch(projectPathProvider);
  if (projectPath == null) return const Stream.empty();

  void pull() async {
    debugPrint("\$ git pull --rebase --autostash");
    var process = await Process.start(
      "git",
      ["pull", "--rebase", "--autostash"],
      workingDirectory: projectPath.path,
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
