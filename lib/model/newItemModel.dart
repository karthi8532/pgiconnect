class NewItemModel {
  String? itemCode;
  String? itemName;

  NewItemModel({
    required this.itemCode,
    required this.itemName,
  });

  factory NewItemModel.fromJson(Map<String, dynamic> json) {
    return NewItemModel(
      itemCode: json["itemCode"],
      itemName: json['itemName'],
    );
  }
}
