import 'dart:convert';

class PettyCashAllModel {
  final int docEntry;
  final String docDate;
  final double totalAmount;
  final String pettyCashReqstFor;
  final String discription;
  final String approvedByCode;
  final String approvedByName;
  final String recivedByCode;
  final String recivedByName;
  final String docStatus;
  final List<PettyCashItem> items;

  PettyCashAllModel({
    required this.docEntry,
    required this.docDate,
    required this.totalAmount,
    required this.pettyCashReqstFor,
    required this.discription,
    required this.approvedByCode,
    required this.approvedByName,
    required this.recivedByCode,
    required this.recivedByName,
    required this.docStatus,
    required this.items,
  });

  factory PettyCashAllModel.fromJson(Map<String, dynamic> json) {
    return PettyCashAllModel(
      docEntry: json['docEntry'],
      docDate: json['docDate'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      pettyCashReqstFor: json['pettyCashReqstFor'],
      discription: json['discription'],
      approvedByCode: json['approvedByCode'],
      approvedByName: json['approvedByName'],
      recivedByCode: json['recivedByCode'],
      recivedByName: json['recivedByName'],
      docStatus: json['docStatus'] ?? '',
      items: (jsonDecode(json['items']) as List)
          .map((item) => PettyCashItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docEntry': docEntry,
      'docDate': docDate,
      'totalAmount': totalAmount,
      'pettyCashReqstFor': pettyCashReqstFor,
      'discription': discription,
      'approvedByCode': approvedByCode,
      'approvedByName': approvedByName,
      'recivedByCode': recivedByCode,
      'recivedByName': recivedByName,
      'docStatus': docStatus,
      'items': jsonEncode(items.map((e) => e.toJson()).toList()),
    };
  }
}

class PettyCashItem {
  final String itemCode;
  final String itemName;
  final double lineAmount;
  final String lineRemarks;

  PettyCashItem({
    required this.itemCode,
    required this.itemName,
    required this.lineAmount,
    required this.lineRemarks,
  });

  factory PettyCashItem.fromJson(Map<String, dynamic> json) {
    return PettyCashItem(
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      lineAmount: (json['lineAmount'] ?? 0).toDouble(),
      lineRemarks: json['lineRemarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'itemName': itemName,
      'lineAmount': lineAmount,
      'lineRemarks': lineRemarks,
    };
  }
}
