class UndoAction {
  final String type;
  final int index;
  final String? name;
  final int? timeRemaining;

  UndoAction({required this.type, required this.index, this.name, this.timeRemaining});
}