class YardUnloadAllModel {
  final int yardUnloading;
  final String docDate;
  final String customerName;
  final String vechileNo;
  final String? weighLocation;
  final String documentType;
  final String invoiceType;

  YardUnloadAllModel({
    required this.yardUnloading,
    required this.docDate,
    required this.customerName,
    required this.vechileNo,
    this.weighLocation,
    required this.documentType,
    required this.invoiceType,
  });

  factory YardUnloadAllModel.fromJson(Map<String, dynamic> json) {
    return YardUnloadAllModel(
      yardUnloading: json['yardunloading'] ?? 0,
      docDate: json['docDate'] ?? '',
      customerName: json['customerName'] ?? '',
      vechileNo: json['VechileNo'] ?? '',
      weighLocation: json['WeighLocation'], // nullable
      documentType: json['documentType'] ?? '',
      invoiceType: json['invoiceType'] ?? '',
    );
  }
}
