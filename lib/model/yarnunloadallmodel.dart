class AllYarnUnloadingModel {
  final String tickeID;
  final String vehicleNo;
  final int wheghbridgeNo;
  final String supplier;
  final String trander;
  final String branch;
  final dynamic wheghbridgeWeight;
  final String? itemCode;
  final String itemName;
  final String? warehouse;
  final int qty;

  AllYarnUnloadingModel({
    required this.tickeID,
    required this.vehicleNo,
    required this.wheghbridgeNo,
    required this.supplier,
    required this.trander,
    required this.branch,
    this.wheghbridgeWeight,
    this.itemCode,
    required this.itemName,
    this.warehouse,
    required this.qty,
  });

  factory AllYarnUnloadingModel.fromJson(Map<String, dynamic> json) {
    return AllYarnUnloadingModel(
      tickeID: json['tickeID'] ?? '',
      vehicleNo: json['vehicleNo'] ?? '',
      wheghbridgeNo: json['wheghbridgeNo'] ?? 0,
      supplier: json['supplier'] ?? '',
      trander: json['trander'] ?? '',
      branch: json['branch'] ?? '',
      wheghbridgeWeight: json['wheghbridgeWeight'],
      itemCode: json['itemCode'],
      itemName: json['itemName'] ?? '',
      warehouse: json['warehouse'],
      qty: json['Qty'] ?? 0,
    );
  }
}
