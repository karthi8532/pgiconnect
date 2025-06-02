class PettyCashItemModel {
  String? itemCode;
  String? itemName;

  PettyCashItemModel({
    required this.itemCode,
    required this.itemName,
  });

  factory PettyCashItemModel.fromJson(Map<String, dynamic> json) {
    return PettyCashItemModel(
      itemCode: json["itemCode"],
      itemName: json['itemName'],
    );
  }
}
