class EditYarnListModel {
  int yardLoadingId;
  int logisticID;
  int? logisticRequestNo;
  String? noOfContainers;
  String? customerCode;
  String? customerName;
  int? salesOrderNo;
  int soEntry;
  var containerNumber;

  EditYarnListModel(
      {required this.yardLoadingId,
      required this.logisticID,
      required this.logisticRequestNo,
      required this.noOfContainers,
      required this.customerCode,
      required this.customerName,
      required this.salesOrderNo,
      required this.soEntry,
      required this.containerNumber});

  factory EditYarnListModel.fromJson(Map<String, dynamic> json) {
    return EditYarnListModel(
      yardLoadingId: json['yardLoadingId'] ?? 0,
      logisticID: json["logisticId"] ?? 0,
      logisticRequestNo: json["logisticRequestNo"],
      noOfContainers: json['noOfContainers'] ?? "0",
      customerCode: json['customerCode'] ?? "",
      customerName: json['customerName'] ?? "",
      salesOrderNo: json['salesOrderNo'] ?? 0,
      soEntry: json['salesOrderId'] ?? 0,
      containerNumber: json['containerNo'],
    );
  }
}
