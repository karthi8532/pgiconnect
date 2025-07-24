class PendingItem {
  String invoiceType;
  String documentType;
  int wgId;
  String ticketNo;
  String trnDate;
  String customerName;
  String itemCode;
  String itemName;
  String warehouse;
  double quantity;
  double unitPrice;
  double controlPrice;
  double lMELevelFormula;
  String controlPercentage;
  double lMEAmount;
  int contango;
  String hedgingRequired;
  String poNumber;
  var pOEntry;
  int poLine;
  String purchaseRemarks;
  double total;
  String slpCode;
  String slpName;
  String lMEFixationDate;
  bool ismanuall;

  PendingItem(
      {required this.invoiceType,
      required this.documentType,
      required this.wgId,
      required this.ticketNo,
      required this.trnDate,
      required this.customerName,
      required this.itemCode,
      required this.itemName,
      required this.warehouse,
      required this.quantity,
      required this.unitPrice,
      required this.controlPrice,
      required this.lMELevelFormula,
      required this.controlPercentage,
      required this.lMEAmount,
      required this.contango,
      required this.hedgingRequired,
      required this.poNumber,
      required this.pOEntry,
      required this.poLine,
      required this.purchaseRemarks,
      required this.total,
      required this.slpCode,
      required this.slpName,
      required this.lMEFixationDate,
      required this.ismanuall});

  factory PendingItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return val;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is String) return int.tryParse(val) ?? 0;
      return val;
    }

    return PendingItem(
      invoiceType: json['invoiceType'] ?? '',
      documentType: json['documentType'] ?? '',
      wgId: parseInt(json['wgId']),
      ticketNo: json['ticketNo'] ?? '',
      trnDate: json['trnDate'] ?? '',
      customerName: json['customerName'] ?? '',
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      warehouse: json['warehouse'] ?? '',
      quantity: parseDouble(json['quantity']),
      unitPrice: parseDouble(json['unitPrice']),
      controlPrice: parseDouble(json['controlPirce']),
      lMELevelFormula: parseDouble(json['lMELevelFormula']),
      controlPercentage: json['controlPrcentage'] ?? '',
      lMEAmount: parseDouble(json['lMEAmount']),
      contango: parseInt(json['contango']),
      hedgingRequired: json['HEDGINGREQUIRED'] ?? '',
      poNumber: json['pONum'] ?? '',
      pOEntry: parseInt(json['pOEntry']),
      poLine: parseInt(json['poLine']),
      purchaseRemarks: json['purchaseRemark'] ?? '',
      total: parseDouble(json['Total']),
      slpCode: json['slpCode'] ?? '',
      slpName: json['slpName'] ?? '',
      lMEFixationDate: json['lMEFixationDate'] ?? '',
      ismanuall: json['ismanuall'] == true || json['ismanuall'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceType': invoiceType,
      'documentType': documentType,
      'wgId': wgId,
      'ticketNo': ticketNo,
      'trnDate': trnDate,
      'customerName': customerName,
      'itemCode': itemCode,
      'itemName': itemName,
      'warehouse': warehouse,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'controlPirce': controlPrice,
      'lMELevelFormula': lMELevelFormula,
      'controlPrcentage': controlPercentage,
      'lMEAmount': lMEAmount,
      'contango': contango,
      'HEDGINGREQUIRED': hedgingRequired,
      'pONum': poNumber,
      'pOEntry': pOEntry,
      'poLine': poLine,
      'purchaseRemark': purchaseRemarks,
      'Total': total,
      'slpCode': slpCode,
      'slpName': slpName,
      'lMEFixationDate': lMEFixationDate,
      'ismanuall': ismanuall,
    };
  }
}
