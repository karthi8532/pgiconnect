import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/countModel.dart';
import 'package:pgiconnect/screens/dashboard/approval/alllclaimlist.dart';
import 'package:pgiconnect/screens/dashboard/approval/approvalsubmit.dart';
import 'package:pgiconnect/screens/dashboard/pettycash/pettycashistall.dart';
import 'package:pgiconnect/screens/login/login/loginpage.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/screens/yarnselectionlist.dart';
import 'package:pgiconnect/service/appcolor.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ApiService apiService = ApiService();
  bool loading = false;
  CountModel countModel = CountModel();
  bool isDrawerOpen = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    getcount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Appcolor.primary,
        elevation: 2,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.sort, size: 20), // change this size and style
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: Row(
          children: [
            Text("Dashboard",
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
        actions: [
          const Icon(Icons.notifications_none, color: Colors.black),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTopCards(),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Other Documents",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildIconTile("Settlement", Icons.currency_rupee_sharp,
                    Colors.purple.shade200, 1),
                _buildIconTile("e-Way Bills", Icons.local_shipping,
                    Colors.blue.shade300, 2),
                _buildIconTile("Proforma Invoices", Icons.receipt,
                    Colors.brown.shade200, 3),
                _buildIconTile("Payment Receipts", Icons.receipt_long,
                    Colors.red.shade200, 4),
                _buildIconTile("Payments Made", Icons.payment, Colors.amber, 5),
                _buildIconTile("Debit Notes", Icons.money_off, Colors.teal, 6),
                _buildIconTile("Credit Notes", Icons.note, Colors.green, 7),
                _buildIconTile(
                    "Purchase Orders", Icons.shopping_cart, Colors.orange, 8),
                _buildIconTile(
                    "Delivery Challans", Icons.description, Colors.blue, 9),
                _buildIconTile(
                    "Inventory", Icons.inventory, Colors.lightBlueAccent, 10),
                _buildIconTile(
                    "Ledgers", Icons.book, Colors.brown.shade100, 11),
                _buildIconTile(
                    "Reports", Icons.article, Colors.green.shade300, 12),
                _buildIconTile("Expenses", Icons.folder, Colors.indigo, 13),
              ],
            ),
          ],
        ),
      ),
      // Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: SingleChildScrollView(
      //       child: Column(
      //         children: [
      //           WeeklyExpenseCard(),
      //           SizedBox(height: 20),
      //           DailyExpenseCard(),
      //           _buildCreateSection(context),
      //         ],
      //       ),
      //     ),
      //   )
      // : Center(
      //     child: ProgressWithIcon(),
      //   ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(
                      'assets/icons/avatar.png',
                    )),
                accountName: Text(
                  Prefs.getFullName('Name').toString(),
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                ),
                accountEmail: Text(
                  Prefs.getEmpID('Id').toString(),
                  style: TextStyle(fontSize: 12.0, color: Colors.black),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppUtils.buildNormalText(text: "Menus"),
              ),
              ListTile(
                leading: Image.asset(
                  'assets/icons/loading.png',
                  width: 20,
                  height: 20,
                ),
                title: const Text(
                  'Yard Loading',
                  style: TextStyle(fontSize: 14.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => YarnSelectionPage()));
                },
              ),
              ListTile(
                leading: Image.asset(
                  'assets/icons/settlementicon.png',
                  width: 20,
                  height: 20,
                ),
                title: const Text(
                  'Settlement',
                  style: TextStyle(fontSize: 14.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ClaimListPage()));
                },
              ),
              ListTile(
                leading: Image.asset(
                  'assets/icons/wealth.png',
                  width: 20,
                  height: 20,
                ),
                title: const Text(
                  'Petty Cash',
                  style: TextStyle(fontSize: 14.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => PettryCashList()));
                },
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.doc,
                  size: 20,
                ),
                title: const Text(
                  'Approval Form',
                  style: TextStyle(fontSize: 14.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Image.asset(
                  'assets/icons/priceupdate.png',
                  width: 20,
                  height: 20,
                ),
                title: const Text(
                  'Price update',
                  style: TextStyle(fontSize: 14.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppUtils.buildNormalText(text: "Settings"),
              ),
              ListTile(
                leading: Image.asset(
                  'assets/icons/ic_logout.png',
                  width: 20,
                  height: 20,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 14.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressed() {
    if (!isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    } else {
      Navigator.pop(context);
    }
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  void onPop() {
    if (isDrawerOpen) {
      setState(() {
        isDrawerOpen = false;
      });
    }
    Navigator.pop(context);
  }

  void logout() {
    Prefs.setLoggedIn("IsLoggedIn", false);
    Prefs.clear();
    Prefs.remove("remove");
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginPage()),
      ModalRoute.withName('/'),
    );
  }

  Widget _buildTopCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMainCard("Yard Loading", 'assets/icons/loading.png',
            Colors.yellow.shade700, 1),
        _buildMainCard(
            "Settelement", 'assets/icons/settlementicon.png', Colors.cyan, 2),
        _buildMainCard(
            "Petty Cash  ", 'assets/icons/wealth.png', Colors.blueGrey, 3),
      ],
    );
  }

  Widget _buildMainCard(String title, String icon, Color color, int position) {
    return Expanded(
      child: GestureDetector(
          onTap: () {
            if (position == 1) {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => YarnSelectionPage()));
            }
            if (position == 2) {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => ClaimListPage()));
            }
            if (position == 3) {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => PettryCashList()));
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
            ),
            child: Stack(
              clipBehavior: Clip.none, // Allows badge to overflow
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: color,
                      child: Image.asset(
                        icon,
                        color: Colors.white,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                // Badge positioned at top-right of CircleAvatar
                position == 1
                    ? Positioned(
                        top: -5, // Adjust to position properly
                        right: 15, // Adjust to position properly
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red, // Badge color
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            loading
                                ? ""
                                : countModel.result!.first.pendingCount
                                    .toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          )),
    );
  }

  Widget _buildIconTile(
      String label, IconData icon, Color color, int position) {
    return GestureDetector(
      onTap: () {
        if (position == 1) {
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => ClaimListPage()));
        }
      },
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 24,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateSection(context) {
    return _buildGridSection(
      title: "Dashboard",
      items: [
        _buildGridItem(context, 'assets/icons/loading.png', "Loading",
            countModel.result!.first.pendingCount ?? 0),
        _buildGridItem(context, 'assets/icons/unloading.png', "Unloading", 0),
        _buildGridItem(
            context, 'assets/icons/priceupdate.png', "Price update", 0),
        _buildGridItem(
            context, 'assets/icons/notebook.png', "Delivery Challan", 0),
        _buildGridItem(context, 'assets/icons/document.png', "Credit Note", 0),
        _buildGridItem(
            context, 'assets/icons/notebook.png', "Purchase Order", 0),
        _buildGridItem(context, 'assets/icons/document.png', "Expenses", 0),
        _buildGridItem(context, 'assets/icons/notebook.png', "Invoice", 0),
      ],
    );
  }

  Widget _buildGridSection(
      {required String title, required List<Widget> items}) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            children: items,
          ),
        ],
      ),
    );
  }

  // Grid Item
  Widget _buildGridItem(
      BuildContext context, String icon, String label, int count) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => YarnSelectionPage()));
      },
      child: Column(
        children: [
          count > 0
              ? Container(
                  child: Badge(
                    label: Text(count.toString()),
                    child: Image.asset(
                      icon,
                      width: 30,
                      height: 30,
                    ),
                  ),
                )
              : Image.asset(
                  icon,
                  width: 30,
                  height: 30,
                ),
          const SizedBox(height: 5),
          Text(label,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
      // child: ListTile(
      //     leading: Stack(
      //       children: [
      //         Image.asset(
      //           icon,
      //           width: 30,
      //           height: 30,
      //         ),
      //         Positioned(
      //           bottom: 0,
      //           right: 0,
      //           child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
      //         ),
      //       ],
      //     ),
      //     title: Text(label,
      //         textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
    );
  }

  void getcount() async {
    setState(() {
      loading = true;
    });

    apiService
        .getdashboardcount(
            Prefs.getDBName('DBName'), Prefs.getBranchID('BranchID'))
        .then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        countModel = CountModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        setState(() {
          loading = false;
        });
        countModel == null;
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

  void onexitpopup() {
    Navigator.of(context).pop();
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

// ---------------------- Weekly Expense Card ----------------------
class WeeklyExpenseCard extends StatelessWidget {
  const WeeklyExpenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Weekly Loading/Un-Loading",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                // ElevatedButton(
                //   onPressed: () {},
                //   child: Text(
                //     "View Report",
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  child: Center(child: Text('View Report')),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text("From 1 - 6 Apr, 2024",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 15),
            WeeklyBubbleChart(),
            SizedBox(height: 15),
            Divider(
              color: Colors.grey.shade200,
            ),
            ExpenseCategoryRow("Loading", "\$758.20", Colors.purple),
            ExpenseCategoryRow("Un-Loading", "\$758.20", Colors.green),
            ExpenseCategoryRow("Reject", "\$758.20", Colors.red),
            ExpenseCategoryRow("Hold", "\$758.20", Colors.orange),
          ],
        ),
      ),
    );
  }
}

// ---------------------- Daily Expense Card ----------------------
class DailyExpenseCard extends StatelessWidget {
  const DailyExpenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Daily Loading/Un-Loading",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  child: Center(child: Text('View Report')),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text("Data from 1-12 Apr, 2024",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 15),
            DailyBarChart(),
            SizedBox(height: 15),
            Divider(
              color: Colors.grey.shade200,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LegendItem(color: Colors.purple, label: "Loading"),
                LegendItem(color: Colors.green, label: "Un-Loading"),
                LegendItem(color: Colors.orange, label: "Hold"),
                LegendItem(color: Colors.red, label: "Reject"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- Weekly Expense Bubble Chart ----------------------
class WeeklyBubbleChart extends StatelessWidget {
  const WeeklyBubbleChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 15,
        alignment: WrapAlignment.center,
        children: [
          ExpenseBubble(
            percentage: "48%",
            color: Color(0XFFc8b6fb),
            size: 80,
            textColor: Colors.purple,
          ),
          ExpenseBubble(
            percentage: "32%",
            color: Color(0XFF9cf7cf),
            size: 60,
            textColor: Colors.green,
          ),
          ExpenseBubble(
            percentage: "13%",
            color: Color(0XFFfab4be),
            size: 50,
            textColor: Colors.red,
          ),
          ExpenseBubble(
            percentage: "7%",
            color: Color(0XFFfccd95),
            size: 40,
            textColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class ExpenseBubble extends StatelessWidget {
  final String percentage;
  final Color color;
  final double size;
  final Color textColor;
  const ExpenseBubble(
      {super.key,
      required this.percentage,
      required this.color,
      required this.size,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
      child: Center(
          child: Text(percentage,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor))),
    );
  }
}

// ---------------------- Daily Expense Bar Chart ----------------------
class DailyBarChart extends StatelessWidget {
  const DailyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            _barGroup(1, [4, 6, 2, 5]),
            _barGroup(2, [3, 4, 1, 6]),
            _barGroup(3, [6, 2, 3, 4]),
            _barGroup(4, [5, 3, 2, 5]),
            _barGroup(5, [4, 5, 3, 6]),
            _barGroup(6, [6, 3, 2, 4]),
            _barGroup(7, [5, 4, 1, 5]),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(),
                        style: TextStyle(fontSize: 12));
                  }),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, List<double> values) {
    List<Color> colors = [
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.orange
    ];
    return BarChartGroupData(
      x: x,
      barRods: List.generate(
        values.length,
        (i) => BarChartRodData(toY: values[i], color: colors[i], width: 10),
      ),
    );
  }
}

// ---------------------- Utility Widgets ----------------------
class ExpenseCategoryRow extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const ExpenseCategoryRow(this.title, this.amount, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: CircleAvatar(radius: 5, backgroundColor: color)),
              Expanded(flex: 6, child: Text(title)),
              Expanded(flex: 3, child: Text(amount))
            ],
          ),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
