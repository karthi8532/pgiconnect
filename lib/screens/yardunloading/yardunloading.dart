import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/agentmodel.dart';
import 'package:pgiconnect/model/editunloadmodel.dart';
import 'package:pgiconnect/model/newItemModel.dart';
import 'package:pgiconnect/model/pendingunloaditemmodel.dart';
import 'package:pgiconnect/model/projectmodel%20copy.dart';
import 'package:pgiconnect/model/projectmodel.dart';
import 'package:pgiconnect/model/suplliermodel.dart';
import 'package:pgiconnect/model/unloadingheadermodel.dart';
import 'package:pgiconnect/model/warehousemodel.dart';
import 'package:pgiconnect/model/weighlocation.dart';
import 'package:pgiconnect/model/weighticketnumbermodel.dart';
import 'package:pgiconnect/model/yadmodel.dart';
import 'package:pgiconnect/screens/dashboard/approval/approvalsubmit.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/screens/yardunloading/pendingitem.dart';
import 'package:pgiconnect/screens/yardunloading/yardunloadingselectionlist.dart';
import 'package:pgiconnect/service/appcolor.dart';

class YardUnloadingPage extends StatefulWidget {
  int docEntry = 0;
  String status;
  YardUnloadingPage({super.key, required this.docEntry, required this.status});

  @override
  State<YardUnloadingPage> createState() => _YardUnloadingPageState();
}

class _YardUnloadingPageState extends State<YardUnloadingPage> {
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
  TextEditingController qtycontroller = TextEditingController();
  ApiService apiService = ApiService();
  bool loading = false;
  int? expandedIndex;

  final supplierKey = GlobalKey<DropdownSearchState<SuppplierModel>>();
  final weighticketKey =
      GlobalKey<DropdownSearchState<WeighTicketNumberModel>>();
  final agentKey = GlobalKey<DropdownSearchState<AgentModel>>();
  final projectkey = GlobalKey<DropdownSearchState<ProjectModel>>();
  final yardKey = GlobalKey<DropdownSearchState<YardModel>>();
  final whsKey = GlobalKey<DropdownSearchState<WarehouseModel>>();
  final salesKey = GlobalKey<DropdownSearchState<SalesPersonModel>>();
  final whsKey1 = GlobalKey<DropdownSearchState<WarehouseModel>>();
  final weighKey = GlobalKey<DropdownSearchState<WeighLocationModel>>();

  final selectItemkey = GlobalKey<DropdownSearchState<NewItemModel>>();

  String getsupplierId = '';
  String getsupplierName = '';
  String alterItemCode = '';
  String alterItemName = '';

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

  List<UnloadingHeaderModel> headerlist = [];
  Map<String, String> invoiceType = {"LME": "LME", "Normal": "Normal"};

  Map<String, String> docType = {
    "Provisional": "Provisional",
    "Final": "Final"
  };

  MapEntry<String, String>? selectedinvoiceType;
  MapEntry<String, String>? selecteddocType;
  List<WarehouseModel> selectedwarehouse = [];
  List<EditUnloadModel> editYarnList = [];

  SuppplierModel? selectedSupplier;

  ProjectModel? selectedProject;
  YardModel? selectedYard;
  AgentModel? selectedAgent;
  WarehouseModel? selectedWhs;
  SalesPersonModel? selectedSales;
  WeighLocationModel? selectedWaybridge;
  WeighTicketNumberModel? selectedWayTicketno;

  final List<File> _images = [];
  final List<File> _editimages = [];
  final List<String> _removedURL = [];

  final Set<File> _selectedImages = {};

  final ImagePicker _picker = ImagePicker();

  bool value1 = false;
  String getGrnCode = "";
  MapEntry<String, String>? selectedGrn;

  List<MapEntry<String, String>> grnList = [
    const MapEntry("Y", "Yes"),
    const MapEntry("N", "No"),
  ];

  String getTicketNo = "";
  @override
  void initState() {
    print(widget.status);
    // if (widget.status == "Open") {
    //   editUnloading();
    // } else {
    //   editUnloading();
    // }
    if (widget.docEntry == 0) {
      getwaybridgeCode = Prefs.getWeighLocationID("WeighLocationID") ?? "";
      getwaybridgeName = Prefs.getWeighLocationName("WeighLocationName") ?? "";

      selectedWaybridge =
          WeighLocationModel(id: getwaybridgeCode, value: getwaybridgeName);
      setState(() {});
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
    qtycontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Appcolor.primary,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yard Unloading'),
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
                        Tab(
                          text: "Attachment",
                        )
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: ScrollPhysics(),
                        children: [
                          headerwidgets(),
                          itemsswidgets(),
                          Column(
                            children: [
                              widget.status == "Open"
                                  ? _buildUploadSection()
                                  : _buildUploadSection(),
                              _buildEditimageUploadSection()
                            ],
                          )
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
            SizedBox(
              height: 5,
            ),
            AppUtils.buildNormalText(text: "Weighbridge Location"),
            SizedBox(
              height: 5,
            ),
            DropdownSearch<WeighLocationModel>(
              selectedItem: selectedWaybridge,
              key: weighKey,
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
                        weighKey.currentState?.popupValidate([item]);
                        getwaybridgeCode = item.id.toString();
                        getwaybridgeName = item.value.toString();
                        setState(() {});
                      });
                },
              ),
              asyncItems: (String filter) => ApiService.getwaybridgelocation(
                Prefs.getDBName('DBName'),
                Prefs.getBranchID('BranchID'),
                filter: filter,
              ),
              itemAsString: (WeighLocationModel item) => item.value.toString(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(5.0, 10, 5.0, 2),
                  hintText: '',
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
            AppUtils.buildNormalText(text: "Weighbridge  Ticket No."),
            SizedBox(height: 5),
            DropdownSearch<WeighTicketNumberModel>(
              selectedItem: selectedWayTicketno,
              key: weighticketKey,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                interceptCallBacks: true, //important line
                itemBuilder: (ctx, item, isSelected) {
                  return ListTile(
                      selected: isSelected,
                      title: Text(
                        item.weighTicketNo.toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        weighticketKey.currentState?.popupValidate([item]);
                        getTicketNo = item.weighTicketNo.toString();
                        selectedWayTicketno = WeighTicketNumberModel(
                            weighTicketNo: item.weighTicketNo.toString());
                        getheader();
                      });
                },
              ),
              asyncItems: (String filter) => ApiService.getwayticketList(
                Prefs.getDBName('DBName'),
                Prefs.getBranchID('BranchID'),
                getwaybridgeCode,
                filter: filter,
              ),
              itemAsString: (WeighTicketNumberModel item) =>
                  item.weighTicketNo.toString(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  hintText: 'Weigh Ticket No * ',
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
            SizedBox(height: 10),
            widget.status == "Close"
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (getwaybridgeCode.isEmpty) {
                              AppUtils.showSingleDialogPopup(
                                  context,
                                  "Please Enter Weight Location",
                                  "Ok",
                                  exitpopup,
                                  null);
                            } /*else if (selectedSupplier!.id!.isEmpty) {
                              AppUtils.showSingleDialogPopup(
                                  context,
                                  "Please Select Supplier",
                                  "Ok",
                                  exitpopup,
                                  null);
                            } */
                            else if (pickupNoController.text.isEmpty) {
                              AppUtils.showSingleDialogPopup(
                                  context,
                                  "Please Enter Pickup No",
                                  "Ok",
                                  exitpopup,
                                  null);
                            } else if (getTicketNo.isEmpty) {
                              AppUtils.showSingleDialogPopup(
                                  context,
                                  "Please Select Ticket No",
                                  "Ok",
                                  exitpopup,
                                  null);
                            } else {
                              callgetitemlist(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 4.0,
                          ),
                          child: Text(
                            'Select Ticket',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
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
                        selectedSupplier = SuppplierModel(
                            id: getsupplierId, value: getsupplierName);
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
            SizedBox(
              height: 10,
            ),
            AppUtils.buildNormalText(text: "Vehicle No"),
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
            SizedBox(
              height: 10,
            ),
            AppUtils.buildNormalText(text: "Project"),
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
            SizedBox(
              height: 5,
            ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Attachment",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._images.map((file) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: IconButton(
                        icon: const Icon(Icons.cancel,
                            color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedImages.remove(file);
                            _images.remove(file);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }),
              GestureDetector(
                onTap: () {
                  AppUtils.showBottomCupertinoDialog(
                    context,
                    title: "Attach Image",
                    btn1function: () {
                      AppUtils.pop(context);
                      _cameraImage();
                    },
                    btn2function: () {
                      AppUtils.pop(context);
                      _pickImage();
                    },
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 30, color: Colors.black54),
                      SizedBox(height: 5),
                      Text("Upload", style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditimageUploadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._editimages.map((file) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(file.path
                              .toString()
                              .replaceAll('"', '')), //double quoates remove
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedImages.remove(file);
                            _removedURL.add(file.path);
                            _editimages.remove(file);
                          });
                        },
                      ),
                    )
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _cameraImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<void> _pickImage() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      setState(() {
        _images.addAll(selectedImages.map((xfile) => File(xfile.path)));
      });
    }
  }

  void getheader() async {
    setState(() {
      loading = true;
    });

    apiService
        .getheader(Prefs.getDBName('DBName'), Prefs.getBranchID('BranchID'),
            getTicketNo)
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        if (jsonDecode(response.body)['success'].toString() == "true") {
          final body = jsonDecode(response.body);
          final result = body['result'];

          if (result != null && result is List) {
            headerlist = result
                .map<UnloadingHeaderModel>(
                    (item) => UnloadingHeaderModel.fromJson(item))
                .toList();
            setState(() {
              pickupNoController.text =
                  headerlist.first.vehicleNumber.toString();

              getprojectId = headerlist.first.project.toString();
              getprojectName = headerlist.first.project.toString();

              selectedProject =
                  ProjectModel(id: getprojectId, value: getprojectName);

              getsupplierId = headerlist.first.cardCode.toString();
              getsupplierName = headerlist.first.cardName.toString();

              selectedSupplier =
                  SuppplierModel(id: getsupplierId, value: getsupplierName);

              getsalespersonCode = headerlist.first.salesPersonCode.toString();
              getsalespersonName = headerlist.first.salesPersonName.toString();

              selectedSales = SalesPersonModel(
                  id: getsalespersonCode, value: getsalespersonName);

              getyardId = headerlist.first.yardId.toString();
              getyardName = headerlist.first.yardName.toString();

              selectedYard = YardModel(id: getyardId, value: getyardName);

              getwhsCode = headerlist.first.whsCode.toString();
              getWhsName = headerlist.first.whsCode.toString();
              selectedWhs = WarehouseModel(id: getwhsCode, value: getWhsName);
            });
          }
        } else {
          headerlist.clear();
        }
      } else {
        AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'].toString(),
            "Ok",
            exitpopup,
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
          ticketNo: getTicketNo,
        ),
      ),
    );

    if (result != null && result['selectedItems'] != null) {
      final List<PendingItem> newItems =
          List<PendingItem>.from(result['selectedItems']);

      setState(() {
        for (var newItem in newItems) {
          final isDuplicate = selectedPendingItems
              .any((existingItem) => existingItem.itemCode == newItem.itemCode);

          if (!isDuplicate) {
            selectedPendingItems.add(newItem);

            final String whsCode = newItem.warehouse;
            final String whsName = newItem.warehousename;
            selectedWhs = WarehouseModel(id: whsCode, value: whsName);
          }
        }
      });
    }
  }

  void addManualItem() {
    setState(() {
      selectedinvoiceType = const MapEntry("LME", "LME");
      selecteddocType = const MapEntry("Provisional", "Provisional");
      selectedPendingItems.add(
        PendingItem(
            invoiceType: "LME",
            documentType: "Provisional",
            wgId: 0,
            ticketNo: getTicketNo,
            trnDate: "",
            customerName: "",
            itemCode: alterItemCode,
            itemName: alterItemName,
            warehouse: "",
            warehousename: "",
            quantity: 1,
            unitPrice: 0,
            controlPrice: 0,
            lMELevelFormula: 0,
            controlPercentage: "",
            lMEAmount: 0,
            contango: 0,
            hedgingRequired: "",
            poNumber: "",
            pOEntry: "",
            poLine: 0,
            purchaseRemarks: "",
            total: 0,
            slpCode: "",
            slpName: "",
            lMEFixationDate: "",
            ismanuall: true),
      );
      alterItemCode = "";
      alterItemName = "";
      qtycontroller.text = "";
      qtycontroller.clear();
    });
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

  Widget itemsswidgets() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          selectedPendingItems.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
                      // If not found, assign default
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
                            entry.key ==
                            selectedPendingItems[index].invoiceType,
                      );
                    } catch (e) {
                      // If not found, assign default
                      selectedinvoiceType = const MapEntry("LME", "LME");
                      selectedPendingItems[index].invoiceType = "LME";
                    }
                    return Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: Key(index ==
                                expandedIndex // different key when state changes forces rebuild
                            ? 'expanded_$index'
                            : 'collapsed_$index'),
                        initiallyExpanded: expandedIndex == index,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            expandedIndex = expanded ? index : null;
                          });
                        },
                        backgroundColor: Colors.white,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${selectedPendingItems[index].itemCode}- ${selectedPendingItems[index].itemName}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            selectedPendingItems[index].ismanuall
                                ? SizedBox(
                                    width: 40,
                                    child: IconButton(
                                        onPressed: () {
                                          AppUtils.showconfirmDialog(
                                              context,
                                              "Are you sure want to delete this item?",
                                              "Yes",
                                              "No", () {
                                            AppUtils.pop(context);
                                            selectedPendingItems
                                                .removeAt(index);
                                            setState(() {});
                                          }, () {
                                            AppUtils.pop(context);
                                          });
                                        },
                                        icon: Icon(
                                          size: 20,
                                          Icons.delete,
                                          color: Colors.red,
                                        )))
                                : Container(),
                          ],
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
                                            text: "Invoice Type"),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 3,
                                        child: AppUtils.buildNormalText(
                                            text: "Doc Type"),
                                      ),
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
                                            itemAsString: (entry) =>
                                                entry.value,
                                            onChanged: (entry) {
                                              if (entry != null) {
                                                setState(() {
                                                  selectedPendingItems[index]
                                                      .invoiceType = entry.key;
                                                });
                                              }
                                            },
                                          )),
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
                                          popupProps: PopupProps.menu(
                                              showSearchBox: true),
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
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  AppUtils.buildNormalText(text: "Item Name"),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    initialValue:
                                        selectedPendingItems[index].itemName ??
                                            '',
                                    enabled: true,
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
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: AppUtils.buildNormalText(
                                            text: "Ware House"),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 3,
                                        child: AppUtils.buildNormalText(
                                            text: "Qty"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: DropdownSearch<WarehouseModel>(
                                          key: whsKey1,
                                          selectedItem: selectedWhs,
                                          popupProps: PopupProps.menu(
                                            showSearchBox: true,
                                            interceptCallBacks:
                                                true, //important line
                                            itemBuilder:
                                                (ctx, item, isSelected) {
                                              return ListTile(
                                                  selected: isSelected,
                                                  title: Text(
                                                    item.value.toString(),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    whsKey1.currentState
                                                        ?.popupValidate([item]);
                                                    selectedPendingItems[index]
                                                            .warehouse =
                                                        item.id.toString();
                                                    getwhsCode =
                                                        item.id.toString();
                                                    getWhsName =
                                                        item.value.toString();
                                                    setState(() {});
                                                  });
                                            },
                                          ),
                                          asyncItems: (String filter) =>
                                              ApiService.getwarehouselist(
                                            Prefs.getDBName('DBName'),
                                            Prefs.getBranchID('BranchID'),
                                            filter: filter,
                                          ),
                                          itemAsString: (WarehouseModel item) =>
                                              item.value.toString(),
                                          dropdownDecoratorProps:
                                              DropDownDecoratorProps(
                                            dropdownSearchDecoration:
                                                InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      20.0, 10.0, 20.0, 10.0),
                                              hintText: 'WareHouse * ',
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                                borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                                borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        flex: 5,
                                        child: TextFormField(
                                          initialValue:
                                              selectedPendingItems[index]
                                                  .quantity
                                                  .toString(),
                                          onChanged: (value) => {
                                            // Update the quantity in the item
                                            selectedPendingItems[index]
                                                    .quantity =
                                                double.tryParse(value) ?? 0.0
                                          },
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 8),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 1,
                                                        color: Colors.grey)),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black26,
                                                  width: 1),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black26,
                                                  width: 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
              : Center(
                  child: Text("No Data!"),
                ),
          SizedBox(
            height: 10,
          ),
          ExpansionTile(
            backgroundColor: Colors.white30,
            title: Text("ADD ITEM"),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownSearch<NewItemModel>(
                  key: selectItemkey,
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    interceptCallBacks: true, //important line
                    itemBuilder: (ctx, item, isSelected) {
                      return ListTile(
                          selected: isSelected,
                          title: Text(
                            item.itemName.toString(),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            selectItemkey.currentState?.popupValidate([item]);
                            alterItemCode = item.itemCode.toString();
                            alterItemName = item.itemName.toString();
                            setState(() {});
                          });
                    },
                  ),
                  asyncItems: (String filter) => ApiService.getnewItem(
                    Prefs.getDBName('DBName'),
                    Prefs.getBranchID('BranchID'),
                    getTicketNo,
                    filter: filter,
                  ),
                  itemAsString: (NewItemModel item) => item.itemName.toString(),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(5.0, 10, 5.0, 2),
                      hintText: 'Item',
                      label: Text("Item"),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        maxLines: 1,
                        controller: qtycontroller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,3}')),
                        ],
                        onChanged: (val) => {},
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
                          hintText: "Qty",
                          label: Text("Qty"),
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
                        flex: 2,
                        child: ElevatedButton(
                            onPressed: () {
                              if (alterItemCode.isEmpty) {
                                AppUtils.showSingleDialogPopup(
                                    context,
                                    "Please Choose Item",
                                    "OK",
                                    onexitpopup,
                                    null);
                              } else if (qtycontroller.text.isEmpty) {
                                AppUtils.showSingleDialogPopup(
                                    context,
                                    "Please Enter Qty",
                                    "OK",
                                    onexitpopup,
                                    null);
                              } else {
                                addManualItem();
                              }
                            },
                            child: Text("Add")))
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ],
      ),
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
    final List<File> selectedImageList = _selectedImages.toList();

    if (widget.status == "Pending") {
      if (_editimages.isNotEmpty) {
        _images.addAll(_editimages);
      }
    }
    dataToSend.clear();
    for (int i = 0; i < selectedPendingItems.length; i++) {
      dataToSend.add({
        "docEntry": widget.status == "Open" ? "" : widget.docEntry,
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
        "lmeFormula": "",
        "invType": selectedPendingItems[i].invoiceType,
        "total": selectedPendingItems[i].total,
        "remarks": "",
        "lmeForml": "",
        "lmeAmt": "",
        "lmeDate": "",
        "docType": selectedPendingItems[i].documentType,
        "wtsNo": "",
        "weigNum": selectedWayTicketno?.weighTicketNo ?? "",
        "poNum": "",
        "poEntry": "",
        "purRemark": "",
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
    map['wightNos'] = selectedWayTicketno?.weighTicketNo ?? "";
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
    map['postGRN'] = getGrnCode;
    map['supervisor'] = "";
    map['status'] = value1 == true ? "Close" : widget.status;
    map['projCode'] = getprojectId;
    map['items'] = dataToSend;
    map['createdBy'] = Prefs.getEmpID("Id");
    map['user2'] = Prefs.getEmpID("Id");
    map['PriceStatus'] = widget.status;
    map['weighLocation'] = getwaybridgeCode;
    map['whsCode'] = getwhsCode;

    //log((jsonEncode(dataToSend)));

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

            selectedSales = SalesPersonModel(
                id: getsalespersonCode.toString(), value: getsalespersonName);

            getwaybridgeCode = editYarnList[0].weighLocation.toString();
            getwaybridgeName = editYarnList[0].weighLocation.toString();

            selectedWayTicketno = WeighTicketNumberModel(
                weighTicketNo: editYarnList[0].wightNos.toString());

            selectedWaybridge = WeighLocationModel(
                id: getwaybridgeCode, value: getwaybridgeName);

            selectedAgent = AgentModel(id: getAgentCode, value: getAgentName);

            updateGrnSelection(editYarnList[0].postGRN);

            value1 = widget.status == "Close" ? true : false;

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
                    warehousename: item.warehouseName,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    controlPrice: item.controlPirce,
                    lMELevelFormula: 0.0,
                    controlPercentage: "0.0",
                    lMEAmount: item.lmeAmount,
                    contango: item.contango.toInt(),
                    hedgingRequired: item.hedginRequied,
                    poNumber: item.pONum,
                    pOEntry: item.pOEntry.toString(),
                    poLine: item.poLine ?? 0,
                    purchaseRemarks: "",
                    total: item.total,
                    slpCode: item.slpCode,
                    slpName: item.slpName,
                    lMEFixationDate: item.lmeFixationDate,
                    ismanuall: false))
                .toList();
            setState(() {});
          }

          if (editYarnList[0].attachmentPath.isNotEmpty) {
            for (var editimages in editYarnList[0].attachmentPath) {
              if ((editimages.filename ?? '').isNotEmpty &&
                  (editimages.url ?? '').isNotEmpty) {
                _editimages.add(File(editimages.url));
              }
            }
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
      (entry) => entry.key == value,
      orElse: () => const MapEntry("N", "No"),
    );
  }

  String convertDate(String inputDate) {
    // Parse the input date
    DateTime date = DateFormat('dd/MM/yyyy').parse(inputDate);

    // Format as yyyyMMdd
    String formatted = DateFormat('yyyyMMdd').format(date);

    return formatted;
  }

  void onrefresh() {
    AppUtils.pop(context);
    AppUtils.pop(context);
    AppUtils.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const YardUnloadingSelectionPage()));
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
