class ProjectModel {
  String? id;
  String? value;

  ProjectModel({required this.id, required this.value});

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(id: json["id"], value: json["Value"]);
  }
}
