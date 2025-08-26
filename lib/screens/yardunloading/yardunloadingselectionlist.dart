import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/yarnunloadmodel.dart';
import 'package:pgiconnect/screens/brachselection/branchselection.dart';
import 'package:pgiconnect/screens/dashboard/goodsreceipt/searchwidget.dart';
import 'package:pgiconnect/screens/dbselectionpage/dbselection.dart';
import 'package:pgiconnect/screens/login/login/loginpage.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/screens/yardunloading/yardunloading.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/widgets/customimagewithindicator.dart';

class YardUnloadingSelectionPage extends StatefulWidget {
  const YardUnloadingSelectionPage({super.key});

  @override
  State<YardUnloadingSelectionPage> createState() =>
      _YardUnloadingSelectionPageState();
}

class _YardUnloadingSelectionPageState
    extends State<YardUnloadingSelectionPage> {
  TextEditingController searchController = TextEditingController();
  bool loading = false;
  List<YardUnloadAllModel> yarnlodingList = [];
  List<YardUnloadAllModel> yarncloselodingList = [];
  ApiService apiService = ApiService();
  int? selectedIndex = 0;
  YardUnloadAllModel? selectedUser;
  String selectedFilter = "Pending"; // Default filter
  String getDBName = "";
  String getcompanyname = "";
  String getbranchName = "";
  int getbranchId = 0;
  TextEditingController fromdatecontroller = TextEditingController();
  TextEditingController todatecontroller = TextEditingController();
  TextEditingController alterfromdatecontroller = TextEditingController();
  TextEditingController altertodatecontroller = TextEditingController();
  String pendingName = "Pending";
  String closed = "Close";

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

    getyarnlist();
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
            Text('Unloading List'),
          ],
        ),
        actions: [
          // IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         CupertinoPageRoute(
          //           builder: (context) => YardUnloadingPage(
          //             docEntry: 0,
          //             status: "Open",
          //           ),
          //         ),
          //       );
          //     },
          //     icon: Icon(CupertinoIcons.add)),
          // ElevatedButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         CupertinoPageRoute(
          //           builder: (context) => YardUnloadingPage(
          //             docEntry: 0,
          //             status: "Open",
          //           ),
          //         ),
          //       );
          //     },
          //     child: Text("Create")),
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
      body: !loading ? getBody() : Center(child: ProgressWithIcon()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => YardUnloadingPage(
                  docEntry: 0,
                  status: "Open",
                ),
              ));
        },
        label: Text(
          'Create',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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
                _buildFilterChip(pendingName, pendingCount),
                SizedBox(width: 8),
                _buildFilterChip(closed, completedCount),
              ],
            ),
          ),
        ),
        Expanded(child: listItem())
      ],
    );
  }

  Widget listItem() {
    final filteredList = _filterItems(searchController.text, selectedFilter);

    if (filteredList.isEmpty) {
      return const Center(child: Text('No Data!'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(4),
      itemCount: filteredList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final product = filteredList[index];

        return GestureDetector(
          onTap: () {
            // Uncomment and use if needed
            /*
          var data = {
            "logisticID": product.logisticID,
            "logisticRequestNo": product.logisticRequestNo,
            "noOfContainers": product.noOfContainers,
            "customerCode": product.customerCode,
            "customerName": product.customerName,
            "salesOrderNo": product.salesOrderNo,
            "soEntry": product.soEntry,
            "isEditable": selectedFilter != "Pending",
            "yardLoadingId": product.yardLoadingId,
            "containerNo": product.containerNumber,
          };

          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => YardLoading(
                data: data,
                status: selectedFilter,
              ),
            ),
          );
          */
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => YardUnloadingPage(
                  docEntry: product.yardUnloading,
                  status: selectedFilter == "Pending" ? "Open" : "Close",
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Customer Name
                    Text(
                      product.customerName.toString() ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// Yard Unloading No
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Yard Unloading No',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            product.yardUnloading.toString() ?? '',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// Sales Order No & Containers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Vechile No',
                            style: TextStyle(color: Colors.black)),
                        Text('WeighLocation',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.vechileNo.toString() ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          product.weighLocation?.toString() ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Document Type',
                            style: TextStyle(color: Colors.black)),
                        Text('Inv Type', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.documentType.toString() ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          product.invoiceType.toString() ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<YardUnloadAllModel> _filterItems(String query, String selectedFilter) {
    if (selectedFilter == "Pending") {
      return query.isEmpty
          ? yarnlodingList
          : yarnlodingList.where((item) {
              final combinedText = [
                item.yardUnloading.toString(),
                item.docDate ?? '',
                item.customerName ?? '',
                item.vechileNo ?? '',
                item.weighLocation ?? '',
                item.documentType ?? '',
                item.invoiceType ?? ''
              ].join(' ').toLowerCase();

              return combinedText.contains(query.toLowerCase());
            }).toList();
    }

    // ✅ Fix: Changed "Pending" to "Closed" (or use correct value)
    if (selectedFilter == "Close") {
      return query.isEmpty
          ? yarncloselodingList
          : yarncloselodingList.where((item) {
              final combinedText = [
                item.yardUnloading.toString(),
                item.docDate ?? '',
                item.customerName ?? '',
                item.vechileNo ?? '',
                item.weighLocation ?? '',
                item.documentType ?? '',
                item.invoiceType ?? ''
              ].join(' ').toLowerCase();

              return combinedText.contains(query.toLowerCase());
            }).toList();
    }

    return []; // ✅ fallback in case filter doesn't match
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
        .getunloadingall(
            Prefs.getDBName('DBName'),
            Prefs.getBranchID('BranchID'),
            alterfromdatecontroller.text,
            altertodatecontroller.text,
            "yardunloading",
            "Open")
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        final body = jsonDecode(response.body);
        final result = body['result'];

        if (result != null && result is List) {
          yarnlodingList.clear();
          yarnlodingList = result
              .map<YardUnloadAllModel>(
                  (item) => YardUnloadAllModel.fromJson(item))
              .toList();
          pendingCount = yarnlodingList.length;
        } else {
          yarnlodingList.clear();
          pendingCount = 0;
        }
      } else if (response.statusCode == 401) {
        yarnlodingList.clear();
        handleTokenExpired();
      } else if (response.statusCode == 500) {
        yarnlodingList.clear();
        pendingCount = 0;
        AppUtils.showSingleDialogPopup(
            context, "No Data Found", "Ok", onexitpopup, null);
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
    }
  }

  void getclosedyarnlist() async {
    setState(() {
      loading = true;
    });

    apiService
        .getunloadingall(
      Prefs.getDBName('DBName'),
      Prefs.getBranchID('BranchID'),
      alterfromdatecontroller.text,
      altertodatecontroller.text,
      "yardunloading",
      "Close",
    )
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        final body = jsonDecode(response.body);
        final result = body['result'];

        if (result != null && result is List) {
          yarncloselodingList.clear();
          yarncloselodingList = result
              .map<YardUnloadAllModel>(
                  (item) => YardUnloadAllModel.fromJson(item))
              .toList();
          completedCount = yarncloselodingList.length;
        } else {
          yarncloselodingList.clear();
          completedCount = 0;
        }
      } else if (response.statusCode == 401) {
        setState(() {
          loading = false;
        });
        yarncloselodingList.clear();
        AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'].toString(),
            "Ok",
            handleTokenExpired,
            null);
      } else if (response.statusCode == 500) {
        yarnlodingList.clear();
        pendingCount = 0;
        AppUtils.showSingleDialogPopup(
            context, "No Data Found", "Ok", onexitpopup, null);
      }
    }).catchError((e) {
      setState(() {
        loading = false;
      });
      yarncloselodingList.clear();
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
    } else {
      count = completedCount; // Replace with your actual closed count
    }
    bool isSelected = label == selectedFilter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
          label.toString() == "Pending" ? getyarnlist() : getclosedyarnlist();
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
