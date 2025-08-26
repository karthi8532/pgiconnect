class NewItemModel {
  String? itemCode;
  String? itemName;
  String? invoiceType;
  String? documentType;

  NewItemModel({
    required this.itemCode,
    required this.itemName,
    required this.invoiceType,
    required this.documentType,
  });

  factory NewItemModel.fromJson(Map<String, dynamic> json) {
    return NewItemModel(
      itemCode: json["itemCode"],
      itemName: json['itemName'],
      invoiceType: json['invoiceType'],
      documentType: json['documentType'],
    );
  }
}
