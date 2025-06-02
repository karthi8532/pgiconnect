import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/edityarnselection.dart';
import 'package:pgiconnect/model/yarnListmodel.dart';
import 'package:pgiconnect/screens/brachselection/branchselection.dart';
import 'package:pgiconnect/screens/dashboard/goodsreceipt/searchwidget.dart';
import 'package:pgiconnect/screens/dashboard/goodsreceipt/yardloading.dart';
import 'package:pgiconnect/screens/dbselectionpage/dbselection.dart';
import 'package:pgiconnect/screens/login/login/loginpage.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/widgets/customimagewithindicator.dart';

class YarnSelectionPage extends StatefulWidget {
  const YarnSelectionPage({super.key});

  @override
  State<YarnSelectionPage> createState() => _YarnSelectionPageState();
}

class _YarnSelectionPageState extends State<YarnSelectionPage> {
  TextEditingController searchController = TextEditingController();
  bool loading = false;
  List<YarnListModel> yarnlodingList = [];
  List<EditYarnListModel> yarneditList = [];

  ApiService apiService = ApiService();
  int? selectedIndex = 0;
  YarnListModel? selectedUser;
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
  String inProgressName = "In Progress";
  String closed = "Completed";

  int inProgressCount = 0;
  int pendingCount = 0;
  int completedCount = 0;
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
    print(alterfromdate);
    print(altertodate);
    getyarnlist();
    getedityarnlist();
    getclosedyarnlist();
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
              Text('Yard List'),
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
                _buildFilterChip(inProgressName, pendingCount),
                SizedBox(width: 8),
                _buildFilterChip(closed, completedCount),
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
                        var data = {};
                        if (selectedFilter.toString() == "Pending") {
                          data = {
                            "logisticID": product.logisticID,
                            "logisticRequestNo": product.logisticRequestNo,
                            "noOfContainers": product.noOfContainers,
                            "customerCode": product.customerCode,
                            "customerName": product.customerName,
                            "salesOrderNo": product.salesOrderNo,
                            "soEntry": product.soEntry,
                            "isEditable": false,
                          };
                        } else {
                          data = {
                            "logisticID": product.logisticID,
                            "logisticRequestNo": product.logisticRequestNo,
                            "noOfContainers": product.noOfContainers,
                            "customerCode": product.customerCode,
                            "customerName": product.customerName,
                            "salesOrderNo": product.salesOrderNo,
                            "soEntry": product.soEntry,
                            "isEditable":
                                selectedFilter == "Pending" ? false : true,
                            "yardLoadingId": product.yardLoadingId,
                            "containerNo": product.containerNumber,
                          };
                        }
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => YardLoading(
                                  data: data, status: selectedFilter)),
                        );
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
                                        child: Text(
                                            product.customerName.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(child: Text('Logistic No')),
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
                                      child: Text(
                                          product.logisticRequestNo.toString(),
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text('Sales Order No',
                                    style: TextStyle(color: Colors.black)),
                                SizedBox(height: 6),
                                Text(product.salesOrderNo.toString(),
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    //     SizedBox(
                    //   height: 100,
                    //   child: Card(
                    //     margin: EdgeInsets.all(15),
                    //     elevation: 8,
                    //     color: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(1.0),
                    //     ),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Align(
                    //             alignment: Alignment.center,
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(
                    //                   horizontal: 10.0),
                    //               child: AppUtils.buildNormalText(
                    //                   text: "test",
                    //                   color: Colors.black,
                    //                   maxLines: 2,
                    //                   fontWeight: FontWeight.bold),
                    //             )),
                    //         Expanded(
                    //             child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           children: [
                    //             Expanded(
                    //               child: Align(
                    //                 alignment: Alignment.bottomRight,
                    //                 child: Container(
                    //                   height: 30,
                    //                   width: 55,
                    //                   decoration: BoxDecoration(
                    //                       borderRadius: BorderRadius.only(
                    //                           bottomLeft: Radius.circular(0),
                    //                           bottomRight: Radius.circular(2),
                    //                           topRight: Radius.circular(0),
                    //                           topLeft: Radius.circular(12)),
                    //                       color: Appcolor.primary),
                    //                   child: Icon(
                    //                     Icons.arrow_forward,
                    //                     color: Colors.white,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         )),
                    //       ],
                    //     ),
                    //   ),
                    // );
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
          ? yarnlodingList
          : yarnlodingList.where((item) {
              String combinedText =
                  "${item.logisticID} ${item.logisticRequestNo} ${item.noOfContainers}${item.customerCode}${item.customerName}${item.salesOrderNo},${item.soEntry}"
                      .toString()
                      .toLowerCase();
              return combinedText.contains(query
                  .toString()
                  .toLowerCase()); // Check if query exists anywhere
            }).toList();
    } else {
      return query.isEmpty
          ? yarneditList
          : yarneditList.where((item) {
              String combinedText =
                  "${item.logisticID} ${item.logisticRequestNo} ${item.noOfContainers}${item.customerCode}${item.customerName}${item.salesOrderNo},${item.soEntry}"
                      .toString()
                      .toLowerCase();
              return combinedText.contains(query
                  .toString()
                  .toLowerCase()); // Check if query exists anywhere
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
                      getyarnlist();
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

  void getyarnlist() async {
    setState(() {
      loading = true;
    });

    apiService
        .getlogisticnumberList(
            Prefs.getDBName('DBName'),
            Prefs.getBranchID('BranchID'),
            alterfromdatecontroller.text,
            altertodatecontroller.text)
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        yarnlodingList.clear();
        yarnlodingList = jsonDecode(response.body)['result']
            .map<YarnListModel>((item) => YarnListModel.fromJson(item))
            .toList();
        pendingCount = yarnlodingList.length;
      } else if (response.statusCode == 401) {
        yarnlodingList.clear();
        handleTokenExpired();
      } else {
        yarnlodingList.clear();
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

  void getedityarnlist() async {
    setState(() {
      loading = true;
    });

    apiService
        .geteditlogisticnumberList(
            Prefs.getDBName('DBName'),
            Prefs.getBranchID('BranchID'),
            alterfromdatecontroller.text,
            altertodatecontroller.text)
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        yarneditList.clear();
        yarneditList = jsonDecode(response.body)['result']
            .map<EditYarnListModel>((item) => EditYarnListModel.fromJson(item))
            .toList();
        inProgressCount = yarneditList.length;
      } else if (response.statusCode == 401) {
        setState(() {
          loading = false;
        });
        yarneditList.clear();
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
      yarneditList.clear();
      AppUtils.showSingleDialogPopup(
          context, e.toString(), "Ok", onexitpopup, null);
    });
  }

  void getclosedyarnlist() async {
    setState(() {
      loading = true;
    });

    apiService
        .getclosedlogisticnumberList(
            Prefs.getDBName('DBName'),
            Prefs.getBranchID('BranchID'),
            alterfromdatecontroller.text,
            altertodatecontroller.text)
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        yarneditList.clear();
        yarneditList = jsonDecode(response.body)['result']
            .map<EditYarnListModel>((item) => EditYarnListModel.fromJson(item))
            .toList();
        completedCount = yarneditList.length;
      } else if (response.statusCode == 401) {
        setState(() {
          loading = false;
        });
        yarneditList.clear();
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
      yarneditList.clear();
      AppUtils.showSingleDialogPopup(
          context, e.toString(), "Ok", onexitpopup, null);
    });
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
      count = pendingCount; // Replace with your actual pending count
    } else if (label == "In Progress") {
      count = inProgressCount; // Replace with your actual in-progress count
    } else {
      count = completedCount; // Replace with your actual closed count
    }
    bool isSelected = label == selectedFilter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
          label.toString() == "Pending"
              ? getyarnlist()
              : label.toString() == "In Progress"
                  ? getedityarnlist()
                  : getclosedyarnlist();
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
      getyarnlist();
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
      getyarnlist();
    }
  }
}
