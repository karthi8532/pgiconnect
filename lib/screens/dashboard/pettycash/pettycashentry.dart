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

class PettyCashEntry extends StatefulWidget {
  const PettyCashEntry({super.key});

  @override
  State<PettyCashEntry> createState() => _PettyCashEntryState();
}

class _PettyCashEntryState extends State<PettyCashEntry> {
  bool loading = false;
  List<PostItemPettryCash> items = [];

  double totalPrice = 0.00;
  ApiService apiService = ApiService();
  TextEditingController requestForController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController alterTodateController = TextEditingController();
  @override
  void initState() {
    items.clear();

    super.initState();
  }

  @override
  void dispose() {
    requestForController.dispose();
    descController.dispose();
    dateController.dispose();
    alterTodateController.dispose();
    super.dispose();
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
                      text: "Item Information", fontSize: 14),
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
                    if (requestForController.text.isEmpty) {
                      AppUtils.showSingleDialogPopup(context,
                          "Request For is Missing", "Ok", onexitpopup, null);
                    } else if (descController.text.isEmpty) {
                      AppUtils.showSingleDialogPopup(context,
                          "Description is Missing", "Ok", onexitpopup, null);
                    } else if (dateController.text.isEmpty) {
                      AppUtils.showSingleDialogPopup(
                          context, "Date is Missing", "Ok", onexitpopup, null);
                    } else if (items.isEmpty) {
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
        "docDate": alterTodateController.text,
        "totalAmount": totalPrice,
        "pettyCashReqstFor": requestForController.text,
        "discription": descController.text,
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

  // Widget _buildHeaderDetails() {
  //   return Column(
  //     children: [
  //       _buildTextField("Request For", "", Icons.person),
  //       SizedBox(
  //         height: 2,
  //       ),
  //       _buildTextField("Desc", "", Icons.dock),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             flex: 5,
  //             child: _buildTextField("Date", "", Icons.dock_outlined),
  //           ),
  //           Expanded(
  //             flex: 5,
  //             child: _buildTextField("", "", Icons.dock_outlined),
  //           ),
  //         ],
  //       ),
  //       SizedBox(
  //         height: 2,
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             flex: 5,
  //             child: _buildTextField("Approver", _textFornField("Approver", "hint", icon, controller), Icons.person),
  //           ),
  //           Expanded(
  //             flex: 5,
  //             child: _buildTextField("Receiver", "", Icons.person),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
  Widget _buildHeaderDetails() {
    return SingleChildScrollView(
      child: Card(
        elevation: 1,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppUtils.buildNormalText(text: "Request For"),
                const SizedBox(height: 5),
                TextField(
                  keyboardType: TextInputType.multiline,
                  controller: requestForController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    hintText: "",
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                AppUtils.buildNormalText(text: "Description"),
                const SizedBox(height: 5),
                TextField(
                  keyboardType: TextInputType.multiline,
                  controller: descController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    hintText: "",
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                AppUtils.buildNormalText(text: "Date"),
                const SizedBox(height: 5),
                TextFormField(
                  keyboardType: TextInputType.none,
                  controller: dateController,
                  readOnly: true,
                  maxLines: 1,
                  onTap: () {
                    pickertodate();
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    hintText: "",
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            )),
      ),
    );
  }

  void pickertodate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), //.add(Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      var dateFormate =
          DateFormat("dd/MM/yyyy").format(DateTime.parse(formattedDate));

      setState(() {
        dateController.text = dateFormate;
        alterTodateController.text = formattedDate;
      });
      // if (alterfromdatecontroller.text.isNotEmpty &&
      //     altertodatecontroller.text.isNotEmpty) {
      //   getfilterlist();
      // }
    }
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
                              "Add Items",
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
