class SingleClaimModel {
  int? docEntry;
  int? docNum;
  String? sellType;
  String? docDate;
  String? cusName;
  String? venName;
  String? poNum;
  double? settelmentaggAmt;
  String? etaDate;
  String? claimeInformation;
  String? cusClaim;
  String? billofLoadingNum;
  String? approverId;
  String? approverName;
  String? status;
  String? invNum;
  String? desigNationofCountry;
  String? supplierContry;
  String? claimIntimation;
  String? ageing;
  int? recoveryFromSup;
  int? effectonGP;
  double? claimAmt;
  List<Items>? items;
  List<Commands>? commands;
  List<AttachmentPath>? attachmentPath;

  SingleClaimModel(
      {this.docEntry,
      this.docNum,
      this.sellType,
      this.docDate,
      this.cusName,
      this.venName,
      this.poNum,
      this.settelmentaggAmt,
      this.etaDate,
      this.claimeInformation,
      this.cusClaim,
      this.billofLoadingNum,
      this.approverId,
      this.approverName,
      this.status,
      this.invNum,
      this.desigNationofCountry,
      this.supplierContry,
      this.claimIntimation,
      this.ageing,
      this.recoveryFromSup,
      this.effectonGP,
      this.claimAmt,
      this.items,
      this.commands,
      this.attachmentPath});

  factory SingleClaimModel.fromJson(Map<String, dynamic> json) {
    return SingleClaimModel(
      docEntry: json['docEntry'] is int
          ? json['docEntry']
          : int.tryParse(json['docEntry'].toString()),
      docNum: json['docNum'] is int
          ? json['docNum']
          : int.tryParse(json['docNum'].toString()),
      sellType: json['sellType']?.toString(),
      docDate: json['docDate']?.toString(),
      cusName: json['cusName']?.toString(),
      venName: json['venName']?.toString(),
      poNum: json['poNum'] ?? "",
      settelmentaggAmt: json['settelmentaggAmt'] is double
          ? json['settelmentaggAmt']
          : double.tryParse(json['settelmentaggAmt'].toString()),
      etaDate: json['etaDate']?.toString(),
      claimeInformation: json['claimeInformation']?.toString(),
      cusClaim: json['cusClaim']?.toString(),
      billofLoadingNum: json['billofLoadingNum']?.toString(),
      approverId: json['approverId']?.toString(),
      approverName: json['approverName']?.toString(),
      status: json['status']?.toString(),
      invNum: json['invNum']?.toString(),
      desigNationofCountry: json['desigNationofCountry']?.toString(),
      supplierContry: json['supplierContry']?.toString(),
      claimIntimation: json['claimIntimation']?.toString(),
      ageing: json['ageing'] ?? "",
      recoveryFromSup: json['recoveryFromSup'] is int
          ? json['recoveryFromSup']
          : int.tryParse(json['recoveryFromSup'].toString()),
      effectonGP: json['effectonGP'] is int
          ? json['effectonGP']
          : int.tryParse(json['effectonGP'].toString()),
      claimAmt: json['claimAmt'] is double
          ? json['claimAmt']
          : double.tryParse(json['claimAmt'].toString()),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => Items.fromJson(e))
          .toList(),
      commands: (json['commands'] as List<dynamic>?)
          ?.map((e) => Commands.fromJson(e))
          .toList(),
      attachmentPath: (json['attachmentPath'] as List<dynamic>?)
          ?.map((e) => AttachmentPath.fromJson(e))
          .toList(),
    );
  }
}

class Items {
  int? lineId;
  String? itemCode;
  String? itemName;
  String? containerNo;
  double? invoiceQty;
  double? provicionalClaimAmt;
  double? quantityAmt;
  double? qualityAmt;
  double? toatalAmt;
  double? shortageQty;

  Items(
      {this.lineId,
      this.itemCode,
      this.itemName,
      this.containerNo,
      this.invoiceQty,
      this.provicionalClaimAmt,
      this.quantityAmt,
      this.qualityAmt,
      this.toatalAmt,
      this.shortageQty});

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      lineId: json['lineId'],
      itemCode: json['itemCode'],
      itemName: json['itemName'],
      containerNo: json['containerNo'],
      invoiceQty: json['invoiceQty'] is int
          ? (json['invoiceQty'] as int).toDouble()
          : json['invoiceQty'],
      provicionalClaimAmt: json['provicionalClaimAmt'] is int
          ? (json['provicionalClaimAmt'] as int).toDouble()
          : json['provicionalClaimAmt'],
      quantityAmt: json['quantityAmt'] is int
          ? (json['quantityAmt'] as int).toDouble()
          : json['quantityAmt'],
      qualityAmt: json['qualityAmt'] is int
          ? (json['qualityAmt'] as int).toDouble()
          : json['qualityAmt'],
      toatalAmt: json['toatalAmt'] is int
          ? (json['toatalAmt'] as int).toDouble()
          : json['toatalAmt'],
      shortageQty: json['shortageQty'] is int
          ? (json['shortageQty'] as int).toDouble()
          : json['shortageQty'],
    );
  }
}

class Commands {
  int? docEntry;
  String? appPosition;
  String? approverCode;
  String? approverName;
  String? approverStatus;
  String? department;
  String? userId;
  String? appDate;
  String? remarks;
  String? appType;

  Commands(
      {this.docEntry,
      this.appPosition,
      this.approverCode,
      this.approverName,
      this.approverStatus,
      this.department,
      this.userId,
      this.appDate,
      this.remarks,
      this.appType});

  factory Commands.fromJson(Map<String, dynamic> json) {
    return Commands(
        docEntry: json['docEntry'],
        appPosition: json['appPosition'],
        approverCode: json['approverCode'],
        approverName: json['approverName'],
        approverStatus: json['approverStatus'],
        department: json['department'],
        userId: json['userId'],
        appDate: json['appDate'],
        remarks: json['remarks'],
        appType: json['appType']);
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
