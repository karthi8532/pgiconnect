import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/pettrycashlistmodel.dart';
import 'package:pgiconnect/screens/dashboard/pettycash/pettycashproductselection.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/widgets/customimagewithindicator.dart';

class PettyCashUpdate extends StatefulWidget {
  int docentry;
  PettyCashAllModel pettyCashItem;
  PettyCashUpdate(
      {super.key, required this.docentry, required this.pettyCashItem});

  @override
  State<PettyCashUpdate> createState() => _PettyCashUpdateState();
}

class _PettyCashUpdateState extends State<PettyCashUpdate> {
  bool loading = false;
  List<PostItemPettryCash> items = [];

  double totalPrice = 0.00;
  ApiService apiService = ApiService();
  @override
  void initState() {
    items.clear();

    for (var item in widget.pettyCashItem.items) {
      items.add(PostItemPettryCash(
        item.itemCode,
        item.itemName,
        item.lineAmount,
        item.lineRemarks,
        widget.pettyCashItem.approvedByCode,
        widget.pettyCashItem.approvedByName,
        widget.pettyCashItem.recivedByCode,
        widget.pettyCashItem.recivedByName,
      ));
    }
    print(items.length);
    _calculateTotals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Appcolor.primary,
        title: AppUtils.buildNormalText(text: "Petty Cash", fontSize: 20),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [],
      ),
      body: !loading
          ? ListView(
              padding: EdgeInsets.all(5),
              children: [
                _buildHeaderDetails(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppUtils.buildNormalText(
                      text: "Product Information", fontSize: 14),
                ),
                _buildProductList(),

                // _buildDBlist(),
                SizedBox(
                  height: 10,
                ),
              ],
            )
          : Center(
              child: ProgressWithIcon(),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Price: ${totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolor.primary),
                  onPressed: () {
                    if (items.isEmpty) {
                      AppUtils.showSingleDialogPopup(context,
                          "Please Add Atleast 1 Item", "Ok", onexitpopup, null);
                    } else {
                      postingitem();
                    }
                  },
                  child: Row(
                    children: [
                      Text("Submit",
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onexitpopup() {
    AppUtils.pop(context);
  }

  void postingitem() async {
    List<Map<String, dynamic>> dataToSend = [];
    setState(() {
      loading = true;
    });

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd.MM.yyyy').format(now);
    dataToSend.clear();
    for (int i = 0; i < items.length; i++) {
      dataToSend.add({
        "docEntry": widget.docentry,
        "docDate": formattedDate,
        "totalAmount": totalPrice,
        "pettyCashReqstFor": widget.pettyCashItem.pettyCashReqstFor,
        "discription": widget.pettyCashItem.discription,
        "lineId": "${i + 1}",
        "itemCode": items[i].itemcode, // dynamic from items
        "itemName": items[i].itemname,
        "lineAmount": items[i].price,
        "lineRemarks": items[i].lineRemarks,
        "approvedByCode": "",
        "approvedByName": items[i].approvedByName,
        "recivedByCode": "",
        "recivedByName": items[i].receivedByName,
        "DocStatus": "Regular",
        "createdById": Prefs.getEmpID('Id'),
        "createdByName": Prefs.getFullName("Name")
      });
    }
    log((jsonEncode(dataToSend)));

    apiService
        .postpettycash(dataToSend, Prefs.getDBName('DBName'),
            Prefs.getBranchID('BranchID'))
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        print(jsonResponse['success'].toString() == "true");
        if (jsonResponse['success'].toString() == "true") {
          AppUtils.showSingleDialogPopup(context,
              jsonResponse['message'].toString(), "Ok", onrefresh, null);
        } else {
          AppUtils.showSingleDialogPopup(
              context,
              jsonDecode(response.body)['message'].toString(),
              "Ok",
              onexitpopup,
              null);
        }
      } else if (response.statusCode == 401) {
      } else {
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
      AppUtils.showSingleDialogPopup(
          context, e.toString(), "Ok", onexitpopup, null);
    });
  }

  void onrefresh() {
    AppUtils.pop(context);
    AppUtils.pop(context);
  }

  Widget _buildHeaderDetails() {
    return Column(
      children: [
        _buildTextField("Request For", widget.pettyCashItem.pettyCashReqstFor,
            Icons.abc_outlined),
        SizedBox(
          height: 2,
        ),
        _buildTextField("Desc", widget.pettyCashItem.discription, Icons.person),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: _buildTextField(
                  "Date",
                  widget.pettyCashItem.docDate.toString().substring(0, 10),
                  Icons.dock_outlined),
            ),
            Expanded(
              flex: 5,
              child: _buildTextField("", "", Icons.dock_outlined),
            ),
          ],
        ),
        SizedBox(
          height: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: _buildTextField("Approver",
                  widget.pettyCashItem.approvedByName.toString(), Icons.person),
            ),
            Expanded(
              flex: 5,
              child: _buildTextField("Receiver",
                  widget.pettyCashItem.recivedByName.toString(), Icons.person),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon) {
    return Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(4),
        color: Colors.white,
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey,
              size: 15,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppUtils.buildNormalText(
                  text: label,
                  fontSize: 10,
                ),
                AppUtils.buildNormalText(
                    text: hint,
                    fontSize: 12,
                    maxLines: 1,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis),
              ],
            )
          ],
        ));
  }

  Widget _buildProductList() {
    return GestureDetector(
      onTap: () {
        _selectproduct(context);
      },
      child: Card(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              items.isEmpty
                  ? Row(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.add_circle,
                              color: Appcolor.primary,
                            )),
                        Container(
                            margin: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              "Add Products",
                              style: TextStyle(fontSize: 14.0),
                            ))
                      ],
                    )
                  : _buildProductItem(items),
              TextButton(
                onPressed: () {
                  _selectproduct(context);
                },
                child: items.isNotEmpty
                    ? Text("+ Add More Items",
                        style: TextStyle(color: Colors.blue))
                    : SizedBox(
                        width: 0,
                        height: 0,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(items) {
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.archivebox,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(items[index].itemname,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.cube_box,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        items[index].price.toString().isEmpty
                            ? "Price  : 0"
                            : "Price  : ${items[index].price.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.cube_box,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        items[index].approvedByName.toString().isEmpty
                            ? "ApprovedByName : "
                            : "ApprovedByName: ${items[index].approvedByName.toString()}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.cube_box,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        items[index].receivedByName.toString().isEmpty
                            ? "Receiver Name : "
                            : "Receiver Name: ${items[index].receivedByName.toString()}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          color: Colors.grey.shade200,
        );
      },
    );
  }

  Future<void> _selectproduct(BuildContext context) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => PettyCashSelectionScreen(
                items: items,
              )),
    );
    if (result != null) {
      setState(() {
        items = result; // Update with new list
        _calculateTotals();
      });
    }
  }

  void _calculateTotals() {
    totalPrice = items.fold(0, (sum, item) => sum + item.price!.toDouble());

    setState(() {});
  }
}
