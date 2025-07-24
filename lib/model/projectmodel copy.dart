class SalesPersonModel {
  var id;
  String? value;

  SalesPersonModel({required this.id, required this.value});

  factory SalesPersonModel.fromJson(Map<String, dynamic> json) {
    return SalesPersonModel(id: json["id"], value: json["Value"]);
  }
}
