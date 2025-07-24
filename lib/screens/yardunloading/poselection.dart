// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pgiconnect/data/apiservice.dart';
// import 'package:pgiconnect/model/dbmodel.dart';
// import 'package:pgiconnect/model/poselectionmodel.dart';
// import 'package:pgiconnect/screens/dashboard/goodsreceipt/searchwidget.dart';
// import 'package:pgiconnect/screens/login/utils/app_utils.dart';
// import 'package:pgiconnect/service/appcolor.dart';
// import 'package:pgiconnect/widgets/customimagewithindicator.dart';

// class PoSelectionPage extends StatefulWidget {
//   const PoSelectionPage({super.key});

//   @override
//   State<PoSelectionPage> createState() => _PoSelectionPageState();
// }

// class _PoSelectionPageState extends State<PoSelectionPage> {
//   TextEditingController searchController = TextEditingController();
//   bool loading = false;
//   List<PoModel> polist = [];
//   ApiService apiService = ApiService();

//   @override
//   void initState() {
//     getpolist();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.grey[200],
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Text('Select Branch'),
//         ),
//         body: !loading ? getBody() : Center(child: ProgressWithIcon()));
//   }

//   Widget getBody() {
//     var size = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         Searchbar(
//           controller: searchController,
//           onSearch: (query) => setState(() {}),
//           onClear: () {
//             searchController.clear();
//             setState(() {});
//           },
//         ),
//         Expanded(
//           child: _filterItems(searchController.text).isNotEmpty
//               ? ListView.builder(
//                   padding: EdgeInsets.all(8),
//                   itemCount: _filterItems(searchController.text).length,
//                   shrinkWrap: true,
//                   physics: ScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     final product = _filterItems(searchController.text)[index];
//                     return ListTile(
//                       leading: Stack(
//                         children: [
//                           CircleAvatar(
//                             radius: 20,
//                             backgroundColor: Appcolor.primary,
//                             child: Text(product.poEntry![0].toUpperCase(),
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 18)),
//                           ),
//                         ],
//                       ),
//                       title: Text(product.poNumber.toString(),
//                           style: TextStyle(
//                               fontWeight: FontWeight.normal, fontSize: 13)),
//                       onTap: () {
//                         var data = {
//                           "poNumber": product.poEntry,
//                           "poEntry": product.poNumber,
//                         };

//                         Navigator.pop(context, data);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text('Selected: ${product.poNumber}')),
//                         );
//                       },
//                     );
//                   },
//                 )
//               : Center(
//                   child: Text('No Data!'),
//                 ),
//         )
//       ],
//     );
//   }

//   List<PoModel> _filterItems(String query) {
//     return query.isEmpty
//         ? polist
//         : polist
//             .where((item) =>
//                 item.poEntry
//                     .toString()
//                     .toLowerCase()
//                     .contains(query.toString().toLowerCase()) ||
//                 item.poNumber
//                     .toString()
//                     .toLowerCase()
//                     .contains(query.toString().toLowerCase()))
//             .toList();
//   }

//   void getpolist() async {
//     setState(() {
//       loading = true;
//     });

//     apiService
//         .getpolist(
//       widget.cardCode,
//     )
//         .then((response) async {
//       setState(() {
//         loading = false;
//       });
//       if (response.statusCode == 200 || response.statusCode < 300) {
//         polist.clear();
//         polist = jsonDecode(response.body)['result']
//             .map<PoModel>((item) => PoModel.fromJson(item))
//             .toList();
//       } else if (response.statusCode == 401) {
//         setState(() {
//           loading = false;
//         });
//         AppUtils.showSingleDialogPopup(
//             context,
//             jsonDecode(response.body)['message'].toString(),
//             "Ok",
//             onexitpopup,
//             null);
//       }
//     }).catchError((e) {
//       setState(() {
//         loading = false;
//       });
//       String errorMessage = "";

//       if (e is TimeoutException) {
//         errorMessage =
//             "Request timed out. Please check your internet connection and try again.";
//       } else if (e is SocketException) {
//         errorMessage = "Network error. Please check your internet connection.";
//       } else {
//         errorMessage = e.toString();
//       }
//       AppUtils.showSingleDialogPopup(
//           context, errorMessage, "Ok", onexitpopup, null);
//     });
//   }

//   void onexitpopup() {
//     Navigator.of(context).pop();
//   }
// }
