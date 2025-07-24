class PoModel {
  String? poEntry;
  String? poNumber;

  PoModel({required this.poEntry, required this.poNumber});

  factory PoModel.fromJson(Map<String, dynamic> json) {
    return PoModel(poEntry: json["id"], poNumber: json["Value"]);
  }
}
