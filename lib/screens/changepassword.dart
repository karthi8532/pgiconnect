import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/screens/login/login/loginpage.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/service/appcolor.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController newpasswordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();
  final bool _obscureText1 = true;
  bool _obscureText2 = true;
  bool _obscureText3 = true;
  bool loading = false;
  @override
  void dispose() {
    newpasswordcontroller.dispose();
    confirmpasswordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: AppUtils.buildNormalText(
            text: 'Change Password',
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
      body: !loading
          ? SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                height: MediaQuery.of(context).size.height - 250,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/changepasswordimg.png',
                          height: 200,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        TextFormField(
                          controller: newpasswordcontroller,
                          obscureText: _obscureText2,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: "Enter New Password",
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 1),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText2 = !_obscureText2;
                                });
                              },
                              child: Icon(
                                _obscureText2
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Appcolor.black,
                                semanticLabel: _obscureText2
                                    ? 'show password'
                                    : 'hide password',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: confirmpasswordcontroller,
                          obscureText: _obscureText3,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: Colors.black26, width: 1),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText3 = !_obscureText3;
                                });
                              },
                              child: Icon(
                                _obscureText3
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Appcolor.black,
                                semanticLabel: _obscureText3
                                    ? 'show password'
                                    : 'hide password',
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    changePasswordbtn(size),
                  ],
                ),
              ),
            )
          : Center(child: const CircularProgressIndicator()),
    );
  }

  void exitpopup() {
    Navigator.of(context).pop();
  }

  Widget changePasswordbtn(Size size) {
    return GestureDetector(
      onTap: () {
        if (newpasswordcontroller.text.isEmpty) {
          AppUtils.showSingleDialogPopup(context,
              "New password Should not left empty!", "Ok", exitpopup, null);
        } else if (confirmpasswordcontroller.text.isEmpty) {
          AppUtils.showSingleDialogPopup(context,
              "Confirm password Should not left empty!", "Ok", exitpopup, null);
        } else if (newpasswordcontroller.text.toString() !=
            confirmpasswordcontroller.text.toString()) {
          AppUtils.showSingleDialogPopup(context,
              "New and Confirm password Mismatch!", "Ok", exitpopup, null);
        } else if (confirmpasswordcontroller.text.toString().length < 4 ||
            newpasswordcontroller.text.toString().length < 4) {
          AppUtils.showSingleDialogPopup(
              context,
              "Password Length minimum 4 character or number",
              "Ok",
              exitpopup,
              null);
        } else {
          updateloginpassword();
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), color: Appcolor.primary),
        child: Text(
          'Update Password',
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void updateloginpassword() async {
    setState(() {
      loading = true;
    });
    ApiService.updatepassword(
      Prefs.getDBName('DBName'),
      Prefs.getBranchID('BranchID'),
      Prefs.getEmpID('Id').toString(),
      confirmpasswordcontroller.text.toString(),
    ).then((response) {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['success'].toString() == "true") {
          AppUtils.showSingleDialogPopup(context,
              jsonDecode(response.body)['message'], "Ok", oncloseapp, null);
        } else {
          AppUtils.showSingleDialogPopup(context,
              jsonDecode(response.body)['message'], "Ok", exitpopup, null);
        }
      } else {
        throw Exception(jsonDecode(response.body)['message'].toString());
      }
    }).catchError((e) {
      setState(() {
        loading = false;
      });
      AppUtils.showSingleDialogPopup(
          context, e.toString(), "Ok", exitpopup, null);
    });
  }

  void oncloseapp() {
    Navigator.of(context).pop();
    Prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false);
  }
}
