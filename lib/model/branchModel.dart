class BranchModel {
  int? id;
  String? gate;

  BranchModel({required this.id, required this.gate});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(id: json["id"], gate: json["gate"]);
  }
}
