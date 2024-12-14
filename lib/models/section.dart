class Section {
  String name;
  bool isOpen;
  List<String> speakers;

  Section({required this.name, this.isOpen = true, List<String>? speakers})
      : speakers = speakers ?? [];

  Section clone() {
    return Section(
      name: this.name,
      isOpen: this.isOpen,
      speakers: List<String>.from(this.speakers),
    );
  }
}
