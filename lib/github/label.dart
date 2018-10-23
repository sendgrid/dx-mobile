class Label {
  final String labelName;
  final String colorHex;

  Label(
    this.labelName,
    this.colorHex
  );

  String toString() =>
      '$labelName, $colorHex';
}
