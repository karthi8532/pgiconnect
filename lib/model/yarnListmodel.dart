class YarnListModel {
  int yardLoadingId;
  int logisticID;
  int? logisticRequestNo;
  var noOfContainers;
  String? customerCode;
  String? customerName;
  var salesOrderNo;
  var soEntry;
  String? supervisorCode;
  String? supervisorName;
  String? dateofLoading;
  var actualQtyLoaded;
  String? whoSealedtheContainer;
  String? clearancegivenby;
  String? itemDisc;

  YarnListModel(
      {required this.yardLoadingId,
      required this.logisticID,
      required this.logisticRequestNo,
      required this.noOfContainers,
      required this.customerCode,
      required this.customerName,
      required this.salesOrderNo,
      required this.soEntry,
      required this.supervisorCode,
      required this.supervisorName,
      required this.dateofLoading,
      required this.actualQtyLoaded,
      required this.whoSealedtheContainer,
      required this.clearancegivenby,
      required this.itemDisc});

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
        supervisorCode: json['supervisorCode'],
        supervisorName: json['supervisorName'],
        dateofLoading: json['dateofLoading'],
        actualQtyLoaded: json['actualQtyLoaded'],
        whoSealedtheContainer: json['whoSealedtheContainer'],
        clearancegivenby: json['clearancegivenby'],
        itemDisc: json['itemDisc']??"");
  }
}
