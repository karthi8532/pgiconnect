class WarehouseModel {
  String? id;
  String? value;

  WarehouseModel({required this.id, required this.value});

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(id: json["id"], value: json["value"]);
  }
}
