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
  
  bool operator ==(o) => o is Label && o.labelName == labelName && o.id == id;

}
