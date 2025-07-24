class AgentModel {
  String? id;
  String? value;

  AgentModel({required this.id, required this.value});

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(id: json["id"], value: json["value"]);
  }
}
