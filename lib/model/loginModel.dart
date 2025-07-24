class LoginModel {
  bool? success;
  User? user;
  String? message;
  Token? token;

  LoginModel({this.success, this.user, this.message, this.token});

  LoginModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    message = json['message'];
    token = json['token'] != null ? Token.fromJson(json['token']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['message'] = message;
    if (token != null) {
      data['token'] = token!.toJson();
    }
    return data;
  }
}

class User {
  String? employeName;
  String? userId;
  String? password;
  int? empID;
  int? branch;
  String? branchName;
  String? dBName;
  String? weigLocid;
  String? weigLocname;

  User(
      {this.employeName,
      this.userId,
      this.password,
      this.empID,
      this.branch,
      this.branchName,
      this.dBName,
      this.weigLocid,
      this.weigLocname});

  User.fromJson(Map<String, dynamic> json) {
    employeName = json['employeName'];
    userId = json['userId'];
    password = json['password'];
    empID = json['empID'];
    branch = json['branch'];
    branchName = json['branchName'];
    dBName = json['DBName'];
    weigLocid = json['WeigLocid'];
    weigLocname = json['WeigLocValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employeName'] = employeName;
    data['userId'] = userId;
    data['password'] = password;
    data['empID'] = empID;
    data['branch'] = branch;
    data['branchName'] = branchName;
    data['DBName'] = dBName;
    data['WeigLocid'] = weigLocid;
    data['WeigLocValue'] = weigLocname;
    return data;
  }
}

class Token {
  String? accessToken;

  Token({this.accessToken});

  Token.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    return data;
  }
}
