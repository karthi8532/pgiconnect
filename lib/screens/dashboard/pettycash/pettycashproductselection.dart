import 'dart:collection';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/itemModel.dart';
import 'package:pgiconnect/model/pettrycashitemmodel.dart';
import 'package:pgiconnect/screens/dashboard/whsselection.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';

class PettyCashSelectionScreen extends StatefulWidget {
  List<PostItemPettryCash> items;
  PettyCashSelectionScreen({super.key, required this.items});

  @override
  PettyCashSelectionScreenState createState() =>
      PettyCashSelectionScreenState();
}

class PettyCashSelectionScreenState extends State<PettyCashSelectionScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _remarks = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _approvernameController = TextEditingController();
  final TextEditingController _receivernameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  //List<PostItem> posteditem=[];
  final itemkey = GlobalKey<DropdownSearchState<PettyCashItemModel>>();
  String getItemCode = "";
  String getItemName = "";

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _remarks.dispose();
    _priceController.dispose();
    _approvernameController.dispose();
    _receivernameController.dispose();
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
                        DropdownSearch<PettyCashItemModel>(
                          key: itemkey,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            interceptCallBacks: true, //important line
                            itemBuilder: (ctx, item, isSelected) {
                              bool isDisabled = widget.items.any(
                                  (temp) => temp.itemcode == item.itemCode);
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
                                    setState(() {});
                                  });
                            },
                          ),
                          asyncItems: (String filter) =>
                              ApiService.getpettycashitemMaster(
                            Prefs.getDBName('DBName'),
                            Prefs.getBranchID('BranchID'),
                            filter: filter,
                          ),
                          itemAsString: (PettyCashItemModel item) =>
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
                                  controller: _priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true, signed: false),
                                  validator: (value) => value!.isNotEmpty
                                      ? null
                                      : "Price is Empty",
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 10.0),
                                    border: OutlineInputBorder(),
                                    hintText: "Price",
                                    labelText: "Price",
                                  ),
                                  onChanged: (val) {
                                    formula();
                                  }),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                  controller: _remarks,
                                  keyboardType: TextInputType.text,
                                  validator: (value) =>
                                      value!.isNotEmpty ? null : "Remarks",
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 10.0),
                                    border: OutlineInputBorder(),
                                    hintText: "Remarks ",
                                    labelText: "Remarks ",
                                  ),
                                  onChanged: (val) {
                                    formula();
                                  }),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                  controller: _approvernameController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) => value!.isNotEmpty
                                      ? null
                                      : "Approver Name is Empty",
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 10.0),
                                    border: OutlineInputBorder(),
                                    hintText: "Approver Name",
                                    labelText: "Approver Name",
                                  ),
                                  onChanged: (val) {
                                    formula();
                                  }),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                  controller: _receivernameController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) => value!.isNotEmpty
                                      ? null
                                      : "Receiver Name",
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 10.0),
                                    border: OutlineInputBorder(),
                                    hintText: "Receiver Name",
                                    labelText: "Receiver Name",
                                  ),
                                  onChanged: (val) {
                                    formula();
                                  }),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
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
                                    text: widget.items[index].price!
                                        .toStringAsFixed(2),
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.doc,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 15),
                                AppUtils.buildNormalText(
                                    text: widget.items[index].lineRemarks
                                        .toString(),
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.person,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 15),
                                AppUtils.buildNormalText(
                                    text:
                                        "Approver : ${widget.items[index].approvedByName.toString()}",
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.person,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 15),
                                AppUtils.buildNormalText(
                                    text:
                                        "Receiver : ${widget.items[index].receivedByName.toString()}",
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
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
    widget.items.add(PostItemPettryCash(
        getItemCode,
        getItemName,
        double.parse(_priceController.text.toString()),
        _remarks.text,
        "",
        _approvernameController.text,
        "",
        _receivernameController.text));
    setState(() {
      _priceController.text = "";
      _remarks.text = "";
      _approvernameController.text = "";
      _receivernameController.text = "";
    });
  }

  formula() {
    double price =
        _priceController.text.isEmpty ? 0 : double.parse(_priceController.text);
  }
}

class PostItemPettryCash {
  String? itemcode;
  String? itemname;
  double? price;
  String? lineRemarks;
  String? approvedByCode;
  String? approvedByName;
  String? receivedByCode;
  String? receivedByName;

  PostItemPettryCash(
      this.itemcode,
      this.itemname,
      this.price,
      this.lineRemarks,
      this.approvedByCode,
      this.approvedByName,
      this.receivedByCode,
      this.receivedByName);
}
