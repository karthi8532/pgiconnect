import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/dbmodel.dart';
import 'package:pgiconnect/screens/dashboard/goodsreceipt/searchwidget.dart';
import 'package:pgiconnect/screens/dashboard/goodsreceipt/yardloading.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/widgets/customimagewithindicator.dart';

class DbselectionPage extends StatefulWidget {
  const DbselectionPage({super.key});

  @override
  State<DbselectionPage> createState() => _DbselectionPageState();
}

class _DbselectionPageState extends State<DbselectionPage> {
  TextEditingController searchController = TextEditingController();
  bool loading = false;
  List<Dbmodel> dbList = [];
  ApiService apiService = ApiService();

  @override
  void initState() {
    getDblist();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Select Branch'),
        ),
        body: !loading ? getBody() : Center(child: ProgressWithIcon()));
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        Searchbar(
          controller: searchController,
          onSearch: (query) => setState(() {}),
          onClear: () {
            searchController.clear();
            setState(() {});
          },
        ),
        Expanded(
          child: _filterItems(searchController.text).isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _filterItems(searchController.text).length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (context, index) {
                    final product = _filterItems(searchController.text)[index];
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Appcolor.primary,
                            child: Text(product.company![0].toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ),
                        ],
                      ),
                      title: Text(product.company.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 13)),
                      onTap: () {
                        var data = {
                          "companyName": product.company,
                          "DBName": product.db,
                        };

                        Navigator.pop(context, data);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Selected: ${product.company}')),
                        );
                      },
                    );
                  },
                )
              : Center(
                  child: Text('No Data!'),
                ),
        )
      ],
    );
  }

  List<Dbmodel> _filterItems(String query) {
    return query.isEmpty
        ? dbList
        : dbList
            .where((item) =>
                item.company
                    .toString()
                    .toLowerCase()
                    .contains(query.toString().toLowerCase()) ||
                item.db
                    .toString()
                    .toLowerCase()
                    .contains(query.toString().toLowerCase()))
            .toList();
  }

  void getDblist() async {
    setState(() {
      loading = true;
    });

    apiService.getDblist().then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        dbList.clear();
        dbList = jsonDecode(response.body)['result']
            .map<Dbmodel>((item) => Dbmodel.fromJson(item))
            .toList();
        print(dbList);
      } else if (response.statusCode == 401) {
        setState(() {
          loading = false;
        });
        AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'].toString(),
            "Ok",
            onexitpopup,
            null);
      }
    }).catchError((e) {
      setState(() {
        loading = false;
      });
      String errorMessage = "";

      if (e is TimeoutException) {
        errorMessage =
            "Request timed out. Please check your internet connection and try again.";
      } else if (e is SocketException) {
        errorMessage = "Network error. Please check your internet connection.";
      } else {
        errorMessage = e.toString();
      }
      AppUtils.showSingleDialogPopup(
          context, errorMessage, "Ok", onexitpopup, null);
    });
  }

  void onexitpopup() {
    Navigator.of(context).pop();
  }
}
