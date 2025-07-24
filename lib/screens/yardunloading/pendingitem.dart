import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/pendingunloaditemmodel.dart';
import 'package:pgiconnect/screens/dashboard/goodsreceipt/searchwidget.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/service/appcolor.dart';

class PendingItemScreen extends StatefulWidget {
  final String getDBName;
  final String getBranchID;
  // final String fromDate;
  // final String toDate;
  final String supplierId;
  final String supplierName;
  final String pickupNo;
  final String location;
  final String ticketNo;

  const PendingItemScreen(
      {super.key,
      required this.getDBName,
      required this.getBranchID,
      // required this.fromDate,
      // required this.toDate,
      required this.supplierId,
      required this.supplierName,
      required this.pickupNo,
      required this.location,
      required this.ticketNo});

  @override
  State<PendingItemScreen> createState() => _PendingItemScreenState();
}

class _PendingItemScreenState extends State<PendingItemScreen> {
  List<PendingItem> pendingItems = [];
  List<PendingItem> selectedItems = [];
  bool loading = false;
  String searchText = '';
  TextEditingController searchController = TextEditingController();

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    pendingitemget();
  }

  void pendingitemget() async {
    setState(() => loading = true);

    apiService
        .getpendingunloadingitesm(
      widget.getDBName,
      widget.getBranchID,
      // widget.fromDate,
      // widget.toDate,
      widget.supplierId,
      widget.supplierName,
      widget.pickupNo,
      widget.location,
      widget.ticketNo
    )
        .then((response) async {
      setState(() => loading = false);

      if (response.statusCode == 200 || response.statusCode < 300) {
        final body = jsonDecode(response.body);
        final result = body['result'];

        if (result != null && result is List) {
          pendingItems =
              result.map<PendingItem>((e) => PendingItem.fromJson(e)).toList();
        } else {
          pendingItems.clear();
        }
      } else {
        pendingItems.clear();
        AppUtils.showSingleDialogPopup(
          context,
          jsonDecode(response.body)['message'].toString(),
          "Ok",
          onexitpopup,
          null,
        );
      }
    }).catchError((e) {
      setState(() => loading = false);

      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = "Request timed out. Please check your internet.";
      } else if (e is SocketException) {
        errorMessage = "Network error. Please check your internet.";
      } else {
        errorMessage = e.toString();
      }

      AppUtils.showSingleDialogPopup(
          context, errorMessage, "Ok", onexitpopup, null);
    });
  }

  void onexitpopup() => AppUtils.pop(context);

  void toggleSelection(PendingItem item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }

  void navigateToNextScreen() {
    if (selectedItems.isEmpty) {
      AppUtils.showSingleDialogPopup(
        context,
        "Please select at least one item.",
        "Ok",
        onexitpopup,
        null,
      );
      return;
    }

    Navigator.pop(context, {'selectedItems': selectedItems});
  }

  List<PendingItem> get filteredItems {
    if (searchText.isEmpty) return pendingItems;

    return pendingItems.where((item) {
      final lower = searchText.toLowerCase();
      return item.itemName.toLowerCase().contains(lower) ||
          item.ticketNo.toLowerCase().contains(lower) ||
          item.customerName.toLowerCase().contains(lower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pending Items'),
        backgroundColor: Appcolor.primary,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Searchbar(
                  controller: searchController,
                  onSearch: (query) => setState(() {
                    searchText = query;
                  }),
                  onClear: () {
                    searchController.clear();
                    setState(() {
                      searchText = '';
                    });
                  },
                ),
                Expanded(
                  child: filteredItems.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final isSelected = selectedItems.contains(item);

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              title: Text(item.itemName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ticket No: ${item.ticketNo}'),
                                  Text('TRN Date: ${item.trnDate}'),
                                  Text('Customer Name: ${item.customerName}'),
                                  Text('Qty: ${item.quantity}'),
                                  Text('Price: ${item.unitPrice}'),
                                ],
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_box)
                                  : const Icon(Icons.check_box_outline_blank),
                              onTap: () => toggleSelection(item),
                            );
                          },
                        )
                      : const Center(child: Text('No matching results')),
                ),
              ],
            ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Appcolor.primary),
              onPressed: navigateToNextScreen,
              child: const Row(
                children: [
                  Text("Next",
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
