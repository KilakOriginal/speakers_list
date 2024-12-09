class UndoStack<T> {
  final List<T> _stack = [];

  void push(T item) {
    _stack.add(item);
  }

  T? pop() {
    if (_stack.isEmpty) return null;
    return _stack.removeLast();
  }

  bool get isEmpty => _stack.isEmpty;
}