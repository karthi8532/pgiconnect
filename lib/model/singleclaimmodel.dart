int? toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String? toStringVal(dynamic value) {
  if (value == null) return "";
  return value.toString();
}

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
  String? forwardtocode;
  String? forwardtoName;
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
      this.attachmentPath,
      this.forwardtocode,
      this.forwardtoName});

  factory SingleClaimModel.fromJson(Map<String, dynamic> json) =>
      SingleClaimModel(
        docEntry: toInt(json['docEntry']),
        docNum: toInt(json['docNum']),
        sellType: toStringVal(json['sellType']),
        docDate: toStringVal(json['docDate']),
        cusName: toStringVal(json['cusName']),
        venName: toStringVal(json['venName']),
        poNum: toStringVal(json['poNum']),
        settelmentaggAmt: toDouble(json['settelmentaggAmt']) ?? 0.0,
        etaDate: toStringVal(json['etaDate']),
        claimeInformation: toStringVal(json['claimeInformation']),
        cusClaim: toStringVal(json['cusClaim']),
        billofLoadingNum: toStringVal(json['billofLoadingNum']),
        approverId: toStringVal(json['approverId']),
        approverName: toStringVal(json['approverName']),
        status: toStringVal(json['status']),
        invNum: toStringVal(json['invNum']),
        desigNationofCountry: toStringVal(json['desigNationofCountry']),
        supplierContry: toStringVal(json['supplierContry']),
        claimIntimation: toStringVal(json['claimIntimation']),
        ageing: toStringVal(json['ageing']),
        recoveryFromSup: toInt(json['recoveryFromSup']) ?? 0,
        effectonGP: toInt(json['effectonGP']) ?? 0,
        claimAmt: toDouble(json['claimAmt']) ?? 0.0,
        items:
            (json['items'] as List?)?.map((e) => Items.fromJson(e)).toList() ??
                [],
        commands: (json['commands'] as List?)
                ?.map((e) => Commands.fromJson(e))
                .toList() ??
            [],
        attachmentPath: (json['attachmentPath'] as List?)
                ?.map((e) => AttachmentPath.fromJson(e))
                .toList() ??
            [],
      );
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

  Items({
    this.lineId,
    this.itemCode,
    this.itemName,
    this.containerNo,
    this.invoiceQty,
    this.provicionalClaimAmt,
    this.quantityAmt,
    this.qualityAmt,
    this.toatalAmt,
    this.shortageQty,
  });

  factory Items.fromJson(Map<String, dynamic> json) => Items(
        lineId: toInt(json['lineId']),
        itemCode: toStringVal(json['itemCode']),
        itemName: toStringVal(json['itemName']),
        containerNo: toStringVal(json['containerNo']),
        invoiceQty: toDouble(json['invoiceQty']) ?? 0.0,
        provicionalClaimAmt: toDouble(json['provicionalClaimAmt']) ?? 0.0,
        quantityAmt: toDouble(json['quantityAmt']) ?? 0.0,
        qualityAmt: toDouble(json['qualityAmt']) ?? 0.0,
        toatalAmt: toDouble(json['toatalAmt']) ?? 0.0,
        shortageQty: toDouble(json['shortageQty']) ?? 0.0,
      );
}

class Commands {
  int? docEntry;
  String? appPosition;
  String? approverCode;
  String? approverName;
  String? approverStatus;
  String? tempStatus;
  String? department;
  String? departmentnew;
  String? userId;
  String? appDate;
  String? remarks;
  String? appType;
  String? toApproverCode;
  String? fromApproverCode;
  String? canEndit;

  Commands(
      {this.docEntry,
      this.appPosition,
      this.approverCode,
      this.approverName,
      this.approverStatus,
      this.tempStatus,
      this.department,
      this.departmentnew,
      this.userId,
      this.appDate,
      this.remarks,
      this.appType,
      this.toApproverCode,
      this.fromApproverCode,
      this.canEndit});

  factory Commands.fromJson(Map<String, dynamic> json) => Commands(
      docEntry: toInt(json['docEntry']),
      appPosition: toStringVal(json['appPosition']),
      approverCode: toStringVal(json['approverCode']),
      approverName: toStringVal(json['approverName']),
      approverStatus: toStringVal(json['approverStatus']),
      tempStatus: toStringVal(json['approverStatus']), // <== initialize here
      department: toStringVal(json['department']),
      departmentnew: toStringVal(json['department']),
      userId: toStringVal(json['userId']),
      appDate: toStringVal(json['appDate']),
      remarks: toStringVal(json['remarks']),
      appType: toStringVal(json['appType']),
      fromApproverCode: toStringVal(json['fromApproverCode']),
      toApproverCode: toStringVal(json['toApproverCode']),
      canEndit: toStringVal(json['canEndit']));
}

class AttachmentPath {
  String? filename;
  String? url;

  AttachmentPath({this.filename, this.url});

  factory AttachmentPath.fromJson(Map<String, dynamic> json) => AttachmentPath(
        filename: toStringVal(json['filename']),
        url: toStringVal(json['url']),
      );

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'url': url,
      };
}
