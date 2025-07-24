class WeighLocationModel {
  String? id;
  String? value;

  WeighLocationModel({required this.id, required this.value});

  factory WeighLocationModel.fromJson(Map<String, dynamic> json) {
    return WeighLocationModel(id: json["id"], value: json["Value"]);
  }
}
