class UndoAction {
  final String type;
  final int index;
  final String? name;
  final int? timeRemaining;
  final List<String>? speakers;

  UndoAction({required this.type, required this.index, this.name, this.timeRemaining, this.speakers});
}
