class EditUnloadModel {
  final int yardunloading;
  final String docDate;
  final String cardCode;
  final String customerName;
  final String vechileNo;
  final String slpCode;
  final String slpName;
  final String? weighLocation;
  final String? wightNos;
  final String documentType;
  final String invoiceType;
  final String itemCode;
  final String itemName;
  final double quantity;
  final String warehouse;
  final String warehousename;
  final double unitPrice;
  final double controlPirce;
  final double lmeLevelFormula;
  final double controlPrcentage;
  final double lmeAmount;
  final String lmeFixationDate;
  final double contango;
  final String hedginRequied;
  final String pONum;
  final String pOEntry;
  final int? poLine;
  final String purchaseRemark;
  final double total;
  final String agentCode;
  final String? agentName;
  final String wightFromDate;
  final String wightToDate;
  final String postGRN;
  final String projCode;
  final String projName;
  final String yard;
  final String yardName;
  final String warehouseName;
  List<AttachmentPath> attachmentPath;
  EditUnloadModel({
    required this.yardunloading,
    required this.docDate,
    required this.cardCode,
    required this.customerName,
    required this.vechileNo,
    required this.slpCode,
    required this.slpName,
    required this.weighLocation,
    required this.wightNos,
    required this.documentType,
    required this.invoiceType,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.warehouse,
    required this.warehousename,
    required this.unitPrice,
    required this.controlPirce,
    required this.lmeLevelFormula,
    required this.controlPrcentage,
    required this.lmeAmount,
    required this.lmeFixationDate,
    required this.contango,
    required this.hedginRequied,
    required this.pONum,
    required this.pOEntry,
    required this.poLine,
    required this.purchaseRemark,
    required this.total,
    required this.agentCode,
    required this.agentName,
    required this.wightFromDate,
    required this.wightToDate,
    required this.postGRN,
    required this.projCode,
    required this.projName,
    required this.yard,
    required this.yardName,
    required this.warehouseName,
    required this.attachmentPath,
  });

  factory EditUnloadModel.fromJson(Map<String, dynamic> json) {
    return EditUnloadModel(
        yardunloading: json['yardunloading'] ?? 0,
        docDate: json['docDate'] ?? '',
        cardCode: json['cardCode'] ?? '',
        customerName: json['customerName'] ?? '',
        vechileNo: json['VechileNo'] ?? '',
        slpCode: json['SlpCode'] ?? '',
        slpName: json['SlpName'] ?? '',
        weighLocation: json['WeighLocation'],
        wightNos: json['WightNos'] ?? '',
        documentType: json['documentType'] ?? '',
        invoiceType: json['invoiceType'] ?? '',
        itemCode: json['itemCode'] ?? '',
        itemName: json['itemName'] ?? '',
        quantity: (json['Quantity'] ?? 0).toDouble(),
        warehouse: json['warehouse'] ?? '',
        warehousename: json['warehouseName'] ?? '',
        unitPrice: (json['unitPrice'] ?? 0).toDouble(),
        controlPirce: (json['controlPirce'] ?? 0).toDouble(),
        lmeLevelFormula: (json['lMELevelFormula'] ?? 0).toDouble(),
        controlPrcentage: (json['controlPrcentage'] ?? 0).toDouble(),
        lmeAmount: (json['lMEAmount'] ?? 0).toDouble(),
        lmeFixationDate: json['lMEFixationDate'] ?? '',
        contango: (json['contango'] ?? 0).toDouble(),
        hedginRequied: json['hedginRequied'] ?? '',
        pONum: json['pONum'] ?? '',
        pOEntry: json['pOEntry'] ?? '',
        poLine: json['poLine'],
        purchaseRemark: json['purchaseRemark'] ?? '',
        total: (json['Total'] ?? 0).toDouble(),
        agentCode: json['agentCode'] ?? '',
        agentName: json['agentName'],
        wightFromDate: json['wightFromDate'] ?? '',
        wightToDate: json['wightToDate'] ?? '',
        postGRN: json['postGRN'] ?? '',
        projCode: json['projCode'] ?? '',
        projName: json['projectName'] ?? '',
        yard: json['yard'] ?? '',
        yardName: json['yardName'] ?? '',
        warehouseName: json['warehouseName'] ?? "",
        attachmentPath: (json['attachmentPath'] as List?)
                ?.map((x) => AttachmentPath.fromJson(x))
                .toList() ??
            []);
  }

  Map<String, dynamic> toJson() {
    return {
      "yardunloading": yardunloading,
      "docDate": docDate,
      "cardCode": cardCode,
      "customerName": customerName,
      "VechileNo": vechileNo,
      "SlpCode": slpCode,
      "SlpName": slpName,
      "WeighLocation": weighLocation,
      "WightNos": wightNos,
      "documentType": documentType,
      "invoiceType": invoiceType,
      "itemCode": itemCode,
      "itemName": itemName,
      "Quantity": quantity,
      "warehouse": warehouse,
      "warehouseName": warehousename,
      "unitPrice": unitPrice,
      "controlPirce": controlPirce,
      "lMELevelFormula": lmeLevelFormula,
      "controlPrcentage": controlPrcentage,
      "lMEAmount": lmeAmount,
      "lMEFixationDate": lmeFixationDate,
      "contango": contango,
      "hedginRequied": hedginRequied,
      "pONum": pONum,
      "pOEntry": pOEntry,
      "poLine": poLine,
      "purchaseRemark": purchaseRemark,
      "Total": total,
      "agentCode": agentCode,
      "agentName": agentName,
      "wightFromDate": wightFromDate,
      "wightToDate": wightToDate,
      "postGRN": postGRN,
      "projCode": projCode,
      "projectName": projName,
      "yard": yard,
      "yardName": yardName,
    };
  }
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
