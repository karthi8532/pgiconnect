class AllClaimModel {
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
  String? items;
  String? commands;
  String? attachmentPath;

  AllClaimModel({
    this.docEntry,
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
  });

  factory AllClaimModel.fromJson(Map<String, dynamic> json) {
    return AllClaimModel(
      docEntry: json['docEntry'] is int ? json['docEntry'] : int.tryParse(json['docEntry'].toString()),
      docNum: json['docNum'] is int ? json['docNum'] : int.tryParse(json['docNum'].toString()),
      sellType: json['sellType']?.toString(),
      docDate: json['docDate']?.toString(),
      cusName: json['cusName']?.toString(),
      venName: json['venName']?.toString(),
      poNum: json['poNum']?.toString(),
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
      ageing: json['ageing']?.toString(),
      recoveryFromSup: json['recoveryFromSup'] is int ? json['recoveryFromSup'] : int.tryParse(json['recoveryFromSup'].toString()),
      effectonGP: json['effectonGP'] is int ? json['effectonGP'] : int.tryParse(json['effectonGP'].toString()),
      claimAmt: json['claimAmt'] is double ? json['claimAmt'] : double.tryParse(json['claimAmt'].toString()),
      items: json['items']?.toString(),
      commands: json['commands']?.toString(),
      attachmentPath: json['attachmentPath']?.toString(),
    );
  }
}
