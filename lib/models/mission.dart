class Mission {
  final String category;
  final String address;
  final DateTime dateTime;
  final String note;
  String status;

  Mission({
    required this.category,
    required this.address,
    required this.dateTime,
    required this.note,
    this.status = "Créée",
  });
}
