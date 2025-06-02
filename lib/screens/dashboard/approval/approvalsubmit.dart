import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/singleclaimmodel.dart';
import 'package:pgiconnect/screens/dashboard/goodsreceipt/productlist.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/util/urllauncherservice.dart';
import 'package:pgiconnect/widgets/tab_item.dart';

class ApprovalSubmitPage extends StatefulWidget {
  int docEntry = 0;
  String status;
  ApprovalSubmitPage({super.key, required this.docEntry, required this.status});

  @override
  State<ApprovalSubmitPage> createState() => _ApprovalSubmitPageState();
}

class _ApprovalSubmitPageState extends State<ApprovalSubmitPage> {
  TextEditingController invNumercontroller = TextEditingController();
  TextEditingController cusNamecontroller = TextEditingController();
  TextEditingController poNumcontroller = TextEditingController();
  TextEditingController supplierNamecontroller = TextEditingController();
  TextEditingController sellTypecontroller = TextEditingController();
  TextEditingController destCountrycontroller = TextEditingController();
  TextEditingController suppliercountrycontroller = TextEditingController();
  TextEditingController etadatecontroller = TextEditingController();
  TextEditingController claimIntimationcontroller = TextEditingController();
  TextEditingController agingcontroller = TextEditingController();
  TextEditingController settlementAgreementController = TextEditingController();
  TextEditingController recoveryfromsuppController = TextEditingController();
  TextEditingController effectGPcontroller = TextEditingController();
  TextEditingController claimAmount = TextEditingController();
  TextEditingController customerClaim = TextEditingController();
  List<SingleClaimModel> singleclaimlist = [];
  bool loading = false;
  ApiService apiService = ApiService();
  bool isForwared = false;
  Map<String, String> statusOption = {
    "F": "Forward",
    "A": "Approved",
    "R": "Rejected",
    "P": "Pending"
  };
  List<PostApproval> postitem = [];
  MapEntry<String, String>? selectedStatus;
  List<Forwardmodel> forwardlist = [];
  int selectedPosition = 0;
  @override
  void initState() {
    getpendingList();
    super.initState();
  }

  @override
  void dispose() {
    invNumercontroller.dispose();
    cusNamecontroller.dispose();
    poNumcontroller.dispose();
    supplierNamecontroller.dispose();
    sellTypecontroller.dispose();
    destCountrycontroller.dispose();
    suppliercountrycontroller.dispose();
    etadatecontroller.dispose();
    claimIntimationcontroller.dispose();
    agingcontroller.dispose();
    settlementAgreementController.dispose();
    recoveryfromsuppController.dispose();
    effectGPcontroller.dispose();
    claimAmount.dispose();
    customerClaim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Appcolor.primary,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settlement'),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  postingitem();
                },
                icon: Icon(Icons.save))
          ],
        ),
        body: !loading
            ? Column(
                children: [
                  TabBar(
                    labelStyle: TextStyle(fontWeight: FontWeight.w700),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.black,
                    unselectedLabelColor: Color(0xff5f6368),
                    isScrollable: true,
                    indicator: MD2Indicator(
                      indicatorSize: MD2IndicatorSize.full,
                      indicatorHeight: 8.0,
                      indicatorColor: Colors.green,
                    ),
                    tabs: [
                      Tab(
                        text: "Header",
                      ),
                      Tab(
                        text: "Comments",
                      ),
                      Tab(
                        text: "Items",
                      ),
                      Tab(
                        text: "Attachments",
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: ScrollPhysics(),
                      children: [
                        headerwidgets(),
                        commentWidets(),
                        itemsswidgets(),
                        attachmentwidget()
                      ],
                    ),
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  void getpendingList() async {
    setState(() {
      loading = true;
    });

    apiService
        .getsingleclaimlist(Prefs.getDBName('DBName'),
            Prefs.getBranchID('BranchID'), widget.docEntry, widget.status)
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        if (jsonDecode(response.body)['success'] == true) {
          setState(() {
            singleclaimlist.clear();
            // singleclaimlist = jsonDecode(response.body)['result']
            //     .map<SingleClaimModel>(
            //         (item) => SingleClaimModel.fromJson(item))
            //     .toList();

            singleclaimlist = (jsonDecode(response.body)['result'] as List)
                .map((e) => SingleClaimModel.fromJson(e))
                .toList();

            invNumercontroller.text = singleclaimlist.first.invNum.toString();
            cusNamecontroller.text = singleclaimlist.first.cusName.toString();
            poNumcontroller.text = singleclaimlist.first.poNum.toString();

            sellTypecontroller.text = singleclaimlist.first.sellType.toString();
            destCountrycontroller.text =
                singleclaimlist.first.desigNationofCountry.toString();
            suppliercountrycontroller.text =
                singleclaimlist.first.supplierContry.toString();
            etadatecontroller.text = singleclaimlist.first.etaDate.toString();
            claimIntimationcontroller.text =
                singleclaimlist.first.claimIntimation.toString();
            agingcontroller.text = singleclaimlist.first.ageing.toString();
            settlementAgreementController.text =
                singleclaimlist.first.settelmentaggAmt.toString();
            recoveryfromsuppController.text =
                singleclaimlist.first.recoveryFromSup.toString();

            effectGPcontroller.text =
                singleclaimlist.first.effectonGP.toString();
            claimAmount.text = singleclaimlist.first.claimAmt.toString();
            customerClaim.text = singleclaimlist.first.cusClaim.toString();
          });
        } else {
          setState(() {
            singleclaimlist.clear();
          });
        }
      } else if (response.statusCode == 401) {
        singleclaimlist.clear();
      } else {
        AppUtils.showSingleDialogPopup(context,
            jsonDecode(response.body)['message'].toString(), "Ok", "", null);
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
    AppUtils.pop(context);
  }

  void postingitem() async {
    postitem.clear();

    for (int i = 0; i < singleclaimlist.first.commands!.length; i++) {
      postitem.add(PostApproval(
          singleclaimlist.first.docEntry,
          singleclaimlist.first.commands![i].appPosition.toString(),
          singleclaimlist.first.commands![i].approverCode.toString(),
          singleclaimlist.first.commands![i].approverName.toString(),
          singleclaimlist.first.commands![i].approverStatus.toString(),
          singleclaimlist.first.commands![i].department.toString(),
          singleclaimlist.first.commands![i].userId.toString(),
          singleclaimlist.first.commands![i].appDate.toString(),
          singleclaimlist.first.commands![i].remarks.toString(),
          singleclaimlist.first.commands![i].appType.toString(),
          (i == selectedPosition && isForwared == true)
              ? Prefs.getEmpID("Id")
              : "",
          i == selectedPosition && isForwared == true
              ? singleclaimlist.first.commands![selectedPosition].approverCode
              : ""));
    }

    Map<String, dynamic> newItemMap = {
      "docEntry": singleclaimlist.first.commands![selectedPosition].docEntry,
      "appPosition":
          singleclaimlist.first.commands![selectedPosition].appPosition,
      "approverCode":
          singleclaimlist.first.commands![selectedPosition].approverCode,
      "approverName":
          singleclaimlist.first.commands![selectedPosition].approverName,
      "approverStatus":
          singleclaimlist.first.commands![selectedPosition].approverStatus,
      "department":
          singleclaimlist.first.commands![selectedPosition].department,
      "userId": singleclaimlist.first.commands![selectedPosition].userId,
      "appDate": singleclaimlist.first.commands![selectedPosition].appDate,
      "remarks": singleclaimlist.first.commands![selectedPosition].remarks,
      "appType": "Forwarded",
      "forwardFrom": Prefs.getEmpID("Id"),
      "forwardTo":
          singleclaimlist.first.commands![selectedPosition].approverCode,
    };
    if (isForwared == true) {
      postitem.add(PostApproval.fromJson(newItemMap));
      print(jsonEncode(postitem));
    }
    setState(() {
      loading = true;
    });

    apiService
        .postclaim(
            postitem, Prefs.getDBName('DBName'), Prefs.getBranchID('BranchID'))
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

  Widget headerwidgets() {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(4),
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              "Invoice Number",
              invNumercontroller.text.toString(),
              Icons.numbers,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Customer Name",
              cusNamecontroller.text.toString(),
              Icons.person,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Purchase Order Number",
              poNumcontroller.text.toString(),
              Icons.numbers,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Supplier",
              supplierNamecontroller.text.toString(),
              Icons.person_2,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Sell Type",
              sellTypecontroller.text.toString(),
              Icons.sell,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Destination Country",
              destCountrycontroller.text.toString(),
              Icons.map,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Supllier Country",
              suppliercountrycontroller.text.toString(),
              Icons.map,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "ETA Date",
              etadatecontroller.text.toString(),
              Icons.date_range,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Claim Intimation",
              claimIntimationcontroller.text.toString(),
              Icons.info,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Aging",
              agingcontroller.text.toString(),
              Icons.date_range_outlined,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Settlement Agreed With Customer",
              settlementAgreementController.text.toString(),
              Icons.cases,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Recovery From Supplier",
              recoveryfromsuppController.text.toString(),
              Icons.cases,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Effect on GP %",
              effectGPcontroller.text.toString(),
              Icons.percent,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Claim Amount",
              claimAmount.text.toString(),
              Icons.request_page,
            ),
          ],
        ),
      ),
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

  Widget _textFornField(String label, String hint, IconData icon,
      TextEditingController controller) {
    return TextFormField(
        controller: controller,
        readOnly: true,
        autofocus: false,
        decoration: InputDecoration(
            labelText: "",
            hintText: "",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            isDense: true));
  }

  Widget commentWidets() {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.builder(
              itemCount: singleclaimlist.first.commands!.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final command = singleclaimlist.first.commands![index];
                selectedStatus = statusOption.entries.firstWhere(
                    (entry) => entry.key == command.approverStatus,
                    orElse: () => MapEntry("", ""));
                List<Commands> filteredCommands = singleclaimlist
                    .first.commands!
                    .where((c) =>
                        c.approverCode.toString() !=
                        Prefs.getEmpID('Id').toString())
                    .toList();
                List<
                    MapEntry<String,
                        Commands>> approverItems = filteredCommands
                    .map((cmd) => MapEntry(
                        "${cmd.approverName} - ${cmd.department} - ${cmd.approverCode})",
                        cmd))
                    .toList();
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                flex: 4,
                                child: AppUtils.buildNormalText(
                                    text: command.department)),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                flex: 3,
                                child:
                                    AppUtils.buildNormalText(text: "Status")),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextField(
                                enabled: Prefs.getEmpID('Id').toString() ==
                                        command.approverCode.toString()
                                    ? true
                                    : false,
                                keyboardType: TextInputType.multiline,
                                maxLines: 1,
                                controller: TextEditingController(
                                    text: command.approverName ?? ''),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  hintText: "",
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.grey)),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black26, width: 1),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black26, width: 1),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                flex: 5,
                                child: DropdownSearch<MapEntry<String, String>>(
                                  enabled: Prefs.getEmpID('Id').toString() ==
                                      command.approverCode.toString(),
                                  selectedItem: statusOption.entries.firstWhere(
                                    (e) => e.key == command.approverStatus,
                                    orElse: () => MapEntry("P", "Pending"),
                                  ),
                                  items: statusOption.entries.toList(),
                                  itemAsString: (entry) => entry.value,
                                  onChanged: (entry) {
                                    setState(() {
                                      if (entry != null) {
                                        setState(() {
                                          // Update the command object with the selected status code
                                          command.approverStatus = entry.key;

                                          // if (entry.key == "F") {
                                          //   command.appType = "Forwarded";
                                          // } else {
                                          //   command.appType = "Regular";
                                          // }
                                          print(entry.key);
                                          print(entry.value);
                                          entry.key == "F"
                                              ? isForwared = true
                                              : false;
                                        });
                                      }
                                    });
                                  },
                                  popupProps:
                                      PopupProps.menu(showSearchBox: true),
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                                flex: 4,
                                child: AppUtils.buildNormalText(
                                    text: "Forward To")),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                flex: 3,
                                child: AppUtils.buildNormalText(text: "Date")),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                                flex: 5,
                                child:
                                    DropdownSearch<MapEntry<String, Commands>>(
                                  enabled: Prefs.getEmpID('Id').toString() ==
                                              command.approverCode.toString() &&
                                          isForwared == true
                                      ? true
                                      : false,
                                  items: approverItems,
                                  itemAsString: (entry) =>
                                      entry.key, // show "Name - Dept (Code)"
                                  selectedItem:
                                      null, // or assign based on some condition
                                  onChanged: (entry) {
                                    setState(() {
                                      Commands selectedCmd = entry!.value;
                                      print(
                                          "Selected ApproverCode: ${selectedCmd.approverCode}");
                                      for (int s = 0;
                                          s <
                                              singleclaimlist
                                                  .first.commands!.length;
                                          s++) {
                                        if (singleclaimlist
                                                .first.commands![s].approverCode
                                                .toString() ==
                                            selectedCmd.approverCode
                                                .toString()) {
                                          print(s);

                                          selectedPosition = s;
                                        }
                                      }
                                    });
                                  },
                                  dropdownBuilder: (context, entry) {
                                    if (entry == null) return Text("");
                                    return Text(
                                      "${entry.value.approverName} - ${entry.value.department}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 14),
                                    );
                                  },
                                  popupProps:
                                      PopupProps.menu(showSearchBox: true),
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      labelText: "",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 5,
                              child: TextField(
                                enabled: Prefs.getEmpID('Id').toString() ==
                                        command.approverCode.toString()
                                    ? true
                                    : false,
                                keyboardType: TextInputType.multiline,
                                controller: TextEditingController(
                                    text: command.appDate ?? ''),
                                maxLines: 1,
                                readOnly: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  hintText: "",
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.grey)),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black26, width: 1),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black26, width: 1),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        AppUtils.buildNormalText(text: "Comments"),
                        const SizedBox(height: 5),
                        TextField(
                          enabled: Prefs.getEmpID('Id').toString() ==
                                  command.approverCode.toString()
                              ? true
                              : false,
                          keyboardType: TextInputType.multiline,
                          controller: TextEditingController(
                              text: command.remarks ?? ''),
                          maxLines: 1,
                          onChanged: (val) {
                            command.remarks = val;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            hintText: "",
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 1),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })),
    );
  }

  Widget itemsswidgets() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          singleclaimlist.first.items!.isNotEmpty
              ? ListView.builder(
                  itemCount: singleclaimlist.first.items!.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = singleclaimlist.first.items![index];
                    return _buildDataRow(item);
                  },
                )
              : Center(
                  child: Text('No Data Found'),
                ),
        ],
      ),
    );
  }

  Widget attachmentwidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        singleclaimlist.first.attachmentPath!.isNotEmpty
            ? ListView.builder(
                itemCount: singleclaimlist.first.attachmentPath!.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final attachements =
                      singleclaimlist.first.attachmentPath![index];
                  return Card(
                    child: ListTile(
                      onTap: () async {
                        try {
                          await UrlLauncherService().launchUrlExternal(
                              attachements.url.toString(),
                              isNewTab: true);
                        } catch (e) {
                          print("Failed to launch URL: $e");
                        }
                      },
                      title: Text(
                        attachements.filename.toString(),
                      ),
                      leading: Icon(Icons.image_aspect_ratio),
                      trailing: Icon(Icons.navigate_next_outlined),
                    ),
                  );
                },
              )
            : Center(
                child: Text('No Data Found'),
              ),
      ],
    );
  }

  Widget _buildDataRow(Items item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(item.containerNo.toString(),
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold))),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(item.toatalAmt!.toStringAsFixed(2),
                    style: TextStyle(fontSize: 12, color: Colors.black)),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Inv Qty : ${item.invoiceQty!.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 13)),
              Text(
                  "Prov Claim Amt : ${item.provicionalClaimAmt!.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 13)),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Quantity Amt : ${item.quantityAmt!.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 13)),
              Text("Quality Amt : ${item.qualityAmt!.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 13)),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Short Qty : ${item.shortageQty!.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 13)),
            ],
          ),
        ]),
      ),
    );
  }
}

class PostApproval {
  int? docEntry;
  String? appPosition;
  String? approverCode;
  String? approverName;
  String? approverStatus;
  String? department;
  String? userId;
  String? appDate;
  String? remarks;
  String? appType;
  String? forwardFrom;
  String? forwardTo;

  PostApproval(
      this.docEntry,
      this.appPosition,
      this.approverCode,
      this.approverName,
      this.approverStatus,
      this.department,
      this.userId,
      this.appDate,
      this.remarks,
      this.appType,
      this.forwardFrom,
      this.forwardTo);

  PostApproval.fromJson(Map<String, dynamic> json) {
    docEntry = json['docEntry'];
    appPosition = json['appPosition'];
    approverCode = json['approverCode'];
    approverName = json['approverName'];
    approverStatus = json['approverStatus'];
    department = json['department'];
    userId = json['userId'];
    appDate = json['appDate'];
    remarks = json['remarks'];
    appType = json['appType'];
    forwardFrom = json['forwardFrom'];
    forwardTo = json['forwardTo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['docEntry'] = docEntry;
    data['appPosition'] = appPosition;
    data['approverCode'] = approverCode;
    data['approverName'] = approverName;
    data['approverStatus'] = approverStatus;
    data['department'] = department;
    data['userId'] = userId;
    data['appDate'] = appDate;
    data['remarks'] = remarks;
    data['appType'] = appType;
    data['forwardFrom'] = forwardFrom;
    data['forwardTo'] = forwardTo;
    return data;
  }
}

class Forwardmodel {
  String code;
  String name;
  String dept;

  Forwardmodel(this.code, this.name, this.dept);
}

enum MD2IndicatorSize {
  tiny,
  normal,
  full,
}

class MD2Indicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;
  final MD2IndicatorSize indicatorSize;

  const MD2Indicator(
      {required this.indicatorHeight,
      required this.indicatorColor,
      required this.indicatorSize});

  @override
  _MD2Painter createBoxPainter([VoidCallback? onChanged]) {
    return _MD2Painter(this, onChanged!);
  }
}

class _MD2Painter extends BoxPainter {
  final MD2Indicator decoration;

  _MD2Painter(this.decoration, VoidCallback onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    Rect? rect;
    if (decoration.indicatorSize == MD2IndicatorSize.full) {
      rect = Offset(offset.dx,
              (configuration.size!.height - decoration.indicatorHeight ?? 3)) &
          Size(configuration.size!.width, decoration.indicatorHeight ?? 3);
    } else if (decoration.indicatorSize == MD2IndicatorSize.normal) {
      rect = Offset(offset.dx + 6,
              (configuration.size!.height - decoration.indicatorHeight ?? 3)) &
          Size(configuration.size!.width - 12, decoration.indicatorHeight ?? 3);
    } else if (decoration.indicatorSize == MD2IndicatorSize.tiny) {
      rect = Offset(offset.dx + configuration.size!.width / 2 - 8,
              (configuration.size!.height - decoration.indicatorHeight ?? 3)) &
          Size(16, decoration.indicatorHeight ?? 3);
    }

    final Paint paint = Paint();
    paint.color = decoration.indicatorColor ?? Color(0xff1967d2);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect!,
            topRight: Radius.circular(8), topLeft: Radius.circular(8)),
        paint);
  }
}
