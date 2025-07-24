class SuppplierModel {
  String? id;
  String? value;

  SuppplierModel({required this.id, required this.value});

  factory SuppplierModel.fromJson(Map<String, dynamic> json) {
    return SuppplierModel(id: json["id"], value: json["value"]);
  }
}
