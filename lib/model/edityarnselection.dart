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
  String? supervisorCode;
  String? supervisorName;
  String? dateofLoading;
  var actualQtyLoaded;
  String? whoSealedtheContainer;
  String? clearancegivenby;
  String? itemDisc;
  EditYarnListModel(
      {required this.yardLoadingId,
      required this.logisticID,
      required this.logisticRequestNo,
      required this.noOfContainers,
      required this.customerCode,
      required this.customerName,
      required this.salesOrderNo,
      required this.soEntry,
      required this.containerNumber,
      required this.supervisorCode,
      required this.supervisorName,
      required this.dateofLoading,
      required this.actualQtyLoaded,
      required this.whoSealedtheContainer,
      required this.clearancegivenby,
      required this.itemDisc});

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
        supervisorCode: json['supervisorCode'],
        supervisorName: json['supervisorName'],
        dateofLoading: json['dateofLoading'],
        actualQtyLoaded: json['actualQtyLoaded'],
        whoSealedtheContainer: json['whoSealedtheContainer'],
        clearancegivenby: json['clearancegivenby'],
        itemDisc: json['itemDisc'] ?? "");
  }
}
