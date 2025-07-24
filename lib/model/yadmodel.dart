class YardModel {
  String? id;
  String? value;

  YardModel({required this.id, required this.value});

  factory YardModel.fromJson(Map<String, dynamic> json) {
    return YardModel(id: json["id"], value: json["Value"]);
  }
}
