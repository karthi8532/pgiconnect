import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/appconstant.dart';
import 'package:pgiconnect/model/itemModel.dart';
import 'package:path/path.dart';
import 'package:pgiconnect/model/pettrycashitemmodel.dart';

class ApiService {
  Future<http.Response> getloginRequest(dynamic body) async {
    try {
      final response =
          await http.post(Uri.parse(Appconstant.apiBaseUrl + ApiDetails.login),
              headers: {
                "Content-Type": "application/json",
              },
              body: jsonEncode(body));
      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getDblist() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(Appconstant.apiBaseUrl + ApiDetails.databaselist),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getbranchlist(getDbName) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse("${Appconstant.apiBaseUrl}/api/branch/$getDbName"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getlogisticnumberList(
      getDBName, getBranchName, String fromdate, String todate) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}/api/logistic/listAll/$getDBName/$getBranchName?sDate=$fromdate&eDate=$todate"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> geteditlogisticnumberList(
      getDBName, getBranchName, String fromdate, String todate) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}/api/yardloading/listAll/$getDBName/$getBranchName?sDate=$fromdate&eDate=$todate"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getclosedlogisticnumberList(
      getDBName, getBranchName, String fromdate, String todate) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}/api/yardloading/completedlist/$getDBName/$getBranchName?sDate=$fromdate&eDate=$todate"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<List<ItemModel>> getitemMaster(
      logisticID, getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/logistic/itemlist/$logisticID/$getDBName/$getBranchName"),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => ItemModel.fromJson(item)).toList();
      }
      return data
          .map((item) => ItemModel.fromJson(item))
          .where((item) =>
              item.itemCode
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.itemName
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.whsCode
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future postrequest(Map<String, dynamic> finalMap, files, items, getDBName,
      getBranchName) async {
    final url = Uri.parse(
        "${Appconstant.apiBaseUrl}api/logistic/Create/$getDBName/$getBranchName");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    var request = http.MultipartRequest('POST', url);

    // Headers (Include Authorization if required)
    request.headers.addAll(headers);

    // 🔹 Add form-data fields
    request.fields['docEntry'] = finalMap['docEntry'];
    request.fields['docNum'] = finalMap['docNum'];
    request.fields['userId'] = finalMap['userId'];
    request.fields['sONum'] = finalMap['sONum'];
    request.fields['sOEntry'] = finalMap['sOEntry'].toString();
    request.fields['cardCode'] = finalMap['cardCode'];
    request.fields['cardName'] = finalMap['cardName'];
    request.fields['containerNo'] = finalMap['containerNo'];
    request.fields['docStatus'] = finalMap['docStatus'];
    request.fields['items'] = jsonEncode(items);

    for (File filePath in files) {
      File file = File(filePath.path);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            filePath.path,
            filename: basename(filePath.path),
          ),
        );
      }
    }

    var response = await request.send();

    return response;
  }

  Future updateyarnList(Map<String, dynamic> finalMap, files, items, getDBName,
      getBranchName, getYarnLoadingId, removeimages) async {
    print(getYarnLoadingId);
    final url = Uri.parse(
        "${Appconstant.apiBaseUrl}api/yardloading/update/$getDBName/$getBranchName/$getYarnLoadingId");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    var request = http.MultipartRequest('PUT', url);

    // Headers (Include Authorization if required)
    request.headers.addAll(headers);

    // 🔹 Add form-data fields
    request.fields['docEntry'] = finalMap['docEntry'];
    request.fields['docNum'] = finalMap['docNum'];
    request.fields['userId'] = finalMap['userId'];
    request.fields['sONum'] = finalMap['sONum'].toString();
    request.fields['sOEntry'] = finalMap['sOEntry'].toString();
    request.fields['cardCode'] = finalMap['cardCode'];
    request.fields['containerNo'] = finalMap['containerNo'];
    request.fields['cardName'] = finalMap['cardName'];
    request.fields['docStatus'] = finalMap['docStatus'];
    request.fields['items'] = jsonEncode(items);
    request.fields['filesRemoved'] = jsonEncode(removeimages);

    print(request.fields);
    print(jsonEncode(items));

    for (File filePath in files) {
      File file = File(filePath.path);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            filePath.path,
            filename: basename(filePath.path),
          ),
        );
      }
    }

    print(request.fields);

    var response = await request.send();

    return response;
  }

  Future<http.Response> getdashboardcount(getDBName, getBranchName) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}/api/dashboard/$getDBName/$getBranchName"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getwhsList() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              '${Appconstant.apiBaseUrl}api/whs/${Prefs.getDBName('DBName')}'),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> geteditsingleyarnloading(
      getDBName, getBranchName, getId) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}/api/yardloading/read/$getDBName/$getBranchName/$getId"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getclaimlist(getDBName, getBranchName, String fromdate,
      String todate, String modetype) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}api/claimApproval/listAll/$getDBName/$getBranchName?sDate=$fromdate&eDate=$todate&mode=${modetype.toLowerCase()}&userId=${Prefs.getEmpID('Id')}"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getsingleclaimlist(
      getDBName, getBranchName, id, modetype) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}api/claimApproval/read/$getDBName/$getBranchName/$id?mode=${modetype.toLowerCase()}"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future postclaim(items, getDBName, getBranchName) async {
    final url = Uri.parse(
        "${Appconstant.apiBaseUrl}api/claimapproval/Create/$getDBName/$getBranchName?userId=${Prefs.getEmpID("Id")}");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    var request = http.MultipartRequest('POST', url);

    // Headers (Include Authorization if required)
    request.headers.addAll(headers);
    request.fields['commands'] = jsonEncode(items);
    print(request.fields);

    var response = await request.send();

    return response;
  }

  Future<http.Response> getpettycashlist(
      getDBName, getBranchName, String fromdate, String todate) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}/api/PettyCash/listall/$getDBName/$getBranchName?sDate=$fromdate&eDate=$todate"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getpettycashlistsingle(
      getDBName, getBranchName, int docEntry) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}/api/PettyCash/read/$getDBName/$getBranchName?id=$docEntry&status=open"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<List<PettyCashItemModel>> getpettycashitemMaster(
      getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/pettyCash/itemlist/$getDBName/$getBranchName"),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => PettyCashItemModel.fromJson(item)).toList();
      }
      return data
          .map((item) => PettyCashItemModel.fromJson(item))
          .where((item) =>
              item.itemCode
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.itemName
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future postpettycash(items, getDBName, getBranchName) async {
    final url = Uri.parse(
        "${Appconstant.apiBaseUrl}api/PettyCash/Create/$getDBName/$getBranchName");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    var request = http.MultipartRequest('POST', url);

    // Headers (Include Authorization if required)
    request.headers.addAll(headers);
    request.fields['details'] = jsonEncode(items);

    var response = await request.send();

    return response;
  }
}
