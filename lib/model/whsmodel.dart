class Whsmodel {
  String? id;
  String? value;

  Whsmodel({required this.id, required this.value});

  factory Whsmodel.fromJson(Map<String, dynamic> json) {
    return Whsmodel(id: json["id"], value: json["value"]);
  }
}
