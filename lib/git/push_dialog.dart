import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../provider.dart";

//TODO: it doesn't make much sense to create a stream that you use only in a provider: use an AsyncNotifier
//then you publish by updating state, and consume with ref.watch
final _permanentStreamController = StreamController<String>();
final _streamProvider = StreamProvider<String>((ref) => _permanentStreamController.stream);

class GitPushDialog extends ConsumerStatefulWidget {
  final String commitMessage;
  final String? commitDescription;

  const GitPushDialog({
    super.key,
    required this.commitMessage,
    required this.commitDescription,
  });

  @override
  ConsumerState<GitPushDialog> createState() => _GitPushDialogState();
}

class _GitPushDialogState extends ConsumerState<GitPushDialog> {
  final List<String> log = [];

  @override
  void initState() {
    super.initState();

    List<String> commitArgs = ["commit", "-m", widget.commitMessage];
    if (widget.commitDescription != null && widget.commitDescription!.isNotEmpty) {
      commitArgs.addAll(["-m", widget.commitDescription!]);
    }

    Future<void> runGitCommand(List<String> args) async {
      final Directory? projectPath = ref.read(projectPathProvider);
      if (projectPath == null) return;

      debugPrint("\$ git ${args.join(" ")}");
      Process.start(
        "git",
        args,
        workingDirectory: projectPath.path,
      ).then((process) async {
        var stdout = process.stdout.transform(utf8.decoder).listen((str) {
          _permanentStreamController.add(str);
        });
        var stderr = process.stderr.transform(utf8.decoder).listen((str) {
          _permanentStreamController.add("error: $str");
        });

        await Future.wait([
          process.exitCode,
          stdout.asFuture(),
          stderr.asFuture(),
        ]);
      });
    }

    runGitCommand(commitArgs)
        .then((_) => runGitCommand(["push", "origin", "HEAD"]))
        .then((_) => Future.delayed(const Duration(seconds: 5), () => Navigator.pop(context)));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(_streamProvider, (_, next) {
      next.whenData((str) {
        setState(() {
          log.add(str);
        });
      });
    });

    return AlertDialog(
      title: const Text("Pushing to GitHub..."),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Commit message:"),
          Text(widget.commitMessage),
          if (widget.commitDescription != null && widget.commitDescription!.isNotEmpty)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text("Commit description:"),
                Text(widget.commitDescription!),
              ],
            ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          const Text("Push log:"),
          for (var line in log)
            if (line.startsWith("error: "))
              Text(line.replaceFirst("error: ", ""), style: const TextStyle(color: Colors.red))
            else
              Text(line),
        ],
      ),
    );
  }
}
