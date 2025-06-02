class Dbmodel {
  String? company;
  String? db;

  Dbmodel({required this.company, required this.db});

  factory Dbmodel.fromJson(Map<String, dynamic> json) {
    return Dbmodel(company: json["company"], db: json["db"]);
  }
}
