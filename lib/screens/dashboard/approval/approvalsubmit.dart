import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/singleclaimmodel.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/util/urllauncherservice.dart';

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
  TextEditingController claimReason = TextEditingController();

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
  List<Forwardmodel> forwardlist = [];
  Map<String, String> statusOption = {
    "F": "Forward",
    "A": "Approved",
    "R": "Rejected",
    "P": "Pending"
  };
  List<PostApproval> postitem = [];
  MapEntry<String, String>? selectedStatus;

  int selectedPosition = 0;
  String toapprover = "";
  String toposition = "";
  String fromappposition = "";
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
    claimReason.dispose();
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
            singleclaimlist.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      postingitem();
                    },
                    icon: Icon(Icons.save))
                : Container()
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
                        singleclaimlist.isNotEmpty
                            ? headerwidgets()
                            : Container(),
                        singleclaimlist.isNotEmpty
                            ? commentWidets()
                            : Container(),
                        singleclaimlist.isNotEmpty
                            ? itemsswidgets()
                            : Container(),
                        singleclaimlist.isNotEmpty
                            ? attachmentwidget()
                            : Container()
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
    print(Prefs.getDBName('DBName'));
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

            singleclaimlist = (jsonDecode(response.body)['result'] as List)
                .map((e) => SingleClaimModel.fromJson(e))
                .toList();

            invNumercontroller.text = singleclaimlist.first.invNum.toString();
            cusNamecontroller.text = singleclaimlist.first.cusName.toString();
            poNumcontroller.text = singleclaimlist.first.poNum.toString();
            supplierNamecontroller.text =
                singleclaimlist.first.venName.toString();

            claimReason.text = singleclaimlist.first.cusClaim.toString();

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

          if (singleclaimlist.first.commands!.isNotEmpty) {
            for (var command in singleclaimlist.first.commands!) {
              if (command.canEndit == "N") {
                forwardlist.add(Forwardmodel(
                    command.approverCode.toString(),
                    command.approverName.toString(),
                    command.department.toString(),
                    command.appPosition.toString(),
                    command.userId.toString()));
              } else {
                fromappposition = command.appPosition.toString();
              }
            }
          }
        } else {
          AppUtils.showSingleDialogPopup(context,
              jsonDecode(response.body)['message'], "OK", onexitpopup, null);
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
    String formattedNow =
        DateFormat("MMM dd yyyy hh:mma").format(DateTime.now());
    if (singleclaimlist.isEmpty) {
      AppUtils.showSingleDialogPopup(
          context, "No data available to submit", "Ok", onexitpopup, null);
      return;
    }

    for (var command in singleclaimlist.first.commands!) {
      command.approverStatus = command.tempStatus;
    }
    for (int i = 0; i < singleclaimlist.first.commands!.length; i++) {
      if (singleclaimlist.first.commands![i].canEndit == "Y") {
        postitem.add(PostApproval(
            singleclaimlist.first.docEntry,
            fromappposition,
            singleclaimlist.first.commands![i].approverCode.toString(),
            singleclaimlist.first.commands![i].approverName.toString(),
            singleclaimlist.first.commands![i].approverStatus.toString(),
            singleclaimlist.first.commands![i].department.toString(),
            singleclaimlist.first.commands![i].userId.toString(),
            formattedNow,
            singleclaimlist.first.commands![i].remarks.toString(),
            singleclaimlist.first.commands![i].appType.toString(),
            (i == i && isForwared == true) ? Prefs.getEmpID("Id") : "",
            i == i && isForwared == true
                ? singleclaimlist.first.commands![i].approverCode
                : "",
            fromappposition,
            singleclaimlist.first.commands![i].tempStatus == "F"
                ? toapprover
                : "",
            singleclaimlist.first.commands![i].tempStatus == "F"
                ? toposition
                : ""));
      }
    }

    // if (isForwared == true) {
    //   postitem.add(PostApproval.fromJson(newItemMap));
    // }
    setState(() {
      loading = true;
    });
    log(jsonEncode(postitem));
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
            // const SizedBox(height: 5),
            // _buildTextField(
            //   "Sell Type",
            //   sellTypecontroller.text.toString(),
            //   Icons.sell,
            // ),
            const SizedBox(height: 5),

            _buildTextField(
              "Claim Reason",
              claimReason.text.toString(),
              Icons.person_2,
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
            // const SizedBox(height: 5),
            // _buildTextField(
            //   "ETA Date",
            //   etadatecontroller.text.toString(),
            //   Icons.date_range,
            // ),
            // const SizedBox(height: 5),
            // _buildTextField(
            //   "Claim Intimation",
            //   claimIntimationcontroller.text.toString(),
            //   Icons.info,
            // ),
            // const SizedBox(height: 5),
            // _buildTextField(
            //   "Aging",
            //   agingcontroller.text.toString(),
            //   Icons.date_range_outlined,
            // ),

            // const SizedBox(height: 5),
            // _buildTextField(
            //   "Effect on GP %",
            //   effectGPcontroller.text.toString(),
            //   Icons.percent,
            // ),
            const SizedBox(height: 5),
            _buildTextField(
              "Claim Amount",
              claimAmount.text.toString(),
              Icons.request_page,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Recovery From Supplier",
              recoveryfromsuppController.text.toString(),
              Icons.cases,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              "Final Settlement",
              settlementAgreementController.text.toString(),
              Icons.cases,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 15,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                  softWrap: true,
                ),
                SizedBox(height: 2),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    final currentUserId = Prefs.getEmpID('Id').toString();
    print(currentUserId);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: singleclaimlist.isNotEmpty
            ? ListView.builder(
                itemCount: singleclaimlist.first.commands!.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final command = singleclaimlist.first.commands![index];

                  selectedStatus = statusOption.entries.firstWhere(
                    (entry) => entry.key == command.tempStatus,
                    orElse: () => MapEntry("P", "Pending"),
                  );

                  String canEndit = command.canEndit.toString();

                  final approverItems = singleclaimlist.first.commands!
                      .where((c) => c.userId.toString() != currentUserId)
                      .map((cmd) => MapEntry(
                            "${cmd.approverName} -  ${cmd.approverCode}- ${cmd.department} -${cmd.userId},${cmd.appPosition}",
                            cmd,
                          ))
                      .toList();
                  // toapprover =
                  //     approverItems[index].value.approverCode.toString();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    color: canEndit == "Y" ? Colors.white : Colors.grey[300],
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Row 1: Department & Status
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: AppUtils.buildNormalText(
                                    text: command.departmentnew ?? ''),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 3,
                                child: AppUtils.buildNormalText(text: "Status"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          /// Row 2: ApproverName (readonly text field) & Status Dropdown
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: TextFormField(
                                  initialValue: command.approverName ?? '',
                                  readOnly: true,
                                  enabled: canEndit == "Y",
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
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
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 5,
                                child: DropdownSearch<MapEntry<String, String>>(
                                  enabled: canEndit == "Y",
                                  selectedItem: selectedStatus,
                                  items: statusOption.entries.toList(),
                                  itemAsString: (entry) => entry.value,
                                  onChanged: (entry) {
                                    if (entry != null) {
                                      setState(() {
                                        command.tempStatus = entry.key;
                                        isForwared = entry.key == 'F';
                                        selectedPosition = index;
                                      });
                                    }
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
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          /// Row 3: Forward To & Date
                          Visibility(
                            visible:
                                canEndit == "Y" && command.tempStatus == "F",
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: AppUtils.buildNormalText(
                                      text: "Forward To"),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 3,
                                  child: AppUtils.buildNormalText(text: "Date"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),

                          /// Row 4: Forward Dropdown & Date Field
                          Visibility(
                            visible: canEndit == "Y",
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Visibility(
                                    visible: canEndit == "Y" &&
                                        command.tempStatus == "F",
                                    child: DropdownSearch<Forwardmodel>(
                                      items: forwardlist,
                                      itemAsString: (item) =>
                                          "${item.name} - ${item.code} - ${item.dept} - ${item.postion}",
                                      selectedItem: forwardlist.isNotEmpty &&
                                              selectedPosition <
                                                  forwardlist.length
                                          ? forwardlist[selectedPosition]
                                          : null,
                                      onChanged: (item) {
                                        if (item != null) {
                                          setState(() {
                                            toapprover = item.toapproverid;
                                            toposition = item.postion;

                                            command.toApproverCode =
                                                item.toapproverid;
                                            command.fromApproverCode =
                                                currentUserId;
                                            command.appPosition = item.postion;
                                            command.department = item.dept;
                                            print(
                                                "Selected Approver: ${item.code}, Position: ${item.postion}");
                                          });
                                        }
                                      },
                                      popupProps: PopupProps.menu(
                                        showSearchBox: true,
                                        itemBuilder:
                                            (context, item, isSelected) {
                                          return ListTile(
                                            title: Text(
                                              "${item.name} - ${item.code} - ${item.dept} - ${item.postion}",
                                            ),
                                          );
                                        },
                                      ),
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Visibility(
                                  visible: canEndit == "Y" &&
                                      command.tempStatus == "F",
                                  child: Expanded(
                                    flex: 5,
                                    child: TextFormField(
                                      initialValue: command.appDate ?? '',
                                      enabled: false,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
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
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),

                          /// Comments Field
                          AppUtils.buildNormalText(text: "Comments"),
                          const SizedBox(height: 5),
                          TextFormField(
                            initialValue: command.remarks ?? '',
                            maxLines: null,
                            minLines: 2,
                            enabled: command.approverStatus == "P",
                            onChanged: (val) {
                              command.remarks = val;
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
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
                },
              )
            : Center(child: Text('No Data Found')),
      ),
    );
  }

  Widget itemsswidgets() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          singleclaimlist.isNotEmpty
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
        singleclaimlist.isNotEmpty ||
                singleclaimlist.first.attachmentPath != null ||
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
  String? position;
  String? toExtEmpNo;
  String? toPosition;
//  "toPosition": selectedPosition,
//       "toExtEmpNo":
//           singleclaimlist.first.commands![selectedPosition].approverCode,
//       "position": singleclaimlist.first.commands![selectedPosition].appPosition,
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
      this.forwardTo,
      this.position,
      this.toExtEmpNo,
      this.toPosition);

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
    position = json['position'];
    toExtEmpNo = json['toExtEmpNo'];
    toPosition = json['toPosition'];
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
    data['position'] = position;
    data['toExtEmpNo'] = toExtEmpNo;
    data['toPosition'] = toPosition;

    return data;
  }
}

class Forwardmodel {
  String toapproverid;
  String code;
  String name;
  String dept;
  String postion;

  Forwardmodel(
      this.code, this.name, this.dept, this.postion, this.toapproverid);
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
