import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/appconstant.dart';
import 'package:pgiconnect/model/agentmodel.dart';
import 'package:pgiconnect/model/itemModel.dart';
import 'package:path/path.dart';
import 'package:pgiconnect/model/newItemModel.dart';
import 'package:pgiconnect/model/pettrycashitemmodel.dart';
import 'package:pgiconnect/model/poselectionmodel%20copy.dart';
import 'package:pgiconnect/model/poselectionmodel.dart';
import 'package:pgiconnect/model/projectmodel%20copy.dart';
import 'package:pgiconnect/model/projectmodel.dart';
import 'package:pgiconnect/model/supervisorModel.dart';
import 'package:pgiconnect/model/suplliermodel.dart';
import 'package:pgiconnect/model/warehousemodel.dart';
import 'package:pgiconnect/model/weighlocation.dart';
import 'package:pgiconnect/model/weighticketnumbermodel.dart';
import 'package:pgiconnect/model/yadmodel.dart';

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

  Future<http.StreamedResponse> postrequest(
    Map<String, dynamic> finalMap,
    List<File> files,
    List items,
    String getDBName,
    String getBranchName,
    List<File> selectedImages,
  ) async {
    final url = Uri.parse(
        "${Appconstant.apiBaseUrl}api/logistic/Create/$getDBName/$getBranchName");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);

    // Add form-data fields

    request.fields['db'] = getDBName;
    request.fields['branch'] = Prefs.getBranchName("BranchName").toString();
    request.fields['docEntry'] = finalMap['docEntry'];
    request.fields['docNum'] = finalMap['docNum'];
    request.fields['userId'] = finalMap['userId'];
    request.fields['containerNo'] = finalMap['containerNo'];
    request.fields['sONum'] = finalMap['sONum'];
    request.fields['sOEntry'] = finalMap['sOEntry'].toString();
    request.fields['cardCode'] = finalMap['cardCode'];
    request.fields['cardName'] = finalMap['cardName'];
    request.fields['lineId'] = "0";
    request.fields['device'] = "";
    request.fields['docStatus'] = finalMap['docStatus'];
    request.fields['supervisorCode'] = finalMap['supervisorCode'];
    request.fields['supervisorName'] = finalMap['supervisorName'];
    request.fields['dateofLoading'] = finalMap['dateofLoading'];
    request.fields['actualQtyLoaded'] = finalMap['actualQtyLoaded'];
    request.fields['whoSealedtheContainer'] = finalMap['whoSealedtheContainer'];
    request.fields['clearancegivenby'] = finalMap['clearancegivenby'];
    request.fields['sealNo'] = finalMap['sealNo'];
    request.fields['vechicleNo'] = finalMap['vechicleNo'];
    request.fields['weighNo'] = finalMap['weighNo'];
    request.fields['items'] = jsonEncode(items);

    // Upload 'files'
    for (final file in files) {
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'files',
          file.path,
          filename: basename(file.path),
        ));
      }
    }

    // Upload 'selectedFiles'
    for (final file in selectedImages) {
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'selectedFiles',
          file.path,
          filename: basename(file.path),
        ));
      }
    }
    print("🔸 Form Fields:");
    request.fields.forEach((key, value) {
      print("  $key: $value");
    });

    print("🔹 Attached Files:");
    for (final file in request.files) {
      print("  Field: ${file.field}, Filename: ${file.filename}");
    }
    return await request.send();
  }

  Future<http.StreamedResponse> updateyarnList(
    Map<String, dynamic> finalMap,
    List<File> files,
    List<dynamic> items,
    String getDBName,
    String getBranchName,
    dynamic getYarnLoadingId,
    List<dynamic> removeImages,
    List<File> selectedImages,
  ) async {
    final url = Uri.parse(
      "${Appconstant.apiBaseUrl}api/yardloading/update/$getDBName/$getBranchName/$getYarnLoadingId",
    );

    Map<String, String> headers = {
      "Authorization": "Bearer ${Prefs.getToken('token')}",
      // "Content-Type": is automatically handled by MultipartRequest
    };

    var request = http.MultipartRequest('PUT', url);
    request.headers.addAll(headers);

    // 🔹 Add form fields
    request.fields['docEntry'] = finalMap['docEntry'] ?? '';
    request.fields['docNum'] = finalMap['docNum'] ?? '';
    request.fields['userId'] = finalMap['userId'] ?? '';
    request.fields['sONum'] = finalMap['sONum']?.toString() ?? '';
    request.fields['sOEntry'] = finalMap['sOEntry']?.toString() ?? '';
    request.fields['cardCode'] = finalMap['cardCode'] ?? '';
    request.fields['containerNo'] = finalMap['containerNo'] ?? '';
    request.fields['cardName'] = finalMap['cardName'] ?? '';
    request.fields['docStatus'] = finalMap['docStatus'] ?? '';
    request.fields['supervisorCode'] = finalMap['supervisorCode'];
    request.fields['supervisorName'] = finalMap['supervisorName'];
    request.fields['dateofLoading'] = finalMap['dateofLoading'];
    request.fields['actualQtyLoaded'] = finalMap['actualQtyLoaded'];
    request.fields['whoSealedtheContainer'] = finalMap['whoSealedtheContainer'];
    request.fields['clearancegivenby'] = finalMap['clearancegivenby'];
    request.fields['sealNo'] = finalMap['sealNo'];
    request.fields['vechicleNo'] = finalMap['vechicleNo'];
    request.fields['weighNo'] = finalMap['weighNo'];

    request.fields['clearancegivenby'] = finalMap['clearancegivenby'];
    request.fields['items'] = jsonEncode(items);
    request.fields['filesRemoved'] = jsonEncode(removeImages);

    // 🖨 Debug form fields
    print("📝 UPDTE Fields being sent:");
    request.fields.forEach((key, value) => print("  $key: $value"));

    // 📁 Attach 'files'
    for (File filePath in files) {
      if (await filePath.exists()) {
        print("📁 UPDTE Attaching file: ${basename(filePath.path)}");
        request.files.add(await http.MultipartFile.fromPath(
          'files',
          filePath.path,
          filename: basename(filePath.path),
        ));
      }
    }

    // 📁 Attach 'selectedImages'
    for (File filePath in selectedImages) {
      if (await filePath.exists()) {
        print("📸 UPDATE Attaching selectedImage: ${basename(filePath.path)}");
        request.files.add(await http.MultipartFile.fromPath(
          'selectedFiles',
          filePath.path,
          filename: basename(filePath.path),
        ));
      }
    }

    // 🔄 Send request
    print("🔸 UPDTE Form Fields:");
    request.fields.forEach((key, value) {
      print("  $key: $value");
    });

    print("🔹 UPDATEAttached Files:");
    for (final file in request.files) {
      print("UPDATEField: ${file.field}, UPDATEFilename: ${file.filename}");
    }
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
              "${Appconstant.apiBaseUrl}api/yardloading/read/$getDBName/$getBranchName/$getId"),
          headers: headers);
      print(jsonEncode(getId));
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
      print(
          "${Appconstant.apiBaseUrl}api/claimApproval/listAll/$getDBName/$getBranchName?sDate=$fromdate&eDate=$todate&mode=${modetype.toLowerCase()}&userId=${Prefs.getEmpID('Id')}");
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
              "${Appconstant.apiBaseUrl}api/claimApproval/read/$getDBName/$getBranchName/$id?mode=${modetype.toLowerCase()}&userId=${Prefs.getEmpID('Id').toString()}"),
          headers: headers);
      print(id);
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

  static Future<List<SuppplierModel>> getsupplierlist(getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=Suplier"),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => SuppplierModel.fromJson(item)).toList();
      }
      return data
          .map((item) => SuppplierModel.fromJson(item))
          .where((item) =>
              item.id
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.value
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<AgentModel>> getAgentlist(getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=Agent"),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => AgentModel.fromJson(item)).toList();
      }
      return data
          .map((item) => AgentModel.fromJson(item))
          .where((item) =>
              item.id
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.value
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<ProjectModel>> getprojectlist(getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=Projects"),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => ProjectModel.fromJson(item)).toList();
      }
      return data
          .map((item) => ProjectModel.fromJson(item))
          .where((item) =>
              item.id
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.value
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<YardModel>> getyardlist(getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=Yard"),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => YardModel.fromJson(item)).toList();
      }
      return data
          .map((item) => YardModel.fromJson(item))
          .where((item) =>
              item.id
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.value
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<WarehouseModel>> getwarehouselist(getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=Whs"),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => WarehouseModel.fromJson(item)).toList();
      }
      return data
          .map((item) => WarehouseModel.fromJson(item))
          .where((item) =>
              item.id
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.value
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<SalesPersonModel>> getsalesperson(getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=Salesperson"),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => SalesPersonModel.fromJson(item)).toList();
      }
      return data
          .map((item) => SalesPersonModel.fromJson(item))
          .where((item) =>
              item.id
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.value
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<WeighLocationModel>> getwaybridgelocation(
      getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=WeighLoc"),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => WeighLocationModel.fromJson(item)).toList();
      }
      return data
          .map((item) => WeighLocationModel.fromJson(item))
          .where((item) =>
              item.id
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.value
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<http.Response> getpolist(
    cardCode,
    getDBName,
    getBranchName,
  ) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              '${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=PO&cardCode=$cardCode'),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getpendingunloadingitesm(
      getDBName,
      getBranchName,
      // String fromdate,
      // String todate,
      String cardCode,
      String cardName,
      String vehicleNo,
      String location,
      String ticketNo) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              '${Appconstant.apiBaseUrl}api/yardunloading/details/$getDBName/$getBranchName?field=itemDetails&weighNo=$ticketNo'),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future<http.Response> getunloadingall(getDBName, getBranchName,
      String fromdate, String todate, String module, String status) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}api/yardunloading/listAll/$getDBName/$getBranchName?status=$status&module=$module&sDate=$fromdate&eDate=$todate&userID=${Prefs.getEmpID('Id')}"),
          headers: headers);
      print(
          "${Appconstant.apiBaseUrl}api/yardunloading/listAll/$getDBName/$getBranchName?status=$status&module=$module&sDate=$fromdate&eDate=$todate&userID=${Prefs.getEmpID('Id')}");
      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  Future postrequestunloading(
    Map<String, dynamic> finalMap,
    List<File> files,
    List<dynamic> items,
    getDBName,
    getBranchName,
    String type,
    List<dynamic> removeImages,
    List<File> selectedImages,
  ) async {
    final url = Uri.parse(
        "${Appconstant.apiBaseUrl}api/$type/Create/$getDBName/$getBranchName");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    var request = http.MultipartRequest('POST', url);

    // Headers (Include Authorization if required)
    request.headers.addAll(headers);

    // 🔹 Add form-data fields
    request.fields['docEntry'] = finalMap['docEntry'].toString();
    request.fields['createDate'] = finalMap['createDate'];
    request.fields['createTime'] = finalMap['createTime'];
    request.fields['device'] = finalMap['device'];
    request.fields['remark'] = finalMap['remark'].toString();
    request.fields['cardCode'] = finalMap['cardCode'];
    request.fields['cardName'] = finalMap['cardName'];
    request.fields['wightFromDate'] = finalMap['wightFromDate'];
    request.fields['wightToDate'] = finalMap['wightToDate'];
    request.fields['wightNos'] = finalMap['wightNos'];
    request.fields['vehicleNo'] = finalMap['vehicleNo'];
    request.fields['yard'] = finalMap['yard'].toString();
    request.fields['docDate'] = finalMap['docDate'];
    request.fields['docType'] = finalMap['docType'];
    request.fields['taxGroup'] = finalMap['taxGroup'];
    request.fields['driverName'] = finalMap['driverName'];
    request.fields['dMobileNo'] = finalMap['dMobileNo'];
    request.fields['slpCode'] = finalMap['slpCode'];
    request.fields['slpName'] = finalMap['slpName'];
    request.fields['agentCode'] = finalMap['agentCode'].toString();
    request.fields['postGRN'] = finalMap['postGRN'];
    request.fields['supervisor'] = finalMap['supervisor'];
    request.fields['status'] = finalMap['status'];
    request.fields['projCode'] = finalMap['projCode'];
    request.fields['items'] = jsonEncode(items);
    request.fields['createdBy'] = finalMap['createdBy'];
    request.fields['user2'] = finalMap['user2'];
    request.fields['PriceStatus'] = finalMap['PriceStatus'];
    request.fields['weighLocation'] = finalMap['weighLocation'];
    request.fields['whsCode'] = finalMap['whsCode'];
    request.fields['filesRemoved'] = jsonEncode(removeImages);
    request.fields['baseLine'] = finalMap['baseLine']?.toString() ?? '';
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

    for (File filePath in selectedImages) {
      if (await filePath.exists()) {
        print("📸 UPDATE Attaching selectedImage: ${basename(filePath.path)}");
        request.files.add(await http.MultipartFile.fromPath(
          'selectedFiles',
          filePath.path,
          filename: basename(filePath.path),
        ));
      }
    }
    log(jsonEncode(request.fields));
    var response = await request.send();

    return response;
  }

  Future<http.Response> editunloadingall(
      getDBName, getBranchName, String docentry, String type) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              "${Appconstant.apiBaseUrl}api/$type/read/$getDBName/$getBranchName/$docentry"),
          headers: headers);

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<List<PoModel>> getpolists(getDBName, getBranchName, getcardCode,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            '${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=PO&cardCode=$getcardCode'),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => PoModel.fromJson(item)).toList();
      }
      return data
          .map((item) => PoModel.fromJson(item))
          .where((item) =>
              item.poNumber
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.poEntry
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<PoLineModel>> getpolinenumber(
      getDBName, getBranchName, getcardCode, poNum,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            '${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=poLine&poEntry=$poNum'),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => PoLineModel.fromJson(item)).toList();
      }
      return data
          .map((item) => PoLineModel.fromJson(item))
          .where((item) =>
              item.id
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.value
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<SuperVisorModel>> getsupervisorlists(
      getDBName, getBranchName,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            '${Appconstant.apiBaseUrl}api/yardunloading/masters/$getDBName/$getBranchName?objct=yardunload&mode=pending&field=Supervisor'),
        headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => SuperVisorModel.fromJson(item)).toList();
      }
      return data
          .map((item) => SuperVisorModel.fromJson(item))
          .where((item) =>
              item.id
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.value
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<WeighTicketNumberModel>> getwayticketList(
      getDBName, getBranchName, getWeighLocationCode,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/yardunloading/details/$getDBName/$getBranchName?field=weighTicketNo&userId=${Prefs.getEmpID("Id")}&weighLoc=$getWeighLocationCode"),
        headers: headers);
    print(
        "${Appconstant.apiBaseUrl}api/yardunloading/details/$getDBName/$getBranchName?field=weighTicketNo&userId=${Prefs.getEmpID("Id")}&weighLoc=$getWeighLocationCode");
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data
            .map((item) => WeighTicketNumberModel.fromJson(item))
            .toList();
      }
      return data
          .map((item) => WeighTicketNumberModel.fromJson(item))
          .where((item) => item.weighTicketNo
              .toString()
              .toLowerCase()
              .contains(filter.toString().toLowerCase()))
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<http.Response> getheader(
      getDBName, getBranchName, String weightTicketNo) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    try {
      final response = await http.get(
          Uri.parse(
              '${Appconstant.apiBaseUrl}api/yardunloading/details/$getDBName/$getBranchName?field=header&weighNo=$weightTicketNo'),
          headers: headers);
      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<List<NewItemModel>> getnewItem(
      getDBName, getBranchName, getTicketNo,
      {String filter = ""}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${Prefs.getToken('token')}",
    };
    final response = await http.get(
        Uri.parse(
            "${Appconstant.apiBaseUrl}api/yardunloading/details/$getDBName/$getBranchName?field=product&weighNo=$getTicketNo"),
        headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['result'];

      if (filter.isEmpty) {
        return data.map((item) => NewItemModel.fromJson(item)).toList();
      }
      return data
          .map((item) => NewItemModel.fromJson(item))
          .where((item) =>
              item.itemCode
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.documentType
                  .toString()
                  .toLowerCase()
                  .contains(filter.toString().toLowerCase()) ||
              item.invoiceType
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
}
