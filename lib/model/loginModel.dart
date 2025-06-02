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
  int? branch;
  String? branchName;
  String? dBName;

  User(
      {this.employeName,
      this.userId,
      this.password,
      this.branch,
      this.branchName,
      this.dBName});

  User.fromJson(Map<String, dynamic> json) {
    employeName = json['employeName'];
    userId = json['userId'];
    password = json['password'];
    branch = json['branch'];
    branchName = json['branchName'];
    dBName = json['DBName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employeName'] = employeName;
    data['userId'] = userId;
    data['password'] = password;
    data['branch'] = branch;
    data['branchName'] = branchName;
    data['DBName'] = dBName;
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
