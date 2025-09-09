import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/agentmodel.dart';
import 'package:pgiconnect/model/editunloadmodel.dart';
import 'package:pgiconnect/model/pendingunloaditemmodel.dart';
import 'package:pgiconnect/model/poselectionmodel%20copy.dart';
import 'package:pgiconnect/model/poselectionmodel.dart';
import 'package:pgiconnect/model/projectmodel%20copy.dart';
import 'package:pgiconnect/model/projectmodel.dart';
import 'package:pgiconnect/model/suplliermodel.dart';
import 'package:pgiconnect/model/warehousemodel.dart';
import 'package:pgiconnect/model/weighlocation.dart';
import 'package:pgiconnect/model/yadmodel.dart';
import 'package:pgiconnect/screens/dashboard/approval/approvalsubmit.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/screens/pricelistupdatescreen/pendingpricelist.dart';
import 'package:pgiconnect/screens/yardunloading/pendingitem.dart';
import 'package:pgiconnect/service/appcolor.dart';

class PriceListUpdate extends StatefulWidget {
  int docEntry = 0;
  String status;
  PriceListUpdate({super.key, required this.docEntry, required this.status});

  @override
  State<PriceListUpdate> createState() => _PriceListUpdateState();
}

class _PriceListUpdateState extends State<PriceListUpdate> {
  TextEditingController supplierNamecontroller = TextEditingController();
  TextEditingController pickupNoController = TextEditingController();
  TextEditingController yardController = TextEditingController();
  TextEditingController refNoController = TextEditingController();
  TextEditingController agentNameController = TextEditingController();
  TextEditingController postingDate = TextEditingController();
  TextEditingController poNumcontroller = TextEditingController();
  TextEditingController poentryController = TextEditingController();
  TextEditingController weightfromdatecontroller = TextEditingController();
  TextEditingController weighttodatecontroller = TextEditingController();
  List<PendingItem> selectedPendingItems = [];
  TextEditingController alterweightfromdatecontroller = TextEditingController();
  TextEditingController alterweighttodatecontroller = TextEditingController();

  ApiService apiService = ApiService();
  bool loading = false;
  int? expandedIndex;
  final List<File> _images = [];
  final List<File> _editimages = [];
  final List<String> _removedURL = [];
  final List<File> selectedImageList = [];
  final supplierKey = GlobalKey<DropdownSearchState<SuppplierModel>>();
  final agentKey = GlobalKey<DropdownSearchState<AgentModel>>();
  final projectkey = GlobalKey<DropdownSearchState<ProjectModel>>();
  final yardKey = GlobalKey<DropdownSearchState<YardModel>>();
  final whsKey = GlobalKey<DropdownSearchState<WarehouseModel>>();
  final salesKey = GlobalKey<DropdownSearchState<SalesPersonModel>>();
  final whsKey1 = GlobalKey<DropdownSearchState<WarehouseModel>>();
  final weighKey = GlobalKey<DropdownSearchState<WeighLocationModel>>();
  final poKey = GlobalKey<DropdownSearchState<PoModel>>();
  final poLineKey = GlobalKey<DropdownSearchState<PoLineModel>>();

  String getsupplierId = '';
  String getsupplierName = '';

  String getprojectId = "";
  String getprojectName = '';
  String getAgentCode = '';
  String getAgentName = '';
  String getyardId = '';
  String getyardName = '';

  String getwhsCode = '';
  String getWhsName = '';

  String getsalespersonCode = '';
  String getsalespersonName = '';

  String getwaybridgeCode = '';
  String getwaybridgeName = '';

  Map<String, String> invoiceType = {"LME": "LME", "Normal": "Normal"};
  Map<String, String> headingType = {"Y": "Yes", "N": "No"};

  Map<String, String> docType = {
    "Provisional": "Provisional",
    "Final": "Final"
  };

  MapEntry<String, String>? selectedinvoiceType;
  MapEntry<String, String>? selecteddocType;
  MapEntry<String, String>? selecteddheading;
  List<WarehouseModel> selectedwarehouse = [];
  List<EditUnloadModel> editYarnList = [];

  PoLineModel? selectedpoLine;
  PoModel? selectedPo;
  SuppplierModel? selectedSupplier;

  ProjectModel? selectedProject;
  YardModel? selectedYard;
  AgentModel? selectedAgent;
  WarehouseModel? selectedWhs;
  SalesPersonModel? selectedSales;
  WeighLocationModel? selectedWaybridge;

  bool value1 = false;

  MapEntry<String, String>? selectedGrn;

  List<MapEntry<String, String>> grnList = [
    const MapEntry("Y", "Yes"),
    const MapEntry("N", "No"),
  ];

  @override
  void initState() {
    print(widget.status);
    if (widget.status == "Open") {
      editUnloading();
    } else {
      editUnloading();
    }
    super.initState();
  }

  @override
  void dispose() {
    supplierNamecontroller.dispose();
    pickupNoController.dispose();
    yardController.dispose();
    agentNameController.dispose();
    refNoController.dispose();
    postingDate.dispose();
    poNumcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Appcolor.primary,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price List Update'),
              ],
            ),
            centerTitle: false,
            actions: [
              CupertinoSwitch(
                value: value1,
                onChanged: (val) {
                  setState(() {
                    value1 = val;
                  });
                },
              ),
              SizedBox(
                width: 20,
              ),
              Badge(
                alignment: Alignment.center,
                label: Text(value1 == true ? "Close" : widget.status),
                child: Text(
                  '',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 50,
              ),
              // IconButton(
              //     onPressed: () {

              //     },
              //     icon: Icon(Icons.save))
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
                          text: "Item Details",
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: ScrollPhysics(),
                        children: [
                          headerwidgets(),
                          itemsswidgets(),
                        ],
                      ),
                    )
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
          persistentFooterButtons: [
            widget.status == "Close"
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Appcolor.primary),
                        onPressed: () {
                          if (getwhsCode.isEmpty) {
                            AppUtils.showSingleDialogPopup(
                                context,
                                "Please Select Warehouse",
                                "Ok",
                                exitpopup,
                                null);
                          } else if (selectedGrn!.value.isEmpty) {
                            AppUtils.showSingleDialogPopup(context,
                                "Please Select GRN", "Ok", exitpopup, null);
                          } else if (getsalespersonCode.isEmpty) {
                            AppUtils.showSingleDialogPopup(
                                context,
                                "Please Select SalesPerson",
                                "Ok",
                                exitpopup,
                                null);
                          } else if (getwhsCode.isEmpty) {
                            AppUtils.showSingleDialogPopup(
                                context,
                                "Please Select Warehouse",
                                "Ok",
                                exitpopup,
                                null);
                          } else if (selectedPendingItems.isEmpty) {
                            AppUtils.showSingleDialogPopup(context,
                                "Please Select Items", "Ok", exitpopup, null);
                          } else {
                            postitems();
                          }
                        },
                        child: Row(
                          children: [
                            Text("Submit",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
          ],
        ));
  }

  Widget headerwidgets() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppUtils.buildNormalText(text: "Supplier Details"),
            SizedBox(height: 5),
            DropdownSearch<SuppplierModel>(
              selectedItem: selectedSupplier,
              key: supplierKey,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                interceptCallBacks: true, //important line
                itemBuilder: (ctx, item, isSelected) {
                  return ListTile(
                      selected: isSelected,
                      title: Text(
                        item.value.toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        supplierKey.currentState?.popupValidate([item]);
                        getsupplierId = item.id.toString();
                        getsupplierName = item.value.toString();
                        setState(() {});
                      });
                },
              ),
              asyncItems: (String filter) => ApiService.getsupplierlist(
                Prefs.getDBName('DBName'),
                Prefs.getBranchID('BranchID'),
                filter: filter,
              ),
              itemAsString: (SuppplierModel item) => item.value.toString(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  hintText: 'Supplier * ',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            AppUtils.buildNormalText(text: "Pickup No"),
            SizedBox(height: 5),
            TextFormField(
              maxLines: 1,
              controller: pickupNoController,
              onChanged: (val) => {},
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
                hintText: "Pickup No",
                disabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
              ),
            ),
            SizedBox(height: 5),

            AppUtils.buildNormalText(text: "Yard"),
            SizedBox(height: 5),
            DropdownSearch<YardModel>(
              selectedItem: selectedYard,
              key: yardKey,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                interceptCallBacks: true, //important line
                itemBuilder: (ctx, item, isSelected) {
                  return ListTile(
                      selected: isSelected,
                      title: Text(
                        item.value.toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        yardKey.currentState?.popupValidate([item]);
                        getyardId = item.id.toString();
                        getyardName = item.value.toString();
                        setState(() {});
                      });
                },
              ),
              asyncItems: (String filter) => ApiService.getyardlist(
                Prefs.getDBName('DBName'),
                Prefs.getBranchID('BranchID'),
                filter: filter,
              ),
              itemAsString: (YardModel item) => item.value.toString(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  hintText: 'Yard * ',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            // AppUtils.buildNormalText(text: "Agent"),
            // SizedBox(height: 5),
            // DropdownSearch<AgentModel>(
            //   selectedItem: selectedAgent,
            //   key: agentKey,
            //   popupProps: PopupProps.menu(
            //     showSearchBox: true,
            //     interceptCallBacks: true, //important line
            //     itemBuilder: (ctx, item, isSelected) {
            //       return ListTile(
            //           selected: isSelected,
            //           title: Text(
            //             item.value.toString(),
            //             style: TextStyle(
            //               color: Colors.black,
            //             ),
            //           ),
            //           onTap: () {
            //             agentKey.currentState?.popupValidate([item]);
            //             getAgentCode = item.id.toString();
            //             getAgentName = item.value.toString();
            //             setState(() {});
            //           });
            //     },
            //   ),
            //   asyncItems: (String filter) => ApiService.getAgentlist(
            //     Prefs.getDBName('DBName'),
            //     Prefs.getBranchID('BranchID'),
            //     filter: filter,
            //   ),
            //   itemAsString: (AgentModel item) => item.value.toString(),
            //   dropdownDecoratorProps: DropDownDecoratorProps(
            //     dropdownSearchDecoration: InputDecoration(
            //       contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            //       hintText: 'Agent * ',
            //       enabledBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(1),
            //         borderSide: const BorderSide(color: Colors.grey, width: 1),
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(1),
            //         borderSide: const BorderSide(color: Colors.grey, width: 1),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              height: 5,
            ),
            AppUtils.buildNormalText(text: "Warehouse"),
            SizedBox(height: 5),
            DropdownSearch<WarehouseModel>(
              key: whsKey,
              selectedItem: selectedWhs,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                interceptCallBacks: true, //important line
                itemBuilder: (ctx, item, isSelected) {
                  return ListTile(
                      selected: isSelected,
                      title: Text(
                        item.value.toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        whsKey.currentState?.popupValidate([item]);
                        getwhsCode = item.id.toString();
                        getWhsName = item.value.toString();
                        setState(() {});
                      });
                },
              ),
              asyncItems: (String filter) => ApiService.getwarehouselist(
                Prefs.getDBName('DBName'),
                Prefs.getBranchID('BranchID'),
                filter: filter,
              ),
              itemAsString: (WarehouseModel item) => item.value.toString(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  hintText: 'WareHouse * ',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            AppUtils.buildNormalText(text: "Purchase Trader"),
            SizedBox(height: 5),
            DropdownSearch<SalesPersonModel>(
              selectedItem: selectedSales,
              key: salesKey,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                interceptCallBacks: true, //important line
                itemBuilder: (ctx, item, isSelected) {
                  return ListTile(
                      selected: isSelected,
                      title: Text(
                        item.value.toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        salesKey.currentState?.popupValidate([item]);
                        getsalespersonCode = item.id.toString();
                        getsalespersonName = item.value.toString();
                        setState(() {});
                      });
                },
              ),
              asyncItems: (String filter) => ApiService.getsalesperson(
                Prefs.getDBName('DBName'),
                Prefs.getBranchID('BranchID'),
                filter: filter,
              ),
              itemAsString: (SalesPersonModel item) => item.value.toString(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  hintText: 'Sales person * ',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // AppUtils.buildNormalText(text: "PO Num"),
            // SizedBox(height: 5),
            // TextFormField(
            //   controller: poNumcontroller,
            //   keyboardType: TextInputType.number,
            //   inputFormatters: <TextInputFormatter>[
            //     FilteringTextInputFormatter.digitsOnly
            //   ],
            //   maxLines: 1,
            //   readOnly: true,
            //   onChanged: (val) => {},
            //   decoration: InputDecoration(
            //     contentPadding:
            //         const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            //     focusedBorder: const OutlineInputBorder(
            //         borderSide: BorderSide(width: 1, color: Colors.grey)),
            //     enabledBorder: OutlineInputBorder(
            //       borderSide: const BorderSide(color: Colors.black26, width: 1),
            //     ),
            //     hintText: "Po Num",
            //     disabledBorder: OutlineInputBorder(
            //       borderSide: const BorderSide(color: Colors.black26, width: 1),
            //     ),
            //   ),
            // ),
            // SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Expanded(
                //     flex: 5,
                //     child: AppUtils.buildNormalText(
                //         text: "Weigh bridge Location")),
                Expanded(
                    flex: 5,
                    child: AppUtils.buildNormalText(text: "Is Posting GRN")),
              ],
            ),
            Row(
              children: [
                // Expanded(
                //   flex: 5,
                //   child: DropdownSearch<WeighLocationModel>(
                //     selectedItem: selectedWaybridge,
                //     key: weighKey,
                //     popupProps: PopupProps.menu(
                //       showSearchBox: true,
                //       interceptCallBacks: true, //important line
                //       itemBuilder: (ctx, item, isSelected) {
                //         return ListTile(
                //             selected: isSelected,
                //             title: Text(
                //               item.value.toString(),
                //               style: TextStyle(
                //                 color: Colors.black,
                //               ),
                //             ),
                //             onTap: () {
                //               weighKey.currentState?.popupValidate([item]);
                //               getwaybridgeCode = item.id.toString();
                //               getwaybridgeName = item.value.toString();
                //               setState(() {});
                //             });
                //       },
                //     ),
                //     asyncItems: (String filter) =>
                //         ApiService.getwaybridgelocation(
                //       Prefs.getDBName('DBName'),
                //       Prefs.getBranchID('BranchID'),
                //       filter: filter,
                //     ),
                //     itemAsString: (WeighLocationModel item) =>
                //         item.value.toString(),
                //     dropdownDecoratorProps: DropDownDecoratorProps(
                //       dropdownSearchDecoration: InputDecoration(
                //         contentPadding: EdgeInsets.fromLTRB(5.0, 10, 5.0, 2),
                //         hintText: '',
                //         enabledBorder: OutlineInputBorder(
                //           borderRadius: BorderRadius.circular(1),
                //           borderSide:
                //               const BorderSide(color: Colors.grey, width: 1),
                //         ),
                //         focusedBorder: OutlineInputBorder(
                //           borderRadius: BorderRadius.circular(1),
                //           borderSide:
                //               const BorderSide(color: Colors.grey, width: 1),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   width: 5,
                // ),
                Expanded(
                  flex: 5,
                  child: DropdownSearch<MapEntry<String, String>>(
                    items: grnList,
                    itemAsString: (MapEntry<String, String>? entry) =>
                        entry?.value ?? 'Y',
                    selectedItem: selectedGrn,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10, 5.0, 2),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedGrn = value;
                      });
                      print("Selected: ${value?.key} - ${value?.value}");
                      //getGrnCode = "${value?.key}";
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // SizedBox(height: 5),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     Expanded(
            //         flex: 5,
            //         child: AppUtils.buildNormalText(
            //             text: "Weighbridge From Date")),
            //     Expanded(
            //         flex: 5,
            //         child:
            //             AppUtils.buildNormalText(text: "Weighbridge To Date")),
            //   ],
            // ),
            // SizedBox(height: 5),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 5,
            //       child: TextFormField(
            //         maxLines: 1,
            //         readOnly: true,
            //         controller: weightfromdatecontroller,
            //         onTap: () {
            //           pickerfromdate();
            //         },
            //         decoration: InputDecoration(
            //           contentPadding: const EdgeInsets.symmetric(
            //               horizontal: 8, vertical: 8),
            //           focusedBorder: const OutlineInputBorder(
            //               borderSide: BorderSide(width: 1, color: Colors.grey)),
            //           enabledBorder: OutlineInputBorder(
            //             borderSide:
            //                 const BorderSide(color: Colors.black26, width: 1),
            //           ),
            //           hintText: "Weigh bridge from date",
            //           disabledBorder: OutlineInputBorder(
            //             borderSide:
            //                 const BorderSide(color: Colors.black26, width: 1),
            //           ),
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: 5),
            //     Expanded(
            //       flex: 5,
            //       child: TextFormField(
            //         controller: weighttodatecontroller,
            //         readOnly: true,
            //         onTap: () {
            //           pickertodate();
            //         },
            //         maxLines: 1,
            //         onChanged: (val) => {},
            //         decoration: InputDecoration(
            //           contentPadding: const EdgeInsets.symmetric(
            //               horizontal: 8, vertical: 8),
            //           focusedBorder: const OutlineInputBorder(
            //               borderSide: BorderSide(width: 1, color: Colors.grey)),
            //           enabledBorder: OutlineInputBorder(
            //             borderSide:
            //                 const BorderSide(color: Colors.black26, width: 1),
            //           ),
            //           hintText: "Weigh bridge from date",
            //           disabledBorder: OutlineInputBorder(
            //             borderSide:
            //                 const BorderSide(color: Colors.black26, width: 1),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            AppUtils.buildNormalText(text: "Project Details"),
            SizedBox(height: 5),
            DropdownSearch<ProjectModel>(
              key: projectkey,
              selectedItem: selectedProject,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                interceptCallBacks: true, //important line
                itemBuilder: (ctx, item, isSelected) {
                  return ListTile(
                      selected: isSelected,
                      title: Text(
                        item.value.toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        projectkey.currentState?.popupValidate([item]);
                        getprojectId = item.id.toString();
                        getprojectName = item.value.toString();
                        setState(() {});
                      });
                },
              ),
              asyncItems: (String filter) => ApiService.getprojectlist(
                Prefs.getDBName('DBName'),
                Prefs.getBranchID('BranchID'),
                filter: filter,
              ),
              itemAsString: (ProjectModel item) => item.value.toString(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  hintText: 'Projects * ',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  void exitpopup() {
    AppUtils.pop(context);
  }

  Future<void> callgetitemlist(BuildContext context) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PendingItemScreen(
          getDBName: Prefs.getDBName('DBName') ?? '',
          getBranchID: Prefs.getBranchID('BranchID').toString(),
          // fromDate: widget.status == "Open"
          //     ? alterweightfromdatecontroller.text
          //     : convertDate(alterweightfromdatecontroller.text),
          // toDate: widget.status == "Open"
          //     ? alterweighttodatecontroller.text
          //     : convertDate(alterweighttodatecontroller.text),
          supplierId: getsupplierId,
          supplierName: getsupplierName,
          pickupNo: pickupNoController.text,
          location: getwaybridgeCode,
          ticketNo: "",
        ),
      ),
    );

    if (result != null && result['selectedItems'] != null) {
      setState(() {
        selectedPendingItems = List<PendingItem>.from(result['selectedItems']);
      });
    }
  }

  String convertDateNew(String inputDate) {
    // Parse the input date
    DateTime date = DateFormat('dd-MM-yyyy').parse(inputDate);

    // Format as yyyyMMdd
    String formatted = DateFormat('yyyy-MM-dd').format(date);

    return formatted;
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

  // Widget itemsswidgets() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         SizedBox(height: 10),
  //         selectedPendingItems.isNotEmpty
  //             ? ListView.builder(
  //                 shrinkWrap: true,
  //                 physics: NeverScrollableScrollPhysics(),
  //                 itemCount: selectedPendingItems.length,
  //                 itemBuilder: (BuildContext context, int index) {
  //                   selectedWhs =
  //                       WarehouseModel(id: getwhsCode, value: getWhsName);
  //                   final bool isLME =
  //                       selectedPendingItems[index].invoiceType == 'LME';
  //                   try {
  //                     if (selectedPendingItems[index].documentType.isEmpty) {
  //                       selectedPendingItems[index].documentType =
  //                           "Provisional";
  //                     }

  //                     selecteddocType = docType.entries.firstWhere(
  //                       (entry) =>
  //                           entry.key ==
  //                           selectedPendingItems[index].documentType,
  //                     );
  //                   } catch (e) {
  //                     // If not found, assign default
  //                     selecteddocType =
  //                         const MapEntry("Provisional", "Provisional");
  //                     selectedPendingItems[index].documentType = "Provisional";
  //                   }
  //                   try {
  //                     if (selectedPendingItems[index].invoiceType.isEmpty) {
  //                       selectedPendingItems[index].invoiceType = "LME";
  //                     }

  //                     selectedinvoiceType = invoiceType.entries.firstWhere(
  //                       (entry) =>
  //                           entry.key ==
  //                           selectedPendingItems[index].invoiceType,
  //                     );
  //                   } catch (e) {
  //                     // If not found, assign default
  //                     selectedinvoiceType = const MapEntry("LME", "LME");
  //                     selectedPendingItems[index].invoiceType = "LME";
  //                   }
  //                   return Theme(
  //                     data: Theme.of(context)
  //                         .copyWith(dividerColor: Colors.transparent),
  //                     child: ExpansionTile(
  //                       key: Key(index ==
  //                               expandedIndex // different key when state changes forces rebuild
  //                           ? 'expanded_$index'
  //                           : 'collapsed_$index'),
  //                       initiallyExpanded: expandedIndex == index,
  //                       onExpansionChanged: (expanded) {
  //                         setState(() {
  //                           expandedIndex = expanded ? index : null;
  //                         });
  //                       },

  //                       //heading
  //                       backgroundColor: Colors.white,
  //                       title: Text(
  //                         "${selectedPendingItems[index].itemCode}- ${selectedPendingItems[index].itemName} - Qty ${selectedPendingItems[index].quantity}",
  //                         style: TextStyle(
  //                             fontWeight: FontWeight.bold, fontSize: 16),
  //                       ),
  //                       children: [
  //                         Card(
  //                           margin: const EdgeInsets.only(bottom: 10),
  //                           color: Colors.white,
  //                           child: Padding(
  //                             padding: const EdgeInsets.all(8),
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Row(
  //                                   children: [
  //                                     Expanded(
  //                                       flex: 4,
  //                                       child: AppUtils.buildNormalText(
  //                                           text: "Invoice Type"),
  //                                     ),
  //                                     const SizedBox(width: 5),
  //                                     Expanded(
  //                                       flex: 3,
  //                                       child: AppUtils.buildNormalText(
  //                                           text: "Doc Type"),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 const SizedBox(height: 5),
  //                                 Row(
  //                                   children: [
  //                                     Expanded(
  //                                         flex: 5,
  //                                         child: DropdownSearch<
  //                                             MapEntry<String, String>>(
  //                                           enabled: true,
  //                                           selectedItem: selectedinvoiceType,
  //                                           items: invoiceType.entries.toList(),
  //                                           itemAsString: (entry) =>
  //                                               entry.value,
  //                                           onChanged: (entry) {
  //                                             if (entry != null) {
  //                                               setState(() {
  //                                                 selectedPendingItems[index]
  //                                                     .invoiceType = entry.key;
  //                                               });
  //                                             }
  //                                           },
  //                                         )),
  //                                     const SizedBox(width: 5),
  //                                     Expanded(
  //                                       flex: 5,
  //                                       child: DropdownSearch<
  //                                           MapEntry<String, String>>(
  //                                         enabled: true,
  //                                         selectedItem: selecteddocType,
  //                                         items: docType.entries.toList(),
  //                                         itemAsString: (entry) => entry.value,
  //                                         onChanged: (entry) {
  //                                           if (entry != null) {
  //                                             setState(() {
  //                                               selecteddocType = entry;
  //                                               selectedPendingItems[index]
  //                                                   .documentType = entry.key;
  //                                             });
  //                                           }
  //                                         },
  //                                         popupProps: PopupProps.menu(
  //                                             showSearchBox: true),
  //                                         dropdownDecoratorProps:
  //                                             DropDownDecoratorProps(
  //                                           dropdownSearchDecoration:
  //                                               InputDecoration(
  //                                             contentPadding:
  //                                                 EdgeInsets.symmetric(
  //                                                     horizontal: 10,
  //                                                     vertical: 10),
  //                                             border: OutlineInputBorder(),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 const SizedBox(height: 5),
  //                                 // Item Name (Always show)

  //                                 AppUtils.buildNormalText(text: "Item Name"),
  //                                 const SizedBox(height: 5),
  //                                 TextFormField(
  //                                   initialValue:
  //                                       selectedPendingItems[index].itemName ??
  //                                           '',
  //                                   readOnly: true,
  //                                   decoration: const InputDecoration(
  //                                     contentPadding: EdgeInsets.symmetric(
  //                                         horizontal: 8, vertical: 8),
  //                                     border: OutlineInputBorder(),
  //                                   ),
  //                                 ),

  //                                 const SizedBox(height: 10),
  //                                 Row(children: [
  //                                   Expanded(
  //                                       flex: 5,
  //                                       child: AppUtils.buildNormalText(
  //                                           text: "Qty")),
  //                                   Expanded(
  //                                       flex: 5,
  //                                       child: AppUtils.buildNormalText(
  //                                           text: "Unit Price")),
  //                                 ]),
  //                                 const SizedBox(height: 5),
  //                                 Row(children: [
  //                                   Expanded(
  //                                     flex: 5,
  //                                     child: TextFormField(
  //                                       initialValue:
  //                                           selectedPendingItems[index]
  //                                               .quantity
  //                                               .toString(),
  //                                       keyboardType: const TextInputType
  //                                           .numberWithOptions(
  //                                           decimal: true, signed: false),
  //                                       inputFormatters: [
  //                                         // allows: digits + single decimal point
  //                                         FilteringTextInputFormatter.allow(
  //                                             RegExp(r'^\d*\.?\d*$')),
  //                                       ],
  //                                       onChanged: (value) {
  //                                         setState(() {
  //                                           selectedPendingItems[index]
  //                                                   .quantity =
  //                                               double.tryParse(value) ?? 0.0;
  //                                           selectedPendingItems[index].total =
  //                                               selectedPendingItems[index]
  //                                                       .quantity *
  //                                                   selectedPendingItems[index]
  //                                                       .unitPrice;
  //                                         });
  //                                       },
  //                                       decoration: const InputDecoration(
  //                                           border: OutlineInputBorder()),
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 5),
  //                                   Expanded(
  //                                     flex: 5,
  //                                     child: TextFormField(
  //                                       initialValue:
  //                                           selectedPendingItems[index]
  //                                               .unitPrice
  //                                               .toString(),
  //                                       keyboardType: const TextInputType
  //                                           .numberWithOptions(
  //                                           decimal: true, signed: false),
  //                                       inputFormatters: [
  //                                         // allows: digits + single decimal point
  //                                         FilteringTextInputFormatter.allow(
  //                                             RegExp(r'^\d*\.?\d*$')),
  //                                       ],
  //                                       onChanged: (value) {
  //                                         setState(() {
  //                                           selectedPendingItems[index]
  //                                                   .unitPrice =
  //                                               double.tryParse(value) ?? 0.0;
  //                                           selectedPendingItems[index].total =
  //                                               selectedPendingItems[index]
  //                                                       .quantity *
  //                                                   selectedPendingItems[index]
  //                                                       .unitPrice;
  //                                         });
  //                                       },
  //                                       decoration: const InputDecoration(
  //                                           border: OutlineInputBorder()),
  //                                     ),
  //                                   ),
  //                                 ]),

  //                                 const SizedBox(height: 10),
  //                                 AppUtils.buildNormalText(
  //                                     text: "Control Price"),
  //                                 const SizedBox(height: 5),
  //                                 TextFormField(
  //                                   readOnly: true,
  //                                   initialValue: selectedPendingItems[index]
  //                                       .controlPrice
  //                                       .toString(),
  //                                   decoration: InputDecoration(
  //                                     filled: true,
  //                                     fillColor: Colors.grey.shade200,
  //                                     border: const OutlineInputBorder(),
  //                                   ),
  //                                 ),

  //                                 const SizedBox(height: 10),
  //                                 Row(children: [
  //                                   Expanded(
  //                                       flex: 3,
  //                                       child: AppUtils.buildNormalText(
  //                                           text: "PO Num")),
  //                                   Expanded(
  //                                       flex: 3,
  //                                       child: AppUtils.buildNormalText(
  //                                           text: "PO Line")),
  //                                 ]),
  //                                 const SizedBox(height: 5),
  //                                 Row(children: [
  //                                   Expanded(
  //                                     flex: 3,
  //                                     child: DropdownSearch<PoModel>(
  //                                       key: poKey,
  //                                       selectedItem: selectedPo,
  //                                       asyncItems: (filter) =>
  //                                           ApiService.getpolists(
  //                                         Prefs.getDBName('DBName'),
  //                                         Prefs.getBranchID('BranchID'),
  //                                         getsupplierId,
  //                                         filter: filter,
  //                                       ),
  //                                       itemAsString: (item) =>
  //                                           item.poNumber.toString(),
  //                                       onChanged: (item) {
  //                                         if (item != null) {
  //                                           setState(() {
  //                                             selectedPendingItems[index]
  //                                                     .poNumber =
  //                                                 item.poNumber.toString();
  //                                             selectedPendingItems[index]
  //                                                     .pOEntry =
  //                                                 item.poEntry.toString();
  //                                             selectedPendingItems[index]
  //                                                     .poLine =
  //                                                 item.poLine!.toInt();
  //                                           });
  //                                         }
  //                                       },
  //                                       dropdownDecoratorProps:
  //                                           DropDownDecoratorProps(
  //                                         dropdownSearchDecoration:
  //                                             InputDecoration(
  //                                           contentPadding:
  //                                               EdgeInsets.symmetric(
  //                                                   horizontal: 10,
  //                                                   vertical: 10),
  //                                           border: OutlineInputBorder(),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 5),
  //                                   Expanded(
  //                                     flex: 3,
  //                                     child: DropdownSearch<PoLineModel>(
  //                                       key: poLineKey,
  //                                       selectedItem: selectedpoLine,
  //                                       asyncItems: (filter) =>
  //                                           ApiService.getpolinenumber(
  //                                         Prefs.getDBName('DBName'),
  //                                         Prefs.getBranchID('BranchID'),
  //                                         getsupplierId,
  //                                         filter: filter,
  //                                         selectedPendingItems[index].pOEntry,
  //                                       ),
  //                                       itemAsString: (item) =>
  //                                           item.value.toString(),
  //                                       dropdownDecoratorProps:
  //                                           DropDownDecoratorProps(
  //                                         dropdownSearchDecoration:
  //                                             InputDecoration(
  //                                           contentPadding:
  //                                               EdgeInsets.symmetric(
  //                                                   horizontal: 10,
  //                                                   vertical: 10),
  //                                           border: OutlineInputBorder(),
  //                                         ),
  //                                       ),
  //                                       onChanged: (item) {
  //                                         setState(() {
  //                                           selectedpoLine = item;
  //                                         });
  //                                       },
  //                                     ),
  //                                   ),
  //                                 ]),

  //                                 const SizedBox(height: 10),

  //                                 AppUtils.buildNormalText(text: "Total"),
  //                                 TextFormField(
  //                                   readOnly: true,
  //                                   controller: TextEditingController(
  //                                     text: selectedPendingItems[index]
  //                                         .total
  //                                         .toStringAsFixed(2),
  //                                   ),
  //                                   decoration: InputDecoration(
  //                                     filled: true,
  //                                     fillColor: Colors.grey.shade200,
  //                                     border: const OutlineInputBorder(),
  //                                   ),
  //                                 ),

  //                                 // 🔽 LME-Specific Section
  //                                 if (isLME) ...[
  //                                   const SizedBox(height: 10),
  //                                   Row(children: [
  //                                     Expanded(
  //                                         flex: 3,
  //                                         child: AppUtils.buildNormalText(
  //                                             text: "LME Level %")),
  //                                     Expanded(
  //                                         flex: 3,
  //                                         child: AppUtils.buildNormalText(
  //                                             text: "Control %")),
  //                                   ]),
  //                                   const SizedBox(height: 5),
  //                                   Row(children: [
  //                                     Expanded(
  //                                       flex: 3,
  //                                       child: TextFormField(
  //                                         initialValue:
  //                                             selectedPendingItems[index]
  //                                                 .lMELevelFormula
  //                                                 .toString(),
  //                                         onChanged: (value) {
  //                                           selectedPendingItems[index]
  //                                                   .lMELevelFormula =
  //                                               double.tryParse(value) ?? 0.0;
  //                                         },
  //                                         decoration: const InputDecoration(
  //                                             border: OutlineInputBorder()),
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 5),
  //                                     Expanded(
  //                                       flex: 3,
  //                                       child: TextFormField(
  //                                         readOnly: true,
  //                                         initialValue:
  //                                             selectedPendingItems[index]
  //                                                 .controlPercentage
  //                                                 .toString(),
  //                                         decoration: InputDecoration(
  //                                           filled: true,
  //                                           fillColor: Colors.grey.shade200,
  //                                           border: const OutlineInputBorder(),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ]),
  //                                   const SizedBox(height: 10),
  //                                   Row(children: [
  //                                     Expanded(
  //                                         flex: 4,
  //                                         child: AppUtils.buildNormalText(
  //                                             text: "LME Amount")),
  //                                     Expanded(
  //                                         flex: 3,
  //                                         child: AppUtils.buildNormalText(
  //                                             text: "LME Fix Date")),
  //                                     Expanded(
  //                                         flex: 3,
  //                                         child: AppUtils.buildNormalText(
  //                                             text: "Contango Amt")),
  //                                   ]),
  //                                   const SizedBox(height: 5),
  //                                   Row(children: [
  //                                     Expanded(
  //                                       flex: 4,
  //                                       child: TextFormField(
  //                                         initialValue:
  //                                             selectedPendingItems[index]
  //                                                 .lMEAmount
  //                                                 .toString(),
  //                                         onChanged: (value) {
  //                                           selectedPendingItems[index]
  //                                                   .lMEAmount =
  //                                               double.tryParse(value) ?? 0.0;
  //                                         },
  //                                         decoration: const InputDecoration(
  //                                             border: OutlineInputBorder()),
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 5),
  //                                     Expanded(
  //                                       flex: 3,
  //                                       child: TextFormField(
  //                                         readOnly: true,
  //                                         controller: TextEditingController(
  //                                           text: selectedPendingItems[index]
  //                                                   .lMEFixationDate ??
  //                                               '',
  //                                         ),
  //                                         onTap: () => _selectDate(index),
  //                                         decoration: const InputDecoration(
  //                                             border: OutlineInputBorder()),
  //                                       ),
  //                                     ),
  //                                     const SizedBox(width: 5),
  //                                     Expanded(
  //                                       flex: 3,
  //                                       child: TextFormField(
  //                                         initialValue:
  //                                             selectedPendingItems[index]
  //                                                 .contango
  //                                                 .toString(),
  //                                         onChanged: (value) {
  //                                           selectedPendingItems[index]
  //                                                   .contango =
  //                                               int.tryParse(value) ?? 0;
  //                                         },
  //                                         decoration: const InputDecoration(
  //                                             border: OutlineInputBorder()),
  //                                       ),
  //                                     ),
  //                                   ]),
  //                                   const SizedBox(height: 10),
  //                                   AppUtils.buildNormalText(
  //                                       text: "Hedging Required"),
  //                                   DropdownSearch<MapEntry<String, String>>(
  //                                     selectedItem:
  //                                         headingType.entries.firstWhere(
  //                                       (entry) =>
  //                                           entry.key.toUpperCase() ==
  //                                           (selectedPendingItems[index]
  //                                                       .hedgingRequired ??
  //                                                   '')
  //                                               .toUpperCase(),
  //                                       orElse: () => const MapEntry("N", "No"),
  //                                     ),
  //                                     items: headingType.entries.toList(),
  //                                     itemAsString: (entry) => entry.value,
  //                                     onChanged: (entry) {
  //                                       if (entry != null) {
  //                                         setState(() {
  //                                           selectedPendingItems[index]
  //                                               .hedgingRequired = entry.key;
  //                                         });
  //                                       }
  //                                     },
  //                                   )
  //                                 ],
  //                                 AppUtils.buildNormalText(
  //                                     text: "Purchase Remarks"),
  //                                 const SizedBox(height: 5),
  //                                 TextFormField(
  //                                   initialValue: selectedPendingItems[index]
  //                                       .purchaseRemarks
  //                                       .toString(),
  //                                   onChanged: (value) {
  //                                     selectedPendingItems[index]
  //                                         .purchaseRemarks = value;
  //                                   },
  //                                   decoration: const InputDecoration(
  //                                       border: OutlineInputBorder()),
  //                                 ),

  //                                 const SizedBox(height: 10),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 })
  //             : Center(
  //                 child: Text("No Data!"),
  //               ),
  //       ],
  //     ),
  //   );
  // }

  Widget itemsswidgets() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          selectedPendingItems.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedPendingItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    selectedWhs =
                        WarehouseModel(id: getwhsCode, value: getWhsName);

                    try {
                      if (selectedPendingItems[index].documentType.isEmpty) {
                        selectedPendingItems[index].documentType =
                            "Provisional";
                      }

                      selecteddocType = docType.entries.firstWhere(
                        (entry) =>
                            entry.key ==
                            selectedPendingItems[index].documentType,
                      );
                    } catch (e) {
                      selecteddocType =
                          const MapEntry("Provisional", "Provisional");
                      selectedPendingItems[index].documentType = "Provisional";
                    }

                    try {
                      if (selectedPendingItems[index].invoiceType.isEmpty) {
                        selectedPendingItems[index].invoiceType = "LME";
                      }

                      selectedinvoiceType = invoiceType.entries.firstWhere(
                        (entry) =>
                            entry.key.toLowerCase().trim() ==
                            (selectedPendingItems[index].invoiceType ?? '')
                                .toLowerCase()
                                .trim(),
                        orElse: () =>
                            const MapEntry("LME", "LME"), // 👈 fallback
                      );
                    } catch (e) {
                      selectedinvoiceType = const MapEntry("LME", "LME");
                      selectedPendingItems[index].invoiceType = "LME";
                    }

                    // normalize values for condition checks
                    final String selectinvoiceType =
                        (selectedPendingItems[index].invoiceType ?? '')
                            .trim()
                            .toLowerCase();
                    final String selecteddocTypeValue =
                        (selectedPendingItems[index].documentType ?? '')
                            .trim()
                            .toLowerCase();

                    final bool isLME = selectinvoiceType == 'lme';
                    final bool isFinalDoc = selecteddocTypeValue == 'final';
                    final bool isProvisionalDoc =
                        selecteddocTypeValue == 'provisional';
                    final bool isNormal = selecteddocTypeValue == 'normal';
                    print('isLME $isLME');
                    print('isFinalDoc $isFinalDoc');
                    print('isProvisionalDoc $isProvisionalDoc');
                    print('isNormal $isNormal');

                    return Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: Key(index == expandedIndex
                            ? 'expanded_$index'
                            : 'collapsed_$index'),
                        initiallyExpanded: expandedIndex == index,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            expandedIndex = expanded ? index : null;
                          });
                        },
                        backgroundColor: Colors.white,
                        title: Text(
                          "${selectedPendingItems[index].itemCode}- ${selectedPendingItems[index].itemName} - Qty ${selectedPendingItems[index].quantity}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        children: [
                          Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: AppUtils.buildNormalText(
                                              text: "Invoice Type")),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          flex: 3,
                                          child: AppUtils.buildNormalText(
                                              text: "Doc Type")),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: DropdownSearch<
                                            MapEntry<String, String>>(
                                          enabled: true,
                                          selectedItem: selectedinvoiceType,
                                          items: invoiceType.entries.toList(),
                                          itemAsString: (entry) => entry.value,
                                          onChanged: (entry) {
                                            if (entry != null) {
                                              setState(() {
                                                selectedPendingItems[index]
                                                    .invoiceType = entry.key;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 5,
                                        child: DropdownSearch<
                                            MapEntry<String, String>>(
                                          enabled: true,
                                          selectedItem: selecteddocType,
                                          items: docType.entries.toList(),
                                          itemAsString: (entry) => entry.value,
                                          onChanged: (entry) {
                                            if (entry != null) {
                                              setState(() {
                                                selecteddocType = entry;
                                                selectedPendingItems[index]
                                                    .documentType = entry.key;
                                              });
                                            }
                                          },
                                          popupProps: const PopupProps.menu(
                                              showSearchBox: true),
                                          dropdownDecoratorProps:
                                              const DropDownDecoratorProps(
                                            dropdownSearchDecoration:
                                                InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5),
                                  AppUtils.buildNormalText(text: "Item Name"),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    initialValue:
                                        selectedPendingItems[index].itemName ??
                                            '',
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Expanded(
                                        flex: 5,
                                        child: AppUtils.buildNormalText(
                                            text: "Qty")),
                                    Expanded(
                                        flex: 5,
                                        child: AppUtils.buildNormalText(
                                            text: "Unit Price")),
                                  ]),
                                  const SizedBox(height: 5),
                                  Row(children: [
                                    Expanded(
                                      flex: 5,
                                      child: TextFormField(
                                        initialValue:
                                            selectedPendingItems[index]
                                                .quantity
                                                .toString(),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                            decimal: true, signed: false),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$'))
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPendingItems[index]
                                                    .quantity =
                                                double.tryParse(value) ?? 0.0;
                                            selectedPendingItems[index].total =
                                                selectedPendingItems[index]
                                                        .quantity *
                                                    selectedPendingItems[index]
                                                        .unitPrice;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder()),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 5,
                                      child: TextFormField(
                                        initialValue:
                                            selectedPendingItems[index]
                                                .unitPrice
                                                .toString(),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                            decimal: true, signed: false),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$'))
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPendingItems[index]
                                                    .unitPrice =
                                                double.tryParse(value) ?? 0.0;
                                            selectedPendingItems[index].total =
                                                selectedPendingItems[index]
                                                        .quantity *
                                                    selectedPendingItems[index]
                                                        .unitPrice;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder()),
                                      ),
                                    ),
                                  ]),

                                  const SizedBox(height: 10),
                                  AppUtils.buildNormalText(
                                      text: "Control Price"),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    readOnly: true,
                                    initialValue: selectedPendingItems[index]
                                        .controlPrice
                                        .toString(),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Expanded(
                                        flex: 3,
                                        child: AppUtils.buildNormalText(
                                            text: "PO Num")),
                                    Expanded(
                                        flex: 3,
                                        child: AppUtils.buildNormalText(
                                            text: "PO Line")),
                                  ]),
                                  const SizedBox(height: 5),
                                  Row(children: [
                                    Expanded(
                                      flex: 3,
                                      child: DropdownSearch<PoModel>(
                                        key: poKey,
                                        selectedItem: selectedPo,
                                        asyncItems: (filter) =>
                                            ApiService.getpolists(
                                          Prefs.getDBName('DBName'),
                                          Prefs.getBranchID('BranchID'),
                                          getsupplierId,
                                          filter: filter,
                                        ),
                                        itemAsString: (item) =>
                                            item.poNumber.toString(),
                                        onChanged: (item) {
                                          if (item != null) {
                                            setState(() {
                                              selectedPendingItems[index]
                                                      .poNumber =
                                                  item.poNumber.toString();
                                              selectedPendingItems[index]
                                                      .pOEntry =
                                                  item.poEntry.toString();
                                              selectedPendingItems[index]
                                                      .poLine =
                                                  item.poLine!.toInt();
                                            });
                                          }
                                        },
                                        dropdownDecoratorProps:
                                            DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 3,
                                      child: DropdownSearch<PoLineModel>(
                                        key: poLineKey,
                                        selectedItem: selectedpoLine,
                                        asyncItems: (filter) =>
                                            ApiService.getpolinenumber(
                                          Prefs.getDBName('DBName'),
                                          Prefs.getBranchID('BranchID'),
                                          getsupplierId,
                                          filter: filter,
                                          selectedPendingItems[index].pOEntry,
                                        ),
                                        itemAsString: (item) =>
                                            item.value.toString(),
                                        dropdownDecoratorProps:
                                            DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        onChanged: (item) {
                                          setState(() {
                                            selectedpoLine = item;
                                          });
                                        },
                                      ),
                                    ),
                                  ]),

                                  const SizedBox(height: 10),
                                  AppUtils.buildNormalText(text: "Total"),
                                  TextFormField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                      text: selectedPendingItems[index]
                                          .total
                                          .toStringAsFixed(2),
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),

                                  // 🔥 Conditional LME Fields
                                  if (isLME && isFinalDoc) ...[
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: AppUtils.buildNormalText(
                                              text: "LME Level %")),
                                      Expanded(
                                          flex: 3,
                                          child: AppUtils.buildNormalText(
                                              text: "Control %")),
                                    ]),
                                    const SizedBox(height: 5),
                                    Row(children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          initialValue:
                                              selectedPendingItems[index]
                                                  .lMELevelFormula
                                                  .toString(),
                                          onChanged: (value) {
                                            selectedPendingItems[index]
                                                    .lMELevelFormula =
                                                double.tryParse(value) ?? 0.0;
                                          },
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          readOnly: true,
                                          initialValue:
                                              selectedPendingItems[index]
                                                  .controlPercentage
                                                  .toString(),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      Expanded(
                                          flex: 4,
                                          child: AppUtils.buildNormalText(
                                              text: "LME Amount")),
                                      Expanded(
                                          flex: 3,
                                          child: AppUtils.buildNormalText(
                                              text: "LME Fix Date")),
                                      Expanded(
                                          flex: 3,
                                          child: AppUtils.buildNormalText(
                                              text: "Contango Amt")),
                                    ]),
                                    const SizedBox(height: 5),
                                    Row(children: [
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          initialValue:
                                              selectedPendingItems[index]
                                                  .lMEAmount
                                                  .toString(),
                                          onChanged: (value) {
                                            selectedPendingItems[index]
                                                    .lMEAmount =
                                                double.tryParse(value) ?? 0.0;
                                          },
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: TextEditingController(
                                            text: selectedPendingItems[index]
                                                    .lMEFixationDate ??
                                                '',
                                          ),
                                          onTap: () => _selectDate(index),
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          initialValue:
                                              selectedPendingItems[index]
                                                  .contango
                                                  .toString(),
                                          onChanged: (value) {
                                            selectedPendingItems[index]
                                                    .contango =
                                                int.tryParse(value) ?? 0;
                                          },
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    AppUtils.buildNormalText(
                                        text: "Hedging Required"),
                                    DropdownSearch<MapEntry<String, String>>(
                                      selectedItem:
                                          headingType.entries.firstWhere(
                                        (entry) =>
                                            entry.key.toUpperCase() ==
                                            (selectedPendingItems[index]
                                                        .hedgingRequired ??
                                                    '')
                                                .toUpperCase(),
                                        orElse: () => const MapEntry("N", "No"),
                                      ),
                                      items: headingType.entries.toList(),
                                      itemAsString: (entry) => entry.value,
                                      onChanged: (entry) {
                                        if (entry != null) {
                                          setState(() {
                                            selectedPendingItems[index]
                                                .hedgingRequired = entry.key;
                                          });
                                        }
                                      },
                                    ),
                                  ] else if (isLME && isProvisionalDoc) ...[
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: AppUtils.buildNormalText(
                                              text: "LME Level %")),
                                      Expanded(
                                          flex: 3,
                                          child: AppUtils.buildNormalText(
                                              text: "Control %")),
                                    ]),
                                    const SizedBox(height: 5),
                                    Row(children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          initialValue:
                                              selectedPendingItems[index]
                                                  .lMELevelFormula
                                                  .toString(),
                                          onChanged: (value) {
                                            selectedPendingItems[index]
                                                    .lMELevelFormula =
                                                double.tryParse(value) ?? 0.0;
                                          },
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          readOnly: true,
                                          initialValue:
                                              selectedPendingItems[index]
                                                  .controlPercentage
                                                  .toString(),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ],
                                  const SizedBox(height: 10),
                                  AppUtils.buildNormalText(
                                      text: "Hedging Required"),
                                  DropdownSearch<MapEntry<String, String>>(
                                    selectedItem:
                                        headingType.entries.firstWhere(
                                      (entry) =>
                                          entry.key.toUpperCase() ==
                                          (selectedPendingItems[index]
                                                      .hedgingRequired ??
                                                  '')
                                              .toUpperCase(),
                                      orElse: () => const MapEntry("N", "No"),
                                    ),
                                    items: headingType.entries.toList(),
                                    itemAsString: (entry) => entry.value,
                                    onChanged: (entry) {
                                      if (entry != null) {
                                        setState(() {
                                          selectedPendingItems[index]
                                              .hedgingRequired = entry.key;
                                        });
                                      }
                                    },
                                  ),
                                  AppUtils.buildNormalText(
                                      text: "Purchase Remarks"),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    initialValue: selectedPendingItems[index]
                                        .purchaseRemarks
                                        .toString(),
                                    onChanged: (value) {
                                      selectedPendingItems[index]
                                          .purchaseRemarks = value;
                                    },
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const Center(child: Text("No items found")),
        ],
      ),
    );
  }

  Widget _buildLMEPercentageSection(int index) {
    final item = selectedPendingItems[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
              flex: 3, child: AppUtils.buildNormalText(text: "LME Level %")),
          Expanded(flex: 3, child: AppUtils.buildNormalText(text: "Control %")),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: item.lMELevelFormula.toString(),
              onChanged: (value) {
                item.lMELevelFormula = double.tryParse(value) ?? 0.0;
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 3,
            child: TextFormField(
              readOnly: true,
              initialValue: item.controlPercentage.toString(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildLMEAmountSection(int index) {
    final item = selectedPendingItems[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
              flex: 4, child: AppUtils.buildNormalText(text: "LME Amount")),
          Expanded(
              flex: 3, child: AppUtils.buildNormalText(text: "LME Fix Date")),
          Expanded(
              flex: 3, child: AppUtils.buildNormalText(text: "Contango Amt")),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          Expanded(
            flex: 4,
            child: TextFormField(
              initialValue: item.lMEAmount.toString(),
              onChanged: (value) {
                item.lMEAmount = double.tryParse(value) ?? 0.0;
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 3,
            child: TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: item.lMEFixationDate ?? '',
              ),
              onTap: () => _selectDate(index),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: item.contango.toString(),
              onChanged: (value) {
                item.contango = int.tryParse(value) ?? 0;
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildHedgingDropdown(int index) {
    final item = selectedPendingItems[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        AppUtils.buildNormalText(text: "Hedging Required"),
        DropdownSearch<MapEntry<String, String>>(
          selectedItem: headingType.entries.firstWhere(
            (entry) =>
                entry.key.toUpperCase() ==
                (item.hedgingRequired ?? '').toUpperCase(),
            orElse: () => const MapEntry("N", "No"),
          ),
          items: headingType.entries.toList(),
          itemAsString: (entry) => entry.value,
          onChanged: (entry) {
            if (entry != null) {
              setState(() {
                item.hedgingRequired = entry.key;
              });
            }
          },
        ),
      ],
    );
  }

  void pickerfromdate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), //.add(Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyyMMdd').format(pickedDate);

      var dateFormate =
          DateFormat("dd/MM/yyyy").format(DateTime.parse(formattedDate));

      setState(() {
        weightfromdatecontroller.text = dateFormate;
        alterweightfromdatecontroller.text = formattedDate;
      });
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
      String formattedDate = DateFormat('yyyyMMdd').format(pickedDate);

      var dateFormate =
          DateFormat("dd/MM/yyyy").format(DateTime.parse(formattedDate));

      setState(() {
        weighttodatecontroller.text = dateFormate;
        alterweighttodatecontroller.text = formattedDate;
      });
    }
  }

  void postitems() async {
    setState(() {
      loading = true;
    });
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
    final map = <String, dynamic>{};

    List<Map<String, dynamic>> dataToSend = [];

    dataToSend.clear();
    for (int i = 0; i < selectedPendingItems.length; i++) {
      dataToSend.add({
        // "docEntry": widget.status == "Open" ? "" : widget.docEntry,
        "docEntry": widget.docEntry,
        "lineId": i + 1,
        "itemCode": selectedPendingItems[i].itemCode,
        "itemName": selectedPendingItems[i].itemName,
        "whsCode": getwhsCode,
        "quantity": selectedPendingItems[i].quantity,
        "lmeFactor": "",
        "hedgableQty": "",
        "ratePerMT": "",
        "lmeLevel": "",
        "contango": selectedPendingItems[i].contango,
        "lmeFormula": selectedPendingItems[i].lMELevelFormula,
        "invType": selectedPendingItems[i].invoiceType,
        "total": selectedPendingItems[i].total,
        "remarks": "",
        "lmeForml": "",
        "lmeAmt": selectedPendingItems[i].lMEAmount,
        "lmeDate": selectedPendingItems[i].lMEFixationDate,
        "docType": selectedPendingItems[i].documentType,
        "wtsNo": "",
        "weigNum": "",
        "unitPrice": selectedPendingItems[i].unitPrice,
        "poNum": selectedPendingItems[i].poNumber,
        "poEntry": selectedPendingItems[i].pOEntry ?? "0",
        "purRemark": selectedPendingItems[i].purchaseRemarks,
        "controlPirce": selectedPendingItems[i].controlPrice,
        "controlPrcnt": selectedPendingItems[i].controlPercentage,
        "createdBy": Prefs.getEmpID("Id")
      });
    }

    map['docEntry'] = widget.docEntry;
    map['createDate'] = today;
    map['createTime'] = "";
    map['device'] = "Mobile";
    map['files'] = '';
    map['remark'] = "";
    map['cardCode'] = getsalespersonCode;
    map['cardName'] = getsupplierName;
    map['wightFromDate'] = weightfromdatecontroller.text;
    map['wightToDate'] = weighttodatecontroller.text;
    map['wightNos'] = "";
    map['vehicleNo'] = pickupNoController.text;
    map['yard'] = getyardId;
    map['docDate'] = today;
    map['docType'] = "Inbound";
    map['taxGroup'] = " VAT5%";
    map['driverName'] = "";
    map['dMobileNo'] = "";
    map['slpCode'] = getsalespersonCode;
    map['slpName'] = getsalespersonName;
    map['agentCode'] = getAgentCode;
    map['postGRN'] = selectedGrn!.key;
    map['supervisor'] = "";
    map['status'] = "Close";
    map['projCode'] = getprojectId;
    map['items'] = dataToSend;
    map['createdBy'] = Prefs.getEmpID("Id");
    map['user2'] = Prefs.getEmpID("Id");
    map['PriceStatus'] = value1 == true ? "Close" : "Open";
    map['weighLocation'] = getwaybridgeCode;
    map['whsCode'] = getwhsCode;
    map['formName'] = "pricelistupdate";

    log((jsonEncode(dataToSend)));

    apiService
        .postrequestunloading(
            map,
            _images,
            dataToSend,
            Prefs.getDBName('DBName').toString(),
            Prefs.getBranchID('BranchID'),
            "yardunloading",
            _removedURL,
            selectedImageList)
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

  void editUnloading() {
    editYarnList.clear();
    setState(() {
      loading = true;
    });
    apiService
        .editunloadingall(
            Prefs.getDBName('DBName').toString(),
            Prefs.getBranchID('BranchID').toString(),
            widget.docEntry.toString(),
            "yardunloading")
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'].toString() == "true") {
          editYarnList = (jsonResponse['result'] as List)
              .map((item) => EditUnloadModel.fromJson(item))
              .toList();

          if (editYarnList.isNotEmpty) {
            getsupplierId = editYarnList[0].cardCode.toString();
            getsupplierName = editYarnList[0].customerName.toString();

            pickupNoController.text = editYarnList[0].vechileNo.toString();
            weightfromdatecontroller.text =
                editYarnList[0].wightFromDate.toString();
            weighttodatecontroller.text =
                editYarnList[0].wightToDate.toString();

            alterweightfromdatecontroller.text =
                editYarnList[0].wightFromDate.toString();
            alterweighttodatecontroller.text =
                editYarnList[0].wightToDate.toString();

            getsalespersonCode = editYarnList[0].slpCode.toString();
            getsalespersonName = editYarnList[0].slpName.toString();

            selectedSupplier =
                SuppplierModel(id: getsupplierId, value: getsupplierName);

            getprojectId = editYarnList[0].projCode.toString();
            getprojectName = editYarnList[0].projName.toString();

            selectedProject =
                ProjectModel(id: getprojectId, value: getprojectName);

            getyardId = editYarnList[0].yard.toString();
            getyardName = editYarnList[0].yardName.toString();
            selectedYard = YardModel(id: getyardId, value: getyardName);

            getAgentCode = editYarnList[0].agentCode.toString();
            getAgentName = editYarnList[0].agentName.toString();

            selectedAgent = AgentModel(id: getAgentCode, value: getAgentName);

            getwhsCode = editYarnList[0].warehouse.toString();
            getWhsName = editYarnList[0].warehouseName.toString();

            selectedWhs = WarehouseModel(id: getwhsCode, value: getWhsName);

            poNumcontroller.text = editYarnList[0].pONum.toString();
            poentryController.text = editYarnList[0].pOEntry.toString();

            weightfromdatecontroller.text =
                editYarnList[0].wightFromDate.toString();

            weighttodatecontroller.text =
                editYarnList[0].wightToDate.toString();

            alterweightfromdatecontroller.text =
                editYarnList[0].wightFromDate.toString();

            alterweighttodatecontroller.text =
                editYarnList[0].wightToDate.toString();

            getsalespersonCode = editYarnList[0].slpCode.toString();
            getsalespersonName = editYarnList[0].slpName.toString();

            selectedpoLine = PoLineModel(
                id: editYarnList[0].poLine ?? 0,
                value: editYarnList[0].poLine ?? 0);

            selectedPo = PoModel(
                poEntry: editYarnList[0].pOEntry.toString(),
                poNumber: editYarnList[0].pONum.toString(),
                poLine: editYarnList[0].poLine ?? 0);
            selectedSales = SalesPersonModel(
                id: getsalespersonCode.toString(), value: getsalespersonName);

            getwaybridgeCode = editYarnList[0].weighLocation.toString();
            getwaybridgeName = editYarnList[0].weighLocation.toString();
            selectedWaybridge = WeighLocationModel(
                id: getwaybridgeCode, value: getwaybridgeName);

            selectedAgent = AgentModel(id: getAgentCode, value: getAgentName);

            updateGrnSelection(editYarnList[0].postGRN);

            selectedPendingItems = editYarnList
                .map((item) => PendingItem(
                    invoiceType: item.invoiceType,
                    documentType: item.documentType,
                    wgId: 0,
                    ticketNo: "",
                    trnDate: "",
                    customerName: item.customerName,
                    itemCode: item.itemCode,
                    itemName: item.itemName,
                    warehouse: item.warehouse,
                    warehousename: item.warehousename,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    controlPrice: item.controlPirce,
                    lMELevelFormula: item.lmeLevelFormula,
                    controlPercentage: item.controlPrcentage.toString(),
                    lMEAmount: item.lmeAmount,
                    contango: item.contango.toInt(),
                    hedgingRequired: item.hedginRequied,
                    poNumber: item.pONum,
                    pOEntry: item.pOEntry.toString(),
                    poLine: item.poLine ?? 0,
                    purchaseRemarks: item.purchaseRemark,
                    total: item.total,
                    slpCode: item.slpCode,
                    slpName: item.slpName,
                    lMEFixationDate: item.lmeFixationDate,
                    ismanuall: false,
                    baseLine: item.baseLine ?? 0))
                .toList();
            setState(() {});
          }
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

  void updateGrnSelection(String value) {
    selectedGrn = grnList.firstWhere(
      (entry) {
        final match = entry.key == value;
        if (match) {}
        return match;
      },
      orElse: () => const MapEntry("N", "No"),
    );
  }

  Future<void> _selectDate(int index) async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      String formatted = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        selectedPendingItems[index].lMEFixationDate = formatted;
      });
    }
  }

  String convertDate(String inputDate) {
    // Parse the input date
    DateTime date = DateFormat('ddMM/yyyy').parse(inputDate);

    // Format as yyyyMMdd
    String formatted = DateFormat('yyyyMMdd').format(date);

    return formatted;
  }

  void onrefresh() {
    AppUtils.pop(context);
    AppUtils.pop(context);
    AppUtils.pop(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const PendingPriceList()));
  }

  void onexitpopup() {
    AppUtils.pop(context);
  }
}

Widget customExpansionTile(
    context, text, initiallyExpanded, leading, childern) {
  return GestureDetector(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      // height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0XFF6e6b7b)),
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          text,
          style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color(0xff5344ed)),
        ),
        initiallyExpanded: initiallyExpanded,
        leading: leading,
        children: childern,
      ),
    ),
  );
}
