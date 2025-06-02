class ItemModel {
  int? logisticID;
  int? yardloadinglineId;
  String? itemCode;
  String? itemName;
  String? whsCode;
  double? qty;
  String? packingType;
  int? baseEntry;
  int? baseLine;
  String? baseType;

  ItemModel({
    required this.logisticID,
    required this.yardloadinglineId,
    required this.itemCode,
    required this.itemName,
    required this.whsCode,
    required this.qty,
    required this.packingType,
    required this.baseEntry,
    required this.baseLine,
    required this.baseType,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      logisticID: json['logisticID'],
      yardloadinglineId: json['yardloadinglineId'],
      itemCode: json["itemCode"],
      itemName: json['itemName'],
      whsCode: json["whs"],
      qty: json['qty'] is int ? (json['qty'] as int).toDouble() : json['qty'],
      packingType: json['packingType'],
      baseEntry: json['baseEntry'],
      baseLine: json['baseLine'],
      baseType: json['baseType'],
    );
  }
}
