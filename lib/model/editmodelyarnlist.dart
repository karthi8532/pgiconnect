class YarnEditListModel {
  int? yardLoadingId;
  int? logisticId;
  int? logisticRequestNo;
  String? containerNo;
  int? salesOrderId;
  int? salesOrderNo;
  String? customerCode;
  String? customerName;
  String? noOfContainer;
  List<Item> items;
  List<AttachmentPath> attachmentPath;

  YarnEditListModel({
    required this.yardLoadingId,
    required this.logisticId,
    required this.logisticRequestNo,
    required this.containerNo,
    required this.salesOrderId,
    required this.salesOrderNo,
    required this.customerCode,
    required this.customerName,
    required this.noOfContainer,
    required this.items,
    required this.attachmentPath,
  });

  factory YarnEditListModel.fromJson(Map<String, dynamic> json) {
    return YarnEditListModel(
      yardLoadingId: json['yardloadinglineId'],
      logisticId: json['logisticId'],
      logisticRequestNo: json['logisticRequestNo'],
      containerNo: json['containerNo'],
      salesOrderId: json['salesOrderId'],
      salesOrderNo: json['salesOrderNo'],
      customerCode: json['customerCode'],
      customerName: json['customerName'],
      noOfContainer: json['noOfContainer'] ?? "0",
      items: List<Item>.from(json['items'].map((x) => Item.fromJson(x))),
      attachmentPath: (json['attachmentPath'] as List?)
              ?.map((x) => AttachmentPath.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'yardloadinglineId': yardLoadingId,
        'logisticId': logisticId,
        'logisticRequestNo': logisticRequestNo,
        'containerNo': containerNo,
        'salesOrderId': salesOrderId,
        'salesOrderNo': salesOrderNo,
        'customerCode': customerCode,
        'customerName': customerName,
        'noOfContainer': noOfContainer,
        'items': items.map((x) => x.toJson()).toList(),
      };
}

class Item {
  int? lineId;
  int? yardLoadingLineId;
  String? itemCode;
  String? itemName;
  String? warehouse;
  double? emptyWeight;
  double? grossWeight;
  double? netWeight;
  double? finalDoQty;

  int? baseEntry;
  int? baseLine;
  String? baseType;
  double? packingWeight;
  String? packingtype;
  String? packingtypeName;
  int? noofpack;
  String? sealNo;
  String? vechicleNo;
  String? weighNo;

  Item(
      {required this.lineId,
      required this.yardLoadingLineId,
      required this.itemCode,
      required this.itemName,
      required this.warehouse,
      required this.emptyWeight,
      required this.grossWeight,
      required this.netWeight,
      required this.finalDoQty,
      required this.baseEntry,
      required this.baseLine,
      required this.baseType,
      required this.packingWeight,
      required this.packingtype,
      required this.packingtypeName,
      required this.noofpack,
      required this.sealNo,
      required this.vechicleNo,
      required this.weighNo});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        lineId: json['LineId'],
        yardLoadingLineId: json['yardloadinglineId'],
        itemCode: json['itemCode'],
        itemName: json['itemName'],
        warehouse: json['warehouse'],
        emptyWeight: json['emptyWeight'] is int
            ? (json['emptyWeight'] as int).toDouble()
            : json['emptyWeight'],
        grossWeight: json['grossWeight'] is int
            ? (json['grossWeight'] as int).toDouble()
            : json['grossWeight'],
        netWeight: json['netWeight'] is int
            ? (json['netWeight'] as int).toDouble()
            : json['netWeight'],
        finalDoQty: json['finalDoQty'] is int
            ? (json['finalDoQty'] as int).toDouble()
            : json['finalDoQty'],
        baseEntry: json['baseEntry'],
        baseLine: json['baseLine'],
        baseType: json['baseType'],
        packingWeight: json['packingWeight'] is int
            ? (json['packingWeight'] as int).toDouble()
            : json['packingWeight'],
        packingtype: json['packingType'],
        packingtypeName: json['packingType'],
        noofpack: json['noofpack'] == null
            ? 0
            : json['noofPack'] is int
                ? (json['noofPack'] as int).toDouble()
                : json['noofPack'],
        sealNo: json['sealNo'],
        vechicleNo: json['vechicleNo'],
        weighNo: json['weighNo']);
  }

  Map<String, dynamic> toJson() => {
        'LineId': lineId,
        'yardloadinglineId': yardLoadingLineId,
        'itemCode': itemCode,
        'itemName': itemName,
        'warehouse': warehouse,
        'emptyWeight': emptyWeight,
        'grossWeight': grossWeight,
        'netWeight': netWeight,
        'finalDoQty': finalDoQty,
        'baseEntry': baseEntry,
        'baseLine': baseLine,
        'baseType': baseType,
        'packingWeight': packingWeight,
        'packingType': packingtype,
        'packingtypeName': packingtypeName,
        'noofPack': noofpack,
        'sealNo': sealNo,
        'vechicleNo': vechicleNo,
        'weighNo': weighNo,
      };
}

class AttachmentPath {
  String filename;
  String url;

  AttachmentPath({
    required this.filename,
    required this.url,
  });

  factory AttachmentPath.fromJson(Map<String, dynamic> json) {
    return AttachmentPath(
      filename: json['filename'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'url': url,
      };
}
