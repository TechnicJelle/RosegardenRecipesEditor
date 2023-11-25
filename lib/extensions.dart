import "dart:io";

extension FileExtention on FileSystemEntity {
  String get name {
    return path.split(Platform.pathSeparator).last;
  }
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ? "${this[0].toUpperCase()}${substring(1).toLowerCase()}" : "";

  String toTitleCase() => replaceAll(RegExp(" +"), " ").split(" ").map((str) => str.toCapitalized()).join(" ");
}
