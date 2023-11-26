import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../provider.dart";

class GitRefreshStatus extends ConsumerWidget {
  const GitRefreshStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var snapshot = ref.watch(gitRefresher);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: snapshot.when(
          data: (str) {
            return Text(str);
          },
          loading: () {
            return const Text("Updating...");
          },
          error: (err, stackTrace) {
            return Text(err.toString(), style: const TextStyle(color: Colors.red));
          },
        ),
      ),
    );
  }
}
