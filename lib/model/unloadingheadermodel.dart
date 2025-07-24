class UnloadingHeaderModel {
  String? vehicleNumber;
  String? project;
  String? yardId;
  String? yardName;
  String? whsCode;
  String? salesPersonCode;
  String? salesPersonName;
  String? cardCode;
  String? cardName;

  UnloadingHeaderModel(
      {required this.vehicleNumber,
      required this.project,
      required this.yardId,
      required this.yardName,
      required this.whsCode,
      required this.salesPersonCode,
      required this.salesPersonName,
      required this.cardCode,
      required this.cardName});

  factory UnloadingHeaderModel.fromJson(Map<String, dynamic> json) {
    return UnloadingHeaderModel(
      vehicleNumber: json["vehicleNumber"],
      project: json["project"],
      yardId: json["yardId"],
      yardName: json["yardName"],
      whsCode: json['whsCode'],
      salesPersonCode: json["salesPersonCode"],
      salesPersonName: json["salesPersonName"],
      cardCode: json["cardCode"],
      cardName: json["cardName"],
    );
  }
}
