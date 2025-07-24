class SuperVisorModel {
  String? id;
  String? value;

  SuperVisorModel({required this.id, required this.value});

  factory SuperVisorModel.fromJson(Map<String, dynamic> json) {
    return SuperVisorModel(id: json["ID"], value: json["Value"]);
  }
}
