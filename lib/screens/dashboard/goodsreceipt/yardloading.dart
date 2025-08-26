import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/editmodelyarnlist.dart';
import 'package:pgiconnect/model/supervisorModel.dart';
import 'package:pgiconnect/screens/dashboard/viewImage.dart';
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

  final Set<File> _selectedImages = {};

  final ImagePicker _picker = ImagePicker();
  bool loading = false;
  ApiService apiService = ApiService();

  TextEditingController containernumbercontroller = TextEditingController();
  TextEditingController dateofLoadingContainer = TextEditingController();
  TextEditingController actualQtyLoadedContainer = TextEditingController();
  TextEditingController sealedByNameController = TextEditingController();
  TextEditingController clearanceByController = TextEditingController();
  TextEditingController weightnocontroller = TextEditingController();
  TextEditingController vehicleNoController = TextEditingController();
  TextEditingController sealNocontroller = TextEditingController();
  List<YarnEditListModel> editmodel = [];
  final superKey = GlobalKey<DropdownSearchState<SuperVisorModel>>();

  final List<File> _images = [];
  final List<File> _editimages = [];
  final List<String> _removedURL = [];
  SuperVisorModel? selectedSupervisor;
  String superVisorCode = "";
  String superVisorName = "";
  bool value1 = false;
  List<Map<String, dynamic>> packinglist = [
    {
      'id': 'JB',
      'name': 'Jumbo Bag',
    },
    {
      'id': 'PL',
      'name': 'Pallete',
    },
    {
      'id': 'BR',
      'name': 'Briquestes',
    },
    {
      'id': 'BU',
      'name': 'Bundles',
    },
    {
      'id': 'LO',
      'name': 'Loose',
    },
    {
      'id': 'FW',
      'name': 'Fumigated Wooden Pallets',
    }
  ];
  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
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
      // containernumbercontroller.text = widget.data['containerNo'];
      // dateofLoadingContainer.text = widget.data['dateofLoading'] ?? "";

      // actualQtyLoadedContainer.text =
      //     (widget.data['actualQtyLoaded'] as num).toStringAsFixed(3);

      // sealedByNameController.text = widget.data['whoSealedtheContainer'];
      // clearanceByController.text = widget.data['clearancegivenby'];
      // superVisorCode = widget.data['supervisorCode'];
      // superVisorName = widget.data['supervisorName'];
      containernumbercontroller.text = widget.data['containerNo'] ?? '';

      dateofLoadingContainer.text = widget.data['dateofLoading'] ?? '';

      actualQtyLoadedContainer.text =
          (widget.data['actualQtyLoaded'] ?? 0).toStringAsFixed(3);

      sealedByNameController.text = widget.data['whoSealedtheContainer'] ?? '';

      clearanceByController.text = widget.data['clearancegivenby'] ?? '';

      superVisorCode = (widget.data['supervisorCode'] ?? '').toString();
      superVisorName = (widget.data['supervisorName'] ?? '').toString();
      selectedSupervisor =
          SuperVisorModel(id: superVisorCode, value: superVisorName);
    }
    super.initState();
  }

  @override
  void dispose() {
    containernumbercontroller.dispose();
    dateofLoadingContainer.dispose();
    actualQtyLoadedContainer.dispose();
    sealedByNameController.dispose();
    clearanceByController.dispose();
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
                          }
                          // else if (superVisorCode.isEmpty) {
                          //   AppUtils.showSingleDialogPopup(
                          //       context,
                          //       "Please Choose Supervisor",
                          //       "Ok",
                          //       onexitpopup,
                          //       null);
                          // } else if (dateofLoadingContainer.text.isEmpty) {
                          //   AppUtils.showSingleDialogPopup(
                          //       context,
                          //       "Please Choose Date of Loading",
                          //       "Ok",
                          //       onexitpopup,
                          //       null);
                          // }
                          //else if (actualQtyLoadedContainer.text.isEmpty) {
                          //   AppUtils.showSingleDialogPopup(
                          //       context,
                          //       "Please Enter Actual Qty",
                          //       "Ok",
                          //       onexitpopup,
                          //       null);
                          // } else if (sealedByNameController.text.isEmpty) {
                          // AppUtils.showSingleDialogPopup(
                          //     context,
                          //     "Please Enter Sealed by Name",
                          //     "Ok",
                          //     onexitpopup,
                          //     null);
                          //}
                          // else if (clearanceByController.text.isEmpty) {
                          //   AppUtils.showSingleDialogPopup(
                          //       context,
                          //       "Please Enter Clearance by",
                          //       "Ok",
                          //       onexitpopup,
                          //       null);
                          // }

                          else {
                            // widget.data['isEditable'] == false
                            //     ? postItem()
                            //     : widget.status == "Completed"
                            //         ? ""
                            //         : updateYarnApi();

                            widget.data['isEditable'] == false
                                ? postItem()
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

  // Widget _buildUploadSection() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "Attachment",
  //           style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
  //         ),
  //         const SizedBox(height: 10),
  //         Wrap(
  //           spacing: 10,
  //           runSpacing: 10,
  //           children: [
  //             ..._images.map((file) {
  //               final isSelected = _selectedImages.contains(file);
  //               return Stack(
  //                 children: [
  //                   Container(
  //                     width: 100,
  //                     height: 100,
  //                     decoration: BoxDecoration(
  //                       border: Border.all(
  //                         color: isSelected ? Colors.blue : Colors.grey,
  //                         width: isSelected ? 2 : 1,
  //                       ),
  //                       borderRadius: BorderRadius.circular(8),
  //                       image: DecorationImage(
  //                         image: FileImage(file),
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                   ),
  //                   Positioned(
  //                     top: -8,
  //                     left: -8,
  //                     child: Checkbox(
  //                       value: isSelected,
  //                       onChanged: (value) {
  //                         setState(() {
  //                           if (value == true) {
  //                             print(file.path);
  //                             _selectedImages.add(file);
  //                           } else {
  //                             _selectedImages.remove(file);
  //                           }
  //                         });
  //                       },
  //                       side: const BorderSide(width: 1, color: Colors.green),
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(4)),
  //                       fillColor: WidgetStateProperty.all(Colors.white),
  //                       checkColor: Colors.blue,
  //                     ),
  //                   ),
  //                   Positioned(
  //                     top: -8,
  //                     right: -8,
  //                     child: IconButton(
  //                       icon: const Icon(Icons.cancel,
  //                           color: Colors.red, size: 20),
  //                       onPressed: () {
  //                         setState(() {
  //                           _selectedImages.remove(file);
  //                           _images.remove(file);
  //                         });
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             }),
  //             if (_images.length < maxImages)
  //               GestureDetector(
  //                 onTap: () {
  //                   AppUtils.showBottomCupertinoDialog(
  //                     context,
  //                     title: "Attach Image",
  //                     btn1function: () {
  //                       AppUtils.pop(context);
  //                       _cameraImage();
  //                     },
  //                     btn2function: () {
  //                       AppUtils.pop(context);
  //                       _pickImage();
  //                     },
  //                   );
  //                 },
  //                 child: Container(
  //                   width: 100,
  //                   height: 100,
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.grey),
  //                     borderRadius: BorderRadius.circular(8),
  //                     color: Colors.white,
  //                   ),
  //                   child: const Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(Icons.add, size: 30, color: Colors.black54),
  //                       SizedBox(height: 5),
  //                       Text("Upload", style: TextStyle(color: Colors.black54)),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
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
                    GestureDetector(
                      onTap: () {
                        final imagePath = file.path.toString().trim() ?? "";
                        if (imagePath.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("❌ No image available")),
                          );
                          return; // stop navigation
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ImagePreviewPage(imageUrl: imagePath),
                          ),
                        );
                      },
                      child: Container(
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
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black45, // semi-transparent background
                        padding: const EdgeInsets.all(4),
                        child: const Text(
                          "Click to view",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
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

  Widget _buildHeaderDetails() {
    return Column(
      children: [
        _buildTextField("Company", Prefs.getDBName('DBName').toString(),
            Icons.abc_outlined),
        SizedBox(
          height: 2,
        ),
        // _buildTextField(
        //     "Customer", widget.data['customerName'].toString(), Icons.person),
        // SizedBox(
        //   height: 2,
        // ),
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
              child: _textFornField("Container No", "", Icons.add_box_sharp,
                  containernumbercontroller),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: DropdownSearch<SuperVisorModel>(
                key: superKey,
                selectedItem: selectedSupervisor,
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
                          superKey.currentState?.popupValidate([item]);
                          superVisorCode = item.id.toString();
                          superVisorName = item.value.toString();

                          setState(() {});
                        });
                  },
                ),
                asyncItems: (String filter) => ApiService.getsupervisorlists(
                  Prefs.getDBName('DBName'),
                  Prefs.getBranchID('BranchID'),
                  filter: filter,
                ),
                itemAsString: (SuperVisorModel item) => item.value.toString(),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    hintText: 'Supervisor * ',
                    label: Text("Supervisor"),
                    filled: true,
                    fillColor: Colors.white,
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
            Expanded(
              flex: 5,
              child: _textFormFieldDate("Date Of Loading", "",
                  Icons.add_box_sharp, dateofLoadingContainer),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Expanded(
            //   flex: 5,
            //   child: _textFormFieldNumeric("Actual Qty Loaded", "",
            //       CupertinoIcons.cube_box, actualQtyLoadedContainer),
            // ),
            Expanded(
              flex: 5,
              child: _textFornField("Who is Sealed Container", "",
                  Icons.add_box_sharp, sealedByNameController),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: _textFornField("Clearance By", "", Icons.add_box_sharp,
                  clearanceByController),
            ),
            Expanded(
              flex: 5,
              child: _textFornField(
                  "SealNo", "", Icons.add_box_sharp, sealNocontroller),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: _textFornField(
                  "Weigh No", "", Icons.add_box_sharp, weightnocontroller),
            ),
            Expanded(
              flex: 5,
              child: _textFornField(
                  "Vehicle No", "", Icons.add_box_sharp, vehicleNoController),
            ),
          ],
        )
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

  Widget _textFornField(
      String label, String hint, IconData icon, controllerName) {
    return Container(
        padding: const EdgeInsets.all(4.0),
        child: TextFormField(
            controller: controllerName,
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

  Widget _textFormFieldDate(
      String label, String hint, IconData icon, controllerName) {
    return Container(
        padding: const EdgeInsets.all(4.0),
        child: TextFormField(
            controller: controllerName,
            keyboardType: TextInputType.multiline,
            autofocus: false,
            readOnly: true,
            onTap: () async {
              DateTime tomorrow = DateTime.now().add(Duration(days: 0));
              DateTime? date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                controllerName.text = DateFormat('dd/MM/yyyy').format(date);
              }
            },
            decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                isDense: true)));
  }

  Widget _textFormFieldNumeric(
      String label, String hint, IconData icon, controllerName) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: TextFormField(
        controller: controllerName,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: false,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
        ],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
          isDense: true,
          prefixIcon: Icon(icon),
        ),
      ),
    );
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

  Widget _buildProductItem(List<PostItem> items) {
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
                      Text(items[index].itemname.toString(),
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
                            : "Empty Qty  : ${items[index].emptyQty!.toStringAsFixed(2)}",
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
                            : "Gross wght: ${items[index].grossWeight!.toStringAsFixed(2)}",
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
                            : "Final DoQty: ${items[index].finalDOQty!.toStringAsFixed(2)}",
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
                            : "Net wght: ${items[index].netWeight!.toStringAsFixed(2)}",
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
                            : "Pack wght: ${items[index].packingWeight!.toStringAsFixed(2)}",
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
                            : "No of Pack: ${items[index].noofpack!.toStringAsFixed(2)}",
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
                        items[index].packingtypeName.toString().isEmpty ||
                                items[index].packingtypeName == null
                            ? "Packing Type : "
                            : "Packing Type : ${items[index].packingtypeName.toString()}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Row(
              //       children: [
              //         Icon(
              //           CupertinoIcons.cube_box,
              //           color: Colors.grey,
              //           size: 20,
              //         ),
              //         SizedBox(
              //           width: 5,
              //         ),
              //         Text(
              //           "Seal No:${items[index].sealNo}",
              //           style: TextStyle(fontSize: 12),
              //         ),
              //       ],
              //     ),
              //     Row(
              //       children: [
              //         Icon(
              //           CupertinoIcons.bag,
              //           color: Colors.grey,
              //           size: 20,
              //         ),
              //         SizedBox(
              //           width: 5,
              //         ),
              //         Text(
              //           "Vehicle No : ${items[index].vechicleNo.toString()}",
              //           style: TextStyle(fontSize: 12),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 5,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Row(
              //       children: [
              //         Icon(
              //           CupertinoIcons.cube_box,
              //           color: Colors.grey,
              //           size: 20,
              //         ),
              //         SizedBox(
              //           width: 5,
              //         ),
              //         Text(
              //           "Weigh No : ${items[index].weighNo}",
              //           style: TextStyle(fontSize: 12),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
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
      //FocusScope.of(context).unfocus();
      setState(() {
        items = result; // Update with new list
        _calculateTotals();
      });
      // Hide keyboard after the rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).unfocus();
      });
    }
  }

  void postItem() async {
    final List<File> selectedImageList =
        _selectedImages.toList(); // Convert Set to List

    setState(() {
      loading = true;
    });

    final map = {
      'docEntry': getLogisticID,
      'docNum': getLogisticNo,
      'userId': Prefs.getEmpID('Id'),
      'sONum': widget.data['salesOrderNo'],
      'sOEntry': widget.data['soEntry'],
      'cardCode': widget.data['customerCode'],
      'cardName': widget.data['customerName'],
      'containerNo': containernumbercontroller.text,
      'docStatus': value1 == true ? "closed" : "open",
      'supervisorCode': superVisorCode,
      'supervisorName': superVisorName,
      'dateofLoading': dateofLoadingContainer.text,
      'actualQtyLoaded': "0",
      'whoSealedtheContainer': sealedByNameController.text,
      'clearancegivenby': clearanceByController.text,
      'sealNo': sealNocontroller.text,
      'vechicleNo': vehicleNoController.text,
      'weighNo': weightnocontroller.text
    };
    List<Map<String, dynamic>> jsonList = [];
    if (items.isNotEmpty) {
      for (int i = 0; i < items.length; i++) {
        items[i].sealNo = sealNocontroller.text;
        items[i].vechicleNo = vehicleNoController.text;
        items[i].weighNo = weightnocontroller.text;
      }

      jsonList = items.map((e) => e.toJson()).toList();
    }
    try {
      final response = await apiService.postrequest(
        map,
        _images,
        jsonList.isEmpty ? [] : jsonList,
        getcompanyname,
        getbranchId.toString(),
        selectedImageList,
      );

      setState(() => loading = false);

      if (response.statusCode == 200 || response.statusCode < 300) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['success'].toString() == "true") {
          AppUtils.showSingleDialogPopup(
            context,
            jsonResponse['message'].toString(),
            "Ok",
            onrefresh,
            null,
          );
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            jsonResponse['message'].toString(),
            "Ok",
            onexitpopup,
            null,
          );
        }
      } else {
        final errorBody = await response.stream.bytesToString();
        AppUtils.showSingleDialogPopup(
          context,
          jsonDecode(errorBody)['message'].toString(),
          "Ok",
          onexitpopup,
          null,
        );
      }
    } catch (e) {
      setState(() => loading = false);

      final errorMessage = e is TimeoutException
          ? "Request timed out. Please check your internet connection."
          : e is SocketException
              ? "Network error. Please check your internet connection."
              : e.toString();

      AppUtils.showSingleDialogPopup(
          context, errorMessage, "Ok", onexitpopup, null);
    }
  }

  void updateYarnApi() {
    final List<File> selectedImageList = _selectedImages.toList();

    if (_editimages.isNotEmpty) {
      _images.addAll(_editimages);
    }

    //_images.addAll(_editimages.where((img) => !_images.contains(img)));
    setState(() {
      loading = true;
    });

    final map = {
      'docEntry': getLogisticID,
      'docNum': getLogisticNo,
      'userId': Prefs.getEmpID('Id'),
      'sONum': widget.data['salesOrderNo']?.toString() ?? '',
      'sOEntry': widget.data['soEntry']?.toString() ?? '',
      'cardCode': widget.data['customerCode'] ?? '',
      'cardName': widget.data['customerName'] ?? '',
      'containerNo': containernumbercontroller.text,
      'docStatus': value1 == true ? "closed" : "open",
      'supervisorCode': superVisorCode,
      'supervisorName': superVisorName,
      'dateofLoading': dateofLoadingContainer.text,
      'actualQtyLoaded': actualQtyLoadedContainer.text,
      'whoSealedtheContainer': sealedByNameController.text,
      'clearancegivenby': clearanceByController.text,
      'sealNo': sealNocontroller.text,
      'vechicleNo': vehicleNoController.text,
      'weighNo': weightnocontroller.text
    };

    apiService
        .updateyarnList(
            map,
            _images,
            items,
            getcompanyname,
            getbranchId.toString(),
            widget.data['yardLoadingId'] ?? '',
            _removedURL,
            selectedImageList)
        .then((response) async {
      setState(() {
        loading = false;
      });

      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      print("🔸 updateYarnList() Response: $jsonResponse");

      if (response.statusCode == 200 || response.statusCode < 300) {
        if (jsonResponse['success'].toString() == "true") {
          AppUtils.showSingleDialogPopup(
            context,
            jsonResponse['message'].toString(),
            "Ok",
            onrefresh,
            null,
          );
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            jsonResponse['message'].toString(),
            "Ok",
            onexitpopup,
            null,
          );
        }
      } else {
        AppUtils.showSingleDialogPopup(
          context,
          jsonResponse['message'].toString(),
          "Ok",
          onexitpopup,
          null,
        );
      }
    }).catchError((e) {
      setState(() {
        loading = false;
      });

      final String errorMessage;
      if (e is TimeoutException) {
        errorMessage = "Request timed out. Please try again.";
      } else if (e is SocketException) {
        errorMessage = "No internet connection.";
      } else {
        errorMessage = e.toString();
      }

      AppUtils.showSingleDialogPopup(
          context, errorMessage, "Ok", onexitpopup, null);
    });
  }

  void getyarneditloadinglist() {
    setState(() => loading = true);

    apiService
        .geteditsingleyarnloading(
            getcompanyname, getbranchId, widget.data['yardLoadingId'])
        .then((response) async {
      setState(() => loading = false);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final result = decoded['result'];

        editmodel.clear();
        items.clear();
        _editimages.clear();

        if (result != null && result is List) {
          editmodel = result
              .map<YarnEditListModel>(
                  (item) => YarnEditListModel.fromJson(item))
              .toList();

          for (var model in editmodel) {
            // 🧾 Parse item lines
            if ((model.items ?? []).isNotEmpty) {
              for (var edititems in model.items) {
                items.add(PostItem(
                  edititems.lineId,
                  edititems.yardLoadingLineId,
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
                  edititems.packingtypeName =
                      getPackingName(edititems.packingtype.toString()),
                  edititems.noofpack,
                  edititems.sealNo,
                  edititems.vechicleNo,
                  edititems.weighNo,
                ));
              }
            }
            superVisorCode = model.supervisorCode.toString();
            superVisorName = model.supervisorName.toString();
            selectedSupervisor =
                SuperVisorModel(id: superVisorCode, value: superVisorName);
            dateofLoadingContainer.text = model.dateofLoading.toString();
            sealedByNameController.text =
                model.whoSealedtheContainer.toString();
            actualQtyLoadedContainer.text = model.actualQtyLoaded.toString();
            clearanceByController.text = model.clearancegivenby.toString();
            weightnocontroller.text = model.weighNo.toString();
            vehicleNoController.text = model.vehicleNo.toString();
            sealNocontroller.text = model.sealNo.toString();
            // 🖼️ Parse attachments
            if (model.attachmentPath.isNotEmpty) {
              for (var editimages in model.attachmentPath) {
                if ((editimages.filename ?? '').isNotEmpty &&
                    (editimages.url ?? '').isNotEmpty) {
                  _editimages.add(File(editimages.url));
                }
              }
            }
          }

          // 🚛 Prefill vehicle/seal/weight fields
          if (items.isNotEmpty) {
            vehicleNoController.text = items[0].vechicleNo.toString();
            weightnocontroller.text = items[0].weighNo.toString();
            sealNocontroller.text = items[0].sealNo.toString();
          }

          _calculateTotals();
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            "No data found in the API response.",
            "Ok",
            null,
            null,
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 500) {
        final errorMessage =
            jsonDecode(response.body)['message'].toString() ?? "Error occurred";
        editmodel.clear();
        setState(() => loading = false);
        AppUtils.showSingleDialogPopup(
            context, errorMessage, "Ok", handleTokenExpired, null);
      }
    }).catchError((e) {
      setState(() => loading = false);
      String errorMessage;

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

  String getPackingName(String id) {
    print(id);
    return packinglist.firstWhere(
      (item) => item['id'].toString() == id.toString(),
      orElse: () => {'name': 'Unknown'},
    )['name'];
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
