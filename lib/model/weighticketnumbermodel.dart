class WeighTicketNumberModel {
  String? weighTicketNo;

  WeighTicketNumberModel({required this.weighTicketNo});

  factory WeighTicketNumberModel.fromJson(Map<String, dynamic> json) {
    return WeighTicketNumberModel(weighTicketNo: json["WeighTicketNo"]);
  }
}
