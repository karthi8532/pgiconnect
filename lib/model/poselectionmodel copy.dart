class PoLineModel {
  int? id;
  int? value;

  PoLineModel({required this.id, required this.value});

  factory PoLineModel.fromJson(Map<String, dynamic> json) {
    return PoLineModel(id: json["id"], value: json["Value"]);
  }
}
