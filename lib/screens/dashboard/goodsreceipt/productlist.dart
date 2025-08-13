import 'dart:collection';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/itemModel.dart';
import 'package:pgiconnect/model/supervisorModel.dart';
import 'package:pgiconnect/screens/dashboard/whsselection.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';

class ProductSelectionScreen extends StatefulWidget {
  List<PostItem> items;
  String getLogisticNo;
  ProductSelectionScreen(
      {super.key, required this.items, required this.getLogisticNo});

  @override
  ProductSelectionScreenState createState() => ProductSelectionScreenState();
}

class ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _emptyQtyController = TextEditingController();
  final TextEditingController _grossWeightController = TextEditingController();
  final TextEditingController finalDoqtyController = TextEditingController();
  TextEditingController netweightController = TextEditingController();
  TextEditingController noofpackcontroller = TextEditingController();
  TextEditingController packingqtycontroller = TextEditingController();

  final formKey = GlobalKey<FormState>();

  //List<PostItem> posteditem=[];
  final itemkey = GlobalKey<DropdownSearchState<ItemModel>>();

  final packingkey = GlobalKey<DropdownSearchState<Map<String, dynamic>>>();
  String getItemCode = "";
  String getItemName = "";
  String getWhs = "";

  String getbaseEntry = "";
  String getbaseLine = "";
  String getbaseType = "";
  int getLineId = 0;

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
  String packingListId = "JB";
  String packingListName = "Jumbo Bag";

  String getSuperVisorCode = "";
  String getSuperVisorName = "";

  Map<String, dynamic>? selectedpackingItem;

  final FocusNode _emptyQtyFocus = FocusNode();
  final FocusNode _grossWeightFocus = FocusNode();
  final FocusNode _packingWeightFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _emptyQtyFocus.addListener(() {
      if (!_emptyQtyFocus.hasFocus) {
        _formatTo3Decimal(_emptyQtyController);
      }
    });

    _grossWeightFocus.addListener(() {
      if (!_grossWeightFocus.hasFocus) {
        _formatTo3Decimal(_grossWeightController);
      }
    });

    _packingWeightFocus.addListener(() {
      if (!_packingWeightFocus.hasFocus) {
        _formatTo3Decimal(packingqtycontroller);
      }
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _emptyQtyController.dispose();
    _grossWeightController.dispose();
    finalDoqtyController.dispose();
    netweightController.dispose();
    noofpackcontroller.dispose();
    packingqtycontroller.dispose();
    _emptyQtyFocus.dispose();
    _grossWeightFocus.dispose();
    _packingWeightFocus.dispose();
    itemkey.currentState?.dispose();
    packingkey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Items'),
        backgroundColor: Appcolor.primary,
        actions: [
          RawMaterialButton(
            onPressed: () {
              final isValid = formKey.currentState!.validate();
              if (!isValid) {
                return;
              }
              formKey.currentState!.save();
              additem();
            },
            elevation: 2.0,
            fillColor: Colors.green,
            padding: const EdgeInsets.all(5.0),
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              size: 25.0,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20, left: 5, right: 5),
            child: Column(
              children: [
                Form(
                  key: formKey,
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Warehouse : $getWhs"),
                            GestureDetector(
                                onTap: () {
                                  _whsselection(context);
                                },
                                child: Icon(Icons.edit)),
                          ],
                        ),
                        DropdownSearch<ItemModel>(
                          key: itemkey,
                          popupProps: PopupProps.menu(
                            
                            showSearchBox: true,
                            interceptCallBacks: true, //important line
                            itemBuilder: (ctx, item, isSelected) {
                              bool isDisabled = widget.items.any((temp) =>
                                  temp.lineId == item.yardloadinglineId &&
                                  temp.baseEntry == item.baseEntry);
                              return ListTile(
                                  selected: isSelected,
                                  title: Text(
                                    item.itemName.toString(),
                                    style: TextStyle(
                                      color: isDisabled
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                  enabled: !isDisabled,
                                  onTap: () {
                                    itemkey.currentState?.popupValidate([item]);
                                    getItemCode = item.itemCode.toString();
                                    getItemName = item.itemName.toString();
                                    getWhs = item.whsCode.toString();
                                    getbaseEntry = item.baseEntry.toString();
                                    getbaseLine = item.baseLine.toString();
                                    getbaseType = item.baseType.toString();
                                    getLineId = item.yardloadinglineId!;
                                    setState(() {});
                                  });
                            },
                          ),
                          asyncItems: (String filter) =>
                              ApiService.getitemMaster(
                            widget.getLogisticNo,
                            Prefs.getDBName('DBName'),
                            Prefs.getBranchID('BranchID'),
                            filter: filter,
                          ),
                          itemAsString: (ItemModel item) =>
                              item.itemName.toString(),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              hintText: 'Item  Name * ',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                  focusNode: _emptyQtyFocus,
                                  controller: _emptyQtyController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  autofocus: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,3}')),
                                  ],
                                  validator: (value) =>
                                      value!.isNotEmpty ? null : "Empty Weight",
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 10.0),
                                    border: OutlineInputBorder(),
                                    hintText: "Empty Weight",
                                    labelText: "Empty Weight(MT)",
                                  ),
                                  onChanged: (val) {
                                    formula();
                                  }),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                  focusNode: _grossWeightFocus,
                                  controller: _grossWeightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  autofocus: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,3}')),
                                  ],
                                  validator: (value) => value!.isNotEmpty
                                      ? null
                                      : "Gross Weight is Empty",
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 10.0),
                                    border: OutlineInputBorder(),
                                    hintText: "Gross weight",
                                    labelText: "Gross weight",
                                  ),
                                  onChanged: (val) {
                                    formula();
                                  }),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                readOnly: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                autofocus: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,3}')),
                                ],
                                controller: netweightController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 0.5),
                                  ),
                                  hintText: "NetWeight",
                                  labelText: "NetWeight",
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                focusNode: _packingWeightFocus,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                autofocus: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,3}')),
                                ],
                                controller: packingqtycontroller,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 0.5),
                                  ),
                                  hintText: "Packing Weight",
                                  labelText: "Packing Weight",
                                ),
                                onChanged: (val) {
                                  formula2();
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                readOnly: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                autofocus: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,3}')),
                                ],
                                controller: finalDoqtyController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Appcolor.primary, width: 0.5),
                                  ),
                                  hintText: "Final Weight",
                                  labelText: "Final Weight",
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                autofocus: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,3}')),
                                ],
                                controller: noofpackcontroller,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Appcolor.black, width: 0.5),
                                  ),
                                  hintText: "No.Of.Packing",
                                  labelText: "No.Of.Packing",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: DropdownSearch<Map<String, dynamic>>(
                                key: packingkey,
                                items: packinglist,
                                itemAsString: (Map<String, dynamic>? item) =>
                                    item?['name'] ?? '',
                                onChanged: (value) {
                                  setState(() {
                                    selectedpackingItem = value;
                                  });
                                },
                                selectedItem: selectedpackingItem,
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Packing Type",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  interceptCallBacks: true, //important line
                                  itemBuilder: (ctx, item, isSelected) {
                                    return ListTile(
                                        selected: isSelected,
                                        title: Text(item['name'].toString()),
                                        onTap: () {
                                          packingkey.currentState
                                              ?.popupValidate([item]);
                                          packingListId = item['id'].toString();
                                          packingListName =
                                              item['name'].toString();
                                          print(packingListName);
                                          setState(() {});
                                        });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.isEmpty ? 0 : widget.items.length,
              itemBuilder: (context, index) {
                var item = widget.items[index];
                return InkWell(
                  onTap: () {},
                  child: Container(
                      margin: const EdgeInsets.all(5),
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, bottom: 3),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 0.5,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: Colors.white),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 9,
                                  child: AppUtils.buildNormalText(
                                      text:
                                          "Item Name : ${item.itemname.toString()}",
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      removeitem(index);
                                    },
                                    child: const Icon(
                                      CupertinoIcons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.home,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 15),
                                AppUtils.buildNormalText(
                                    text: widget.items[index].whs.toString(),
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.cube_box,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "Empty Wght",
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(width: 15),
                                    AppUtils.buildNormalText(
                                        text: widget.items[index].emptyQty!
                                            .toStringAsFixed(3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.cube_box,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "Gross Weight",
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(width: 15),
                                    AppUtils.buildNormalText(
                                        text: widget.items[index].emptyQty!
                                            .toStringAsFixed(3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.cube_box,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "Net Weight",
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(width: 15),
                                    AppUtils.buildNormalText(
                                        text: widget.items[index].netWeight!
                                            .toStringAsFixed(3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.cube_box,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "Final DO Qty",
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(width: 15),
                                    AppUtils.buildNormalText(
                                        text: widget.items[index].finalDOQty!
                                            .toStringAsFixed(3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.cube_box,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "Packing wgt",
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(width: 15),
                                    AppUtils.buildNormalText(
                                        text: widget.items[index].packingWeight!
                                            .toStringAsFixed(3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.cube_box,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "No.of.pack",
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(width: 15),
                                    AppUtils.buildNormalText(
                                        text: widget.items[index].noofpack!
                                            .toStringAsFixed(3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.bag,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text:
                                            widget.items[index].packingtypeName,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.end,
                                //   children: [
                                //     const Icon(
                                //       CupertinoIcons.bag,
                                //       color: Colors.grey,
                                //       size: 20,
                                //     ),
                                //     SizedBox(
                                //       width: 15,
                                //     ),
                                //     AppUtils.buildNormalText(
                                //         text:
                                //             "Seal No  ${widget.items[index].sealNo.toString()}",
                                //         fontSize: 12,
                                //         fontWeight: FontWeight.normal),
                                //     const SizedBox(
                                //       width: 15,
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                            // Row(
                            //   children: [
                            //     Row(
                            //       mainAxisAlignment: MainAxisAlignment.start,
                            //       children: [
                            //         const Icon(
                            //           CupertinoIcons.bag,
                            //           color: Colors.grey,
                            //           size: 20,
                            //         ),
                            //         SizedBox(
                            //           width: 15,
                            //         ),
                            //         AppUtils.buildNormalText(
                            //             text:
                            //                 "Vehicle No ${widget.items[index].vechicleNo.toString()}",
                            //             fontSize: 12,
                            //             fontWeight: FontWeight.normal),
                            //         const SizedBox(
                            //           width: 15,
                            //         ),
                            //       ],
                            //     ),
                            //     Row(
                            //       mainAxisAlignment: MainAxisAlignment.end,
                            //       children: [
                            //         const Icon(
                            //           CupertinoIcons.bag,
                            //           color: Colors.grey,
                            //           size: 20,
                            //         ),
                            //         SizedBox(
                            //           width: 15,
                            //         ),
                            //         AppUtils.buildNormalText(
                            //             text:
                            //                 "Weigh No ${widget.items[index].weighNo.toString()}",
                            //             fontSize: 12,
                            //             fontWeight: FontWeight.normal),
                            //         const SizedBox(
                            //           width: 15,
                            //         ),
                            //       ],
                            //     ),
                            //   ],
                            // ),
                          ])),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
              widget.items.isNotEmpty
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Appcolor.primary),
                      onPressed: () {
                        //           List<Map<String, dynamic>> filteredItems =
                        // widget.items.where((item) => item["quantity"] > 0).toList();
                        Navigator.pop(
                            context, widget.items); // Return the updated list
                      },
                      child: Row(
                        children: [
                          Text("Continue",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.white, size: 12),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  removeitem(position) {
    setState(() {
      widget.items.removeAt(position);
    });
  }

  additem() {
    widget.items.add(PostItem(
        getLineId,
        getLineId,
        getItemCode,
        getItemName,
        getWhs,
        _emptyQtyController.text.isEmpty
            ? 0
            : double.parse(_emptyQtyController.text),
        _grossWeightController.text.isEmpty
            ? 0
            : double.parse(_grossWeightController.text),
        finalDoqtyController.text.isEmpty
            ? 0
            : double.parse(finalDoqtyController.text.toString()),
        netweightController.text.isEmpty
            ? 0
            : double.parse(netweightController.text.toString()),
        int.parse(getbaseEntry),
        int.parse(getbaseLine),
        getbaseType,
        packingqtycontroller.text.isEmpty
            ? 0
            : double.parse(packingqtycontroller.text.toString()),
        packingListId,
        packingListName,
        noofpackcontroller.text.isEmpty
            ? 0
            : int.parse(noofpackcontroller.text.toString()),
        "",
        "",
        ""));
    setState(() {
      _emptyQtyController.text = "";
      _grossWeightController.text = "";
      _itemNameController.text = "";
      finalDoqtyController.text = "";
      netweightController.text = "";
      packingqtycontroller.text = "";
      noofpackcontroller.text = "";
    });
  }

  void _formatTo3Decimal(TextEditingController controller) {
    final value = double.tryParse(controller.text);
    if (value != null) {
      controller.text = value.toStringAsFixed(3);
    }
  }

  Future<void> _whsselection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => WhsSelectionPage()),
    );
    if (result != null && result['WhsName'] != null) {
      setState(() {
        getWhs = result['WhsName'];
      });
    }
  }

  formula() {
    if (_emptyQtyController.text.isEmpty &&
        _grossWeightController.text.isEmpty) {
      return netweightController.text = "0";
    }
    double firstweight = _emptyQtyController.text.isEmpty
        ? 0
        : double.parse(_emptyQtyController.text);
    double firstgrossweight = _grossWeightController.text.isEmpty
        ? 0
        : double.parse(_grossWeightController.text);
    double firstnetweight = firstgrossweight - firstweight;
    netweightController.text = firstnetweight.toStringAsFixed(3).toString();
  }

  formula2() {
    if (netweightController.text.isEmpty && packingqtycontroller.text.isEmpty) {
      return finalDoqtyController.text = "0";
    }
    double firstnetweight = netweightController.text.isEmpty
        ? 0
        : double.parse(netweightController.text);
    double firstpacking = packingqtycontroller.text.isEmpty
        ? 0
        : double.parse(packingqtycontroller.text);

    double result = firstnetweight - firstpacking;
    finalDoqtyController.text = result.toStringAsFixed(3).toString();
  }
}

class PostItem {
  int? lineId;
  int? yardloadinglineId;
  String? itemcode;
  String? itemname;
  String? whs;
  double? emptyQty;
  double? grossWeight;
  double? finalDOQty;
  double? netWeight;
  int? baseEntry;
  int? baseLine;
  String? baseType;
  double? packingWeight;
  String? packingtype;
  String? packingtypeName;
  int? noofpack;
  String? sealNo;
  String? vechicleNo;
  String? weighNo;

  PostItem(
      this.lineId,
      this.yardloadinglineId,
      this.itemcode,
      this.itemname,
      this.whs,
      this.emptyQty,
      this.grossWeight,
      this.finalDOQty,
      this.netWeight,
      this.baseEntry,
      this.baseLine,
      this.baseType,
      this.packingWeight,
      this.packingtype,
      this.packingtypeName,
      this.noofpack,
      this.sealNo,
      this.vechicleNo,
      this.weighNo);

  PostItem.fromJson(Map<String, dynamic> json) {
    lineId = json['lineId'];
    yardloadinglineId = json['yardloadinglineId'];
    itemcode = json['itemCode'];
    itemname = json['itemName'];
    whs = json['whs'];
    emptyQty = json['emptyQry'];
    grossWeight = json['grossWght'];
    finalDOQty = json['finalDOqty'];
    netWeight = json['netWeight'];
    baseEntry = json['baseEntry'];
    baseLine = json['baseLine'];
    baseType = json['baseType'];
    packingWeight = json['packingWeight'];
    packingtype = json['packingType'];
    packingtypeName = json['packingtypeName'];
    noofpack = json['noofPack'];
    sealNo = json['sealNo'];
    vechicleNo = json['vechicleNo'];
    weighNo = json['weighNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lineId'] = lineId;
    data['yardloadinglineId'] = yardloadinglineId;
    data['itemCode'] = itemcode;
    data['itemName'] = itemname;
    data['whs'] = whs;
    data['emptyQry'] = emptyQty;
    data['grossWght'] = grossWeight;
    data['finalDOqty'] = finalDOQty;
    data['netWeight'] = netWeight;
    data['baseEntry'] = baseEntry;
    data['baseLine'] = baseLine;
    data['baseType'] = baseType;
    data['packingWeight'] = packingWeight;
    data['packingType'] = packingtype;
    data['packingtypeName'] = 'packingtypeName';
    data['noofPack'] = noofpack;
    data['sealNo'] = sealNo;
    data['vechicleNo'] = vechicleNo;
    data['weighNo'] = weighNo;
    return data;
  }
}
