import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../pages/recipes_list.dart";
import "../provider.dart";

class GitStatus extends ConsumerStatefulWidget {
  const GitStatus({super.key});

  @override
  ConsumerState<GitStatus> createState() => _GitStatusState();
}

class _GitStatusState extends ConsumerState<GitStatus> {
  List<String> log = [];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 100), () async => await _updateLog());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var line in log)
          if (line.startsWith("error: "))
            Text(line.replaceFirst("error: ", ""), style: const TextStyle(color: Colors.red))
          else
            Text(line),
      ],
    );
  }

  Future<void> _updateLog() async {
    final Directory projectPath = ref.watch(projectPathProvider);
    List<String> log = [];

    await runProcess("git", ["add", "--all", "--verbose"], projectPath, null); // No need to log this
    await runProcess("git", ["status", "--porcelain=v1", "--untracked-files=all"], projectPath, log);

    log = log.join("\n").split("\n"); // Split log by line, in case of multiple lines per list item

    log.removeWhere((str) => str.trim().isEmpty);

    // Pretty up the status lines
    for (var i = 0; i < log.length; i++) {
      String line = log[i].trim();
      RegExp statusExp = RegExp(r"^\s*([ADM]+)\s+(.+)$");
      RegExpMatch? statusMatch = statusExp.firstMatch(line);

      if (statusMatch == null) continue; //not a status line

      String statusChars = statusMatch.group(1)!;
      String fancyStatus;
      if (statusChars.contains("A")) {
        fancyStatus = "Added";
      } else if (statusChars.contains("D")) {
        fancyStatus = "Deleted";
      } else if (statusChars.contains("M")) {
        fancyStatus = "Modified";
      } else {
        fancyStatus = "Unknown";
      }

      String modifiedFile = statusMatch.group(2)!;

      RegExp recipeCleanerExp = RegExp(r"recipes[\\/](.+)[\\/]recipe.md");
      RegExpMatch? recipeCleanerMatch = recipeCleanerExp.firstMatch(line);

      if (recipeCleanerMatch != null) {
        modifiedFile = prettifyRecipeName(recipeCleanerMatch.group(1)!);
      }

      log[i] = "$fancyStatus: $modifiedFile";
    }

    setState(() {
      this.log = log;
    });
  }
}

Future<void> runProcess(
  String executableName,
  List<String> arguments,
  Directory workingDirectory,
  List<String>? log,
) async {
  var process = await Process.start(executableName, arguments, workingDirectory: workingDirectory.path);

  var stdout = process.stdout.transform(utf8.decoder).listen((String data) {
    log?.add(data.trimRight());
  });
  var stderr = process.stderr.transform(utf8.decoder).listen((String data) {
    log?.add("error: ${data.trimRight()}");
  });

  await Future.wait([
    process.exitCode,
    stdout.asFuture(),
    stderr.asFuture(),
  ]);
}