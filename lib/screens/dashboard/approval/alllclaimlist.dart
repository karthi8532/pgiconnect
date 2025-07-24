import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/allclaimmodel.dart';
import 'package:pgiconnect/screens/brachselection/branchselection.dart';
import 'package:pgiconnect/screens/dashboard/approval/approvalsubmit.dart';
import 'package:pgiconnect/screens/dashboard/goodsreceipt/searchwidget.dart';
import 'package:pgiconnect/screens/dbselectionpage/dbselection.dart';
import 'package:pgiconnect/screens/login/login/loginpage.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/service/appcolor.dart';

class ClaimListPage extends StatefulWidget {
  const ClaimListPage({super.key});

  @override
  State<ClaimListPage> createState() => _ClaimListPageState();
}

class _ClaimListPageState extends State<ClaimListPage> {
  TextEditingController searchController = TextEditingController();
  bool loading = false;
  List<AllClaimModel> claimLodinglist = [];
  List<AllClaimModel> fowardLodinglist = [];
  List<AllClaimModel> approvedLodinglist = [];

  ApiService apiService = ApiService();
  int? selectedIndex = 0;
  String selectedFilter = "Pending";
  String getDBName = "";
  String getcompanyname = "";
  String getbranchName = "";
  int getbranchId = 0;
  TextEditingController fromdatecontroller = TextEditingController();
  TextEditingController todatecontroller = TextEditingController();
  TextEditingController alterfromdatecontroller = TextEditingController();
  TextEditingController altertodatecontroller = TextEditingController();
  String pendingName = "Pending";
  String forwardName = "Forwarded";
  String approvedName = "Approved";

  int inProgressCount = 0;
  int forwardCount = 0;
  int approvedCount = 0;
  @override
  void initState() {
    DateTime now = DateTime.now();

    final DateTime from90daysbefore = now.subtract(Duration(days: 90));
    final DateTime currentdate = now;

    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final DateFormat formatter1 = DateFormat('yyyyMMdd');

    final String fromdate = formatter.format(from90daysbefore);
    final String todate = formatter.format(currentdate);

    fromdatecontroller.text = fromdate;
    todatecontroller.text = todate;

    final String alterfromdate = formatter1.format(from90daysbefore);
    final String altertodate = formatter1.format(currentdate);

    alterfromdatecontroller.text = alterfromdate;
    altertodatecontroller.text = altertodate;

    getpendingList();
    getforwardList();
    getApproveList();
    super.initState();
  }

  @override
  void dispose() {
    fromdatecontroller.dispose();
    todatecontroller.dispose();
    searchController.dispose();
    altertodatecontroller.dispose();
    alterfromdatecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Appcolor.primary,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settlement'),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (builder) => bottomSheet());
                },
                icon: Icon(CupertinoIcons.sort_down))
          ],
        ),
        body:
            !loading ? getBody() : Center(child: CircularProgressIndicator()));
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              _dbandbranchFilterChip(Prefs.getDBName("DBName").toString(), 0),
              SizedBox(width: 8),
              _dbandbranchFilterChip(
                  Prefs.getBranchName("BranchName").toString(), 1),
            ],
          ),
        ),
        Divider(
          color: Colors.grey.shade200,
        ),
        SizedBox(
          height: 10,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                _buildFilterChip(pendingName, inProgressCount),
                SizedBox(width: 8),
                _buildFilterChip(forwardName, forwardCount),
                SizedBox(width: 8),
                _buildFilterChip(approvedName, approvedCount),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: _filterItems(searchController.text, selectedFilter).isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _filterItems(searchController.text, selectedFilter)
                      .length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (context, index) {
                    final product = _filterItems(
                        searchController.text, selectedFilter)[index];

                    return GestureDetector(
                      onTap: () {
                        print(product.docEntry);
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => ApprovalSubmitPage(
                                  docEntry: product.docEntry,
                                  status: selectedFilter)),
                        ).then((_) {
                          getpendingList();
                          getforwardList();
                          getApproveList();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(product.cusName.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(child: Text('Settlement No')),
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 3,
                                        right: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.red),
                                      ),
                                      child: Text(product.docNum.toString(),
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Date',
                                        style: TextStyle(color: Colors.black)),
                                    Text('Invoice No',
                                        style: TextStyle(color: Colors.black)),
                                    Text('Provisional Amt',
                                        style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(product.docDate.toString(),
                                        style: TextStyle(color: Colors.grey)),
                                    Text(product.invNum.toString(),
                                        style: TextStyle(color: Colors.grey)),
                                    Text(product.claimAmt.toStringAsFixed(2),
                                        style: TextStyle(color: Colors.grey))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  _filterItems(String query, selectedFilter) {
    if (selectedFilter == "Pending") {
      return query.isEmpty
          ? claimLodinglist
          : claimLodinglist.where((item) {
              String combinedText =
                  "${item.docEntry} ${item.docNum} ${item.sellType}${item.docDate}${item.cusName}${item.venName},${item.poNum},${item.settelmentaggAmt},${item.etaDate},${item.claimeInformation},${item.cusClaim},${item.billofLoadingNum},${item.approverId},${item.approverName},${item.status},${item.invNum},${item.desigNationofCountry},${item.supplierContry},${item.claimIntimation},${item.ageing},${item.recoveryFromSup},${item.effectonGP},${item.claimAmt}"
                      .toString()
                      .toLowerCase();
              return combinedText.contains(query
                  .toString()
                  .toLowerCase()); // Check if query exists anywhere
            }).toList();
    }
    if (selectedFilter == "Forwarded") {
      return query.isEmpty
          ? fowardLodinglist
          : fowardLodinglist.where((item) {
              String combinedText =
                  "${item.docEntry} ${item.docNum} ${item.sellType}${item.docDate}${item.cusName}${item.venName},${item.poNum},${item.settelmentaggAmt},${item.etaDate},${item.claimeInformation},${item.cusClaim},${item.billofLoadingNum},${item.approverId},${item.approverName},${item.status},${item.invNum},${item.desigNationofCountry},${item.supplierContry},${item.claimIntimation},${item.ageing},${item.recoveryFromSup},${item.effectonGP},${item.claimAmt}"
                      .toString()
                      .toLowerCase();
              return combinedText.contains(query
                  .toString()
                  .toLowerCase()); // Check if query exists anywhere
            }).toList();
    } else {
      return query.isEmpty
          ? approvedLodinglist
          : approvedLodinglist.where((item) {
              String combinedText =
                  "${item.docEntry} ${item.docNum} ${item.sellType}${item.docDate}${item.cusName}${item.venName},${item.poNum},${item.settelmentaggAmt},${item.etaDate},${item.claimeInformation},${item.cusClaim},${item.billofLoadingNum},${item.approverId},${item.approverName},${item.status},${item.invNum},${item.desigNationofCountry},${item.supplierContry},${item.claimIntimation},${item.ageing},${item.recoveryFromSup},${item.effectonGP},${item.claimAmt}"
                      .toString()
                      .toLowerCase();
              return combinedText.contains(query.toString().toLowerCase());
            }).toList();
    }
  }

  Widget bottomSheet() {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Wrap(
          spacing: 600,
          children: [
            AppUtils.bottomHanger(context),
            Container(height: 10),
            AppUtils.buildNormalText(text: "From Date"),
            Container(height: 20),
            Container(
                //padding: EdgeInsets.all(20),
                child: TextFormField(
              controller: fromdatecontroller,
              readOnly: true,
              onTap: () {
                pickerdatefrom();
              },
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "From Date",
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
              ),
            )),
            Container(height: 10),
            AppUtils.buildNormalText(text: "To  Date"),
            Container(height: 10),
            Container(
                //padding: EdgeInsets.all(20),
                child: TextFormField(
              readOnly: true,
              onTap: () {
                pickertodate();
              },
              controller: todatecontroller,
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "To Date",
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
              ),
            )),
            Container(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolor.primary),
                  onPressed: () {
                    if (fromdatecontroller.text.isEmpty) {
                    } else if (todatecontroller.text.isEmpty) {
                    } else {
                      Navigator.pop(context);
                      getpendingList();
                    }
                  },
                  child: Text("Submit", style: TextStyle(color: Colors.white)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void getpendingList() async {
    setState(() {
      loading = true;
    });

    apiService
        .getclaimlist(
            Prefs.getDBName('DBName'),
            Prefs.getBranchID('BranchID'),
            alterfromdatecontroller.text,
            altertodatecontroller.text,
            pendingName)
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        if (jsonDecode(response.body)['success'] == true) {
          setState(() {
            claimLodinglist.clear();
            claimLodinglist = jsonDecode(response.body)['result']
                .map<AllClaimModel>((item) => AllClaimModel.fromJson(item))
                .toList();
            inProgressCount = claimLodinglist.length;
          });
        } else {
          setState(() {
            claimLodinglist.clear();
            inProgressCount = 0;
          });
        }
      } else if (response.statusCode == 401) {
        claimLodinglist.clear();
        handleTokenExpired();
      } else {
        claimLodinglist.clear();
        AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'].toString(),
            "Ok",
            handleTokenExpired,
            null);
      }
    }).catchError((e) {
      claimLodinglist.clear();
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

  void getforwardList() async {
    setState(() {
      loading = true;
    });

    apiService
        .getclaimlist(
            Prefs.getDBName('DBName'),
            Prefs.getBranchID('BranchID'),
            alterfromdatecontroller.text,
            altertodatecontroller.text,
            forwardName)
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        if (jsonDecode(response.body)['success'] == true) {
          fowardLodinglist.clear();
          setState(() {
            fowardLodinglist = jsonDecode(response.body)['result']
                .map<AllClaimModel>((item) => AllClaimModel.fromJson(item))
                .toList();
            forwardCount = fowardLodinglist.length;
          });
        } else {
          setState(() {
            fowardLodinglist.clear();
            forwardCount = 0;
          });
        }
      } else if (response.statusCode == 401) {
        fowardLodinglist.clear();
        handleTokenExpired();
      } else {
        fowardLodinglist.clear();
        AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'].toString(),
            "Ok",
            handleTokenExpired,
            null);
      }
    }).catchError((e) {
      setState(() {
        loading = false;
      });
      fowardLodinglist.clear();
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

  void getApproveList() async {
    setState(() {
      loading = true;
    });
    apiService
        .getclaimlist(
            Prefs.getDBName('DBName'),
            Prefs.getBranchID('BranchID'),
            alterfromdatecontroller.text,
            altertodatecontroller.text,
            approvedName)
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        if (jsonDecode(response.body)['success'] == true) {
          approvedLodinglist.clear();

          setState(() {
            approvedLodinglist = jsonDecode(response.body)['result']
                .map<AllClaimModel>((item) => AllClaimModel.fromJson(item))
                .toList();
            approvedCount = approvedLodinglist.length;
          });
        } else {
          approvedLodinglist.clear();
          approvedCount = 0;
        }
      } else if (response.statusCode == 401) {
        approvedLodinglist.clear();
        handleTokenExpired();
      } else {
        approvedLodinglist.clear();
        AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'].toString(),
            "Ok",
            handleTokenExpired,
            null);
      }
    }).catchError((e) {
      setState(() {
        loading = false;
      });
      approvedLodinglist.clear();
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

  void pickerdatefrom() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      var dateFormate =
          DateFormat("dd/MM/yyyy").format(DateTime.parse(formattedDate));

      setState(() {
        fromdatecontroller.text = dateFormate;
        alterfromdatecontroller.text = formattedDate;
      });
      // if (alterfromdatecontroller.text.isNotEmpty &&
      //     altertodatecontroller.text.isNotEmpty) {
      //   getfilterlist();
      // }
    }
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
        todatecontroller.text = dateFormate;
        altertodatecontroller.text = formattedDate;
      });
      // if (alterfromdatecontroller.text.isNotEmpty &&
      //     altertodatecontroller.text.isNotEmpty) {
      //   getfilterlist();
      // }
    }
  }

  void handleTokenExpired() {
    AppUtils.showSingleDialogPopup(
        context, "Session Expired please login again", "Ok", () {
      Navigator.pop(context);
      Prefs.clear();
      Prefs.remove("remove");
      Prefs.setLoggedIn("IsLoggedIn", false);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (Route<dynamic> route) => false,
      );
    }, null);
  }

  void onexitpopup() {
    Navigator.of(context).pop();
  }

  Widget _dbandbranchFilterChip(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == 0) {
            _dbselection(context);
          } else {
            _branchselection(context, getDBName);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    if (label == "Pending") {
      count = inProgressCount; // Replace with your actual pending count
    } else if (label == "Forwarded") {
      count = forwardCount; // Replace with your actual in-progress count
    } else {
      count = approvedCount; // Replace with your actual approvedName count
    }
    bool isSelected = label == selectedFilter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
          label.toString() == "Pending"
              ? getpendingList()
              : label.toString() == "Forwarded"
                  ? getforwardList()
                  : getApproveList();
          searchController.text = "";
          searchController.clear();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(label,
                style:
                    TextStyle(color: isSelected ? Colors.white : Colors.black)),
            SizedBox(
              width: 3,
            ),
            Text("(${count.toString()})",
                style:
                    TextStyle(color: isSelected ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Future<void> _dbselection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => DbselectionPage()),
    );
    if (result != null && result['companyName'] != null) {
      setState(() {
        getcompanyname = result['companyName'];
        getDBName = result['DBName'];

        Prefs.setDBName("DBName", getDBName);
        Prefs.setCompanyName("CompanyName", getcompanyname);
      });
      getpendingList();
      getforwardList();
      getApproveList();
    }
  }

  Future<void> _branchselection(BuildContext context, getDBName) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => BranchselectionPage(
                getDBName: getDBName,
              )),
    );
    if (result != null && result['gateName'] != null) {
      setState(() {
        getbranchName = result['gateName'];
        getbranchId = result['gateId'];
        Prefs.setBranchID('BranchID', getbranchId);
        Prefs.setBranchName('BranchName', getbranchName);
      });
      getpendingList();
      getforwardList();
      getApproveList();
    }
  }
}
