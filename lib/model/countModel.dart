class CountModel {
  bool? success;
  List<Result>? result;
  String? message;

  CountModel({this.success, this.result, this.message});

  CountModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Result {
  String? id;
  int? pendingCount;

  Result({this.id, this.pendingCount});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pendingCount = json['pendingCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pendingCount'] = pendingCount;
    return data;
  }
}
