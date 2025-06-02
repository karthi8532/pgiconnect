class YarnListModel {
  int yardLoadingId;
  int logisticID;
  int? logisticRequestNo;
  var noOfContainers;
  String? customerCode;
  String? customerName;
  var salesOrderNo;
  var soEntry;

  YarnListModel(
      {required this.yardLoadingId,
      required this.logisticID,
      required this.logisticRequestNo,
      required this.noOfContainers,
      required this.customerCode,
      required this.customerName,
      required this.salesOrderNo,
      required this.soEntry});

  factory YarnListModel.fromJson(Map<String, dynamic> json) {
    return YarnListModel(
      yardLoadingId: json['yardLoadingId'] ?? 0,
      logisticID: json["logisticID"] ?? 0,
      logisticRequestNo: json["logisticRequestNo"],
      noOfContainers: json['noOfContainers'] ?? "0",
      customerCode: json['customerCode'] ?? "",
      customerName: json['customerName'] ?? "",
      salesOrderNo: json['salesOrderNo'] ?? "0",
      soEntry: json['soEntry'],
    );
  }
}
