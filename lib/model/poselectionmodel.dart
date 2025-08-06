class PoModel {
  String? poEntry;
  String? poNumber;
  int? poLine;

  PoModel(
      {required this.poEntry, required this.poNumber, required this.poLine});

  factory PoModel.fromJson(Map<String, dynamic> json) {
    return PoModel(
        poEntry: json["id"],
        poNumber: json["Value"],
        poLine: json['poLine'] ?? 0);
  }
}
