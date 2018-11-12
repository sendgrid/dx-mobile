class Label {
  final String labelName;
  final String colorHex;
  final String id;

  Label(
    this.labelName,
    this.colorHex,
    this.id
  );

  String toString() =>
      '$labelName, $colorHex, $id';
}
