import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/screens/dashboard/approval/alllclaimlist.dart';
import 'package:pgiconnect/screens/dashboard/pettycash/pettycashistall.dart';
import 'package:pgiconnect/screens/login/login/loginpage.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/screens/pricelistupdatescreen/pendingpricelist.dart';
import 'package:pgiconnect/screens/profile/profilepage.dart';
import 'package:pgiconnect/screens/yardunloading/yardunloading.dart';
import 'package:pgiconnect/screens/yardunloading/yardunloadingselectionlist.dart';
import 'package:pgiconnect/screens/yarnselectionlist.dart';
import 'package:pgiconnect/service/appcolor.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List imageSrc = [
    "assets/icons/loading.png",
    "assets/icons/unloading.png",
    "assets/icons/settlementicon.png",
    "assets/icons/wealth.png",
    "assets/icons/wealth.png",
    "assets/icons/logout.png",
  ];
  List titles = [
    "Yard Loading",
    "Yard Unloading",
    "Claim Approval",
    "Petty Cash",
    "Price List Update",
    "Logout",
  ];
  bool isDrawerOpen = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        // This will close the app
        if (Platform.isAndroid) {
          SystemNavigator.pop(); // For Android
        } else if (Platform.isIOS) {
          exit(0); // For iOS (use cautiously)
        }
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [dashBg, content],
        ),
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
                    'assets/icons/loading.png',
                    width: 20,
                    height: 20,
                  ),
                  title: const Text(
                    'Yard Unloading',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                YardUnloadingSelectionPage()));
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
                    CupertinoIcons.repeat,
                    size: 20,
                  ),
                  title: const Text(
                    'Price List Update',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => PendingPriceList()));
                  },
                ),
                // ListTile(
                //   leading: Image.asset(
                //     'assets/icons/priceupdate.png',
                //     width: 20,
                //     height: 20,
                //   ),
                //   title: const Text(
                //     'Price update',
                //     style: TextStyle(fontSize: 14.0),
                //   ),
                //   onTap: () {
                //     Navigator.pop(context);
                //   },
                // ),
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
      ),
    );
  }

  get dashBg => Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(color: Appcolor.primary),
          ),
          Expanded(
            flex: 5,
            child: Container(color: Colors.transparent),
          ),
        ],
      );

  get content => Container(
        child: Column(
          children: <Widget>[
            header,
            grid,
          ],
        ),
      );

  get header => ListTile(
        contentPadding:
            EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        leading: InkWell(
          onTap: () => _scaffoldKey.currentState!.openDrawer(),
          child: Icon(
            Icons.sort,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          Prefs.getFullName('Name').toString(),
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        // trailing: GestureDetector(
        //   onTap: () {
        //     Navigator.push(context,
        //         CupertinoPageRoute(builder: (context) => ProfileScreen()));
        //   },
        //   child: CircleAvatar(
        //     child: Icon(Icons.person),
        //   ),
        // ),
      );

  get grid => Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 10,
              ),
              itemCount: imageSrc.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (index == 0) {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => YarnSelectionPage()));
                    }
                    if (index == 1) {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  YardUnloadingSelectionPage()));
                    }
                    if (index == 2) {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => ClaimListPage()));
                    }

                    if (index == 3) {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => PettryCashList()));
                    }

                    if (index == 4) {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => PendingPriceList()));
                    }
                    if (index == 5) {
                      logout();
                    }
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Image.asset(
                            imageSrc[index],
                            width: 60,
                          ),
                          Text(titles[index])
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      );
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
}
