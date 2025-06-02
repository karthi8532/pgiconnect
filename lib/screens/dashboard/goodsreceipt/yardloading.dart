import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/editmodelyarnlist.dart';
import 'package:pgiconnect/screens/login/login/loginpage.dart';
import 'package:pgiconnect/screens/yarnselectionlist.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/screens/dashboard/goodsreceipt/productlist.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/widgets/customimagewithindicator.dart';

class YardLoading extends StatefulWidget {
  dynamic data;
  String status;
  YardLoading({super.key, required this.data, required this.status});

  @override
  _YardLoadingState createState() => _YardLoadingState();
}

class _YardLoadingState extends State<YardLoading> {
  bool exportInvoice = false;
  bool showDescription = false;
  bool roundOff = true;
  late List<PostItem> items = [];
  double totalQuantity = 0.00;
  double totalGrossWeight = 0.00;
  double totalDoQty = 0.00;
  double totalNetweight = 0.00;

  double totalpackweight = 0.00;
  double totalnoofpack = 0.0;

  String ticketcontroller = '';
  String customercontroller = '';
  String getcompanyname = '';
  String getDBName = '';
  String getbranchName = "";
  int getbranchId = 0;
  String getLogisticNo = "";
  String getLogisticID = "";
  final ImagePicker _picker = ImagePicker();
  bool loading = false;
  ApiService apiService = ApiService();

  TextEditingController containernumbercontroller = TextEditingController();
  List<YarnEditListModel> editmodel = [];

  final List<File> _images = [];
  final List<File> _editimages = [];
  final List<String> _removedURL = [];

  bool value1 = false;
  @override
  void initState() {
    if (widget.status == "Completed") {
      setState(() {
        value1 = true;
      });
    } else {
      setState(() {
        value1 = false;
      });
    }

    getcompanyname = Prefs.getDBName('DBName').toString();
    getbranchId = Prefs.getBranchID('BranchID')!;
    getbranchName = Prefs.getBranchName('BranchName').toString();
    getLogisticNo = widget.data['logisticRequestNo'].toString();
    getLogisticID = widget.data['logisticID'].toString();
    widget.data['isEditable'] == true ? getyarneditloadinglist() : "";

    if (widget.data['isEditable'] == true) {
      containernumbercontroller.text = widget.data['containerNo'];
    }
    super.initState();
  }

  @override
  void dispose() {
    containernumbercontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Appcolor.primary,
        title: AppUtils.buildNormalText(text: "Yard Loading", fontSize: 20),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
            label: Text(value1 == true ? "Close" : "Open"),
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
          )
        ],
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
                widget.data['isEditable'] == false
                    ? _buildUploadSection()
                    : _buildUploadSection(),
                _buildEditimageUploadSection()
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
                    Text(
                        "Qty: ${totalQuantity.toStringAsFixed(2)} / DO Qty: ${totalDoQty.toStringAsFixed(2)} / Gross wt : ${totalGrossWeight.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(
                        "Net wt : ${totalNetweight.toStringAsFixed(2)}/ Pack wt : ${totalpackweight.toStringAsFixed(2)} / No.of.pack : ${totalnoofpack.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              widget.status == "Completed"
                  ? Container()
                  : Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Appcolor.primary),
                        onPressed: () {
                          if (containernumbercontroller.text.isEmpty) {
                            AppUtils.showSingleDialogPopup(
                                context,
                                "Please Enter Container Number",
                                "Ok",
                                onexitpopup,
                                null);
                          } else if (items.isEmpty) {
                            AppUtils.showSingleDialogPopup(
                                context,
                                "Please make you item is empty",
                                "Ok",
                                onexitpopup,
                                null);
                          } else {
                            widget.data['isEditable'] == false
                                ? postItem()
                                : widget.status == "Completed"
                                    ? ""
                                    : updateYarnApi();
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                                widget.status == "Pending"
                                    ? "Create"
                                    : widget.status == "In Progress"
                                        ? "Update"
                                        : "",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
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

  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Attachment",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          ),
          SizedBox(height: 10),
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
                          image: FileImage(File(file.path)),
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
                            _images.remove(file);
                          });
                        },
                      ),
                    )
                  ],
                );
              }),
              if (_images.length < 5)
                GestureDetector(
                  onTap: () {
                    AppUtils.showBottomCupertinoDialog(context,
                        title: "Attach Image", btn1function: () {
                      AppUtils.pop(context);
                      _cameraImage();
                    }, btn2function: () {
                      AppUtils.pop(context);
                      _pickImage();
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
    if (image != null && _images.length < 5) {
      setState(() {
        _images.add(File(image.path));
      });
    } else if (_images.length >= 5) {
      AppUtils.showSingleDialogPopup(
        context,
        "Max. 5 attachments only allowed",
        "Ok",
        () => Navigator.pop(context),
        null,
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && _images.length < 5) {
      setState(() {
        _images.add(File(image.path));
      });
    } else if (_images.length >= 5) {
      AppUtils.showSingleDialogPopup(
        context,
        "Max. 5 attachments only allowed",
        "Ok",
        () => Navigator.pop(context),
        null,
      );
    }
  }

  Widget _buildHeaderDetails() {
    return Column(
      children: [
        _buildTextField("Company", Prefs.getDBName('DBName').toString(),
            Icons.abc_outlined),
        SizedBox(
          height: 2,
        ),
        _buildTextField(
            "Customer", widget.data['customerName'].toString(), Icons.person),
        SizedBox(
          height: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: _buildTextField(
                  "Logistic No",
                  widget.data['logisticRequestNo'].toString(),
                  Icons.laptop_chromebook_outlined),
            ),
            Expanded(
              flex: 5,
              child: _buildTextField(
                  "Branch",
                  Prefs.getBranchName('BranchName').toString(),
                  Icons.broadcast_on_home),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: _buildTextField("Sales Order No",
                  widget.data['salesOrderNo'].toString(), Icons.dock_outlined),
            ),
            Expanded(
              flex: 5,
              child: _textFornField("Container No", "", Icons.add_box_sharp),
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

  Widget _textFornField(String label, String hint, IconData icon) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
            controller: containernumbercontroller,
            keyboardType: TextInputType.multiline,
            autofocus: false,
            decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                isDense: true)));
  }

  Widget containernumberupdate() {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Wrap(
          spacing: 600,
          children: [
            AppUtils.bottomHanger(context),
            Container(height: 10),
            const Text(
              "Container Number!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Container(height: 20),
            Container(
                //padding: EdgeInsets.all(20),
                child: TextField(
              controller: containernumbercontroller,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter Container Number",
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
                    if (containernumbercontroller.text.isEmpty) {
                    } else {
                      Navigator.pop(context);
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
                        items[index].emptyQty.toString().isEmpty
                            ? "Empty Qty : 0"
                            : "Empty Qty  : ${items[index].emptyQty.toStringAsFixed(2)}",
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
                        items[index].grossWeight.toString().isEmpty
                            ? "Gross wght : 0"
                            : "Gross wght: ${items[index].grossWeight.toStringAsFixed(2)}",
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
                        items[index].finalDOQty.toString().isEmpty
                            ? "Final DoQty :0"
                            : "Final DoQty: ${items[index].finalDOQty.toStringAsFixed(2)}",
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
                        items[index].netWeight.toString() == ""
                            ? "Net wght:0"
                            : "Net wght: ${items[index].netWeight.toStringAsFixed(2)}",
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
                        items[index].packingWeight.toString().isEmpty
                            ? "Pack wght : 0"
                            : "Pack wght: ${items[index].packingWeight.toStringAsFixed(2)}",
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
                        items[index].noofpack.toString().isEmpty ||
                                items[index].noofpack == null
                            ? "No of Pack: 0"
                            : "No of Pack: ${items[index].noofpack.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.bag,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        items[index].packingtypeName.toString(),
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
          builder: (context) => ProductSelectionScreen(
              items: items, getLogisticNo: getLogisticID)),
    );
    if (result != null) {
      setState(() {
        items = result; // Update with new list
        _calculateTotals();
      });
    }
  }

  void postItem() {
    setState(() {
      loading = true;
    });
    final map = <String, dynamic>{};
    map['docEntry'] = getLogisticID;
    map['docNum'] = getLogisticNo;
    map['userId'] = Prefs.getEmpID('Id');
    map['sONum'] = widget.data['salesOrderNo'];
    map['sOEntry'] = widget.data['soEntry'];
    map['cardCode'] = widget.data['customerCode'];
    map['cardName'] = widget.data['customerName'];
    map['containerNo'] = containernumbercontroller.text;
    map['docStatus'] = value1 == true ? "closed" : "opened";

    apiService
        .postrequest(map, _images, items, getcompanyname, getbranchId)
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

  void updateYarnApi() {
    setState(() {
      loading = true;
    });
    final map = <String, dynamic>{};
    map['docEntry'] = getLogisticID;
    map['docNum'] = getLogisticNo;
    map['userId'] = Prefs.getEmpID('Id');
    map['sONum'] = widget.data['salesOrderNo'].toString();
    map['sOEntry'] = widget.data['soEntry'];
    map['cardCode'] = widget.data['customerCode'];
    map['cardName'] = widget.data['customerName'];
    map['containerNo'] = containernumbercontroller.text;
    map['docStatus'] = value1 == true ? "closed" : "opened";

    apiService
        .updateyarnList(map, _images, items, getcompanyname, getbranchId,
            widget.data['yardLoadingId'], _removedURL)
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

  void getyarneditloadinglist() {
    setState(() {
      loading = true;
    });

    apiService
        .geteditsingleyarnloading(
            getcompanyname, getbranchId, widget.data['yardLoadingId'])
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        editmodel.clear();
        editmodel = jsonDecode(response.body)['result']
            .map<YarnEditListModel>((item) => YarnEditListModel.fromJson(item))
            .toList();

        for (var edititems in editmodel.first.items) {
          items.add(PostItem(
              edititems.lineId,
              edititems.itemCode.toString(),
              edititems.itemName.toString(),
              edititems.warehouse,
              edititems.emptyWeight,
              edititems.grossWeight,
              edititems.finalDoQty,
              edititems.netWeight,
              edititems.baseEntry,
              edititems.baseLine,
              edititems.baseType.toString(),
              edititems.packingWeight,
              edititems.packingtype,
              edititems.packingtypeName,
              edititems.noofpack));
        }

        for (var editimages in editmodel.first.attachmentPath) {
          if (editimages.filename.isNotEmpty) {
            _editimages.add(File(jsonEncode(editimages.url)));
            print(_editimages);
          }
        }

        _calculateTotals();
        //items.add(PostItem(itemcode, itemname, whs, emptyQty, grossWeight, finalDOQty, netWeight))
      } else if (response.statusCode == 401) {
        editmodel.clear();
        setState(() {
          loading = false;
        });
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

  void _calculateTotals() {
    totalQuantity =
        items.fold(0, (sum, item) => sum + item.emptyQty!.toDouble());
    totalGrossWeight = items.fold(0, (sum, item) => sum + (item.grossWeight!));
    totalDoQty = items.fold(0, (sum, item) => sum + (item.finalDOQty!));
    totalNetweight = items.fold(0, (sum, item) => sum + (item.netWeight!));
    totalpackweight = items.fold(0, (sum, item) => sum + (item.packingWeight!));
    totalnoofpack = items.fold(0, (sum, item) => sum + (item.noofpack!));

    setState(() {});
  }

  void onexitpopup() {
    Navigator.of(context).pop();
  }

  void onrefresh() {
    AppUtils.pop(context);
    AppUtils.pop(context);
    AppUtils.pop(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const YarnSelectionPage()));
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
}
