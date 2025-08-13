import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/data/apiservice.dart';
import 'package:pgiconnect/model/loginModel.dart';
import 'package:pgiconnect/screens/login/utils/app_utils.dart';
import 'package:pgiconnect/service/appcolor.dart';
import 'package:pgiconnect/screens/dashboard/homepage.dart';
import 'package:pgiconnect/service/loadingservice.dart';
import 'package:pgiconnect/widgets/customimagewithindicator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiService apiService = ApiService();
  LoginModel model = LoginModel();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;
  LoadingService loadingService = LoadingService();
  bool hidePassword = true;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: !loading
            ? SingleChildScrollView(
                child: Container(
                  alignment: Alignment.center,
                  width: size.width,
                  height: size.height,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(221, 195, 49, 0.149),
                      Colors.white,
                      Colors.white,
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        //to give space from top
                        const Expanded(flex: 1, child: Center()),

                        //logo and text section
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              logo(size.height / 8, size.height / 8),
                              const SizedBox(
                                height: 16,
                              ),
                              richText(24),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Let’s login for explore continues',
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  color: const Color(0xFF969AA8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        //sign in google and facebook section
                        // Expanded(
                        //     flex: 2, child: signInGoogleFacebookButton(size)),
                        Expanded(flex: 2, child: Container()),

                        //email and password textField section
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              //email textField
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'User Id',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  emailTextField(size)
                                ],
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              //password textField
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Password',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  passwordTextField(size),
                                ],
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              //keep signed in and forget password section
                              //keepSigned_ForgetSection(),
                            ],
                          ),
                        ),

                        //sign in button section
                        Expanded(
                          flex: 1,
                          child: signInButton(size),
                        ),

                        //sign up text here
                        // Expanded(flex: 2, child: buildFooter(size)),
                      ],
                    ),
                  ),
                ),
              )
            : Center(child: ProgressWithIcon()));
  }

  Widget logo(double height_, double width_) {
    return Image.asset(
      'assets/images/pgilogo.png',
      height: height_,
      width: width_,
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 24.0,
          color: const Color(0xFF21899C),
          letterSpacing: 2.000000061035156,
        ),
        children: const [
          TextSpan(
            text: 'LOGIN',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'PAGE',
            style: TextStyle(
              color: Color(0xFFFE9879),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget emailTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        controller: emailController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          focusColor: Appcolor.primary,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          hintText: 'Enter your user ID',
          hintStyle: GoogleFonts.inter(
            fontSize: 14.0,
            color: const Color(0xFFABB3BB),
            height: 1.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget passwordTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        obscureText: hidePassword,
        controller: passwordController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: hidePassword
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
            onPressed: () {
              setState(() {
                hidePassword = !hidePassword;
              });
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          focusColor: Appcolor.primary,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          hintText: 'Enter your Password',
          hintStyle: GoogleFonts.inter(
            fontSize: 14.0,
            color: const Color(0xFFABB3BB),
            height: 1.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget keepSigned_ForgetSection() {
    return Row(
      children: <Widget>[
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              width: 0.7,
              color: const Color(0xFFD0D0D0),
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        Text(
          'Keep me signed in',
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: const Color(0xFFABB3BB),
            height: 1.17,
          ),
        ),
        Expanded(
          child: Text(
            'Forgot password?',
            style: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFFF56B3F),
              height: 1.17,
            ),
            textAlign: TextAlign.right,
          ),
        )
      ],
    );
  }

  Widget buildRemember(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: 17.0,
          height: 17.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            gradient: const LinearGradient(
              begin: Alignment(5.65, -1.0),
              end: Alignment(-1.0, 1.94),
              colors: [Color(0xFF00AD8F), Color(0xFF7BF4DF)],
            ),
          ),
          child: SvgPicture.string(
            // Vector 5
            '<svg viewBox="47.0 470.0 7.0 4.0" ><path transform="translate(47.0, 470.0)" d="M 0 1.5 L 2.692307710647583 4 L 7 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" /></svg>',
            width: 7.0,
            height: 4.0,
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        Text(
          'Remember me',
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget signInButton(Size size) {
    return GestureDetector(
      onTap: () {
        if (emailController.text.isEmpty) {
          AppUtils.showSingleDialogPopup(context, "Please Enter User ID", "Ok",
              () {
            AppUtils.pop(context);
          }, null);
        } else if (passwordController.text.isEmpty) {
          AppUtils.showSingleDialogPopup(context, "Please Enter User ID", "Ok",
              () {
            AppUtils.pop(context);
          }, null);
        } else {
          postLogin();
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0), color: Appcolor.primary),
        child: Text(
          'Sign In',
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

  Widget buildFooter(Size size) {
    return Center(
      child: Text.rich(
        TextSpan(
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: Colors.black,
          ),
          children: const [
            TextSpan(
              text: 'Don’t have an account? ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: 'Sign Up here',
              style: TextStyle(
                color: Color(0xFFFF7248),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void postLogin() async {
    setState(() {
      loading = true;
    });
    var body = {
      "userID": emailController.text,
      "password": passwordController.text
    };

    apiService.getloginRequest(body).then((response) async {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200 || response.statusCode < 300) {
        if (jsonDecode(response.body)['success'].toString() == "true") {
          model = LoginModel.fromJson(jsonDecode(response.body));
          await Prefs.setEmpID("Id", model.user!.userId.toString());
          await Prefs.setLoginID("ID", model.user!.empID.toString());
          await Prefs.setFullName("Name", model.user!.employeName.toString());
          await Prefs.setToken("token", model.token!.accessToken.toString());
          await Prefs.setLoggedIn("IsLoggedIn", true);
          await Prefs.setDBName('DBName', model.user!.dBName.toString());
          await Prefs.setBranchID('BranchID', model.user!.branch!);
          await Prefs.setBranchName(
              'BranchName', model.user!.branchName.toString());
          await Prefs.setWeighLocationID(
              'WeighLocationID', model.user!.weigLocid.toString());
          await Prefs.setWeighLocationName(
              'WeighLocationName', model.user!.weigLocname.toString());

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          model.message = null;
          AppUtils.showSingleDialogPopup(
              context,
              jsonDecode(response.body)['message'].toString(),
              "Ok",
              onexitpopup,
              null);
        }
      } else if (response.statusCode == 404) {
        AppUtils.showSingleDialogPopup(
          context,
          "Login API not found (404). Please contact support or check the URL.",
          "Ok",
          onexitpopup,
          null,
        );
      } else {
        setState(() {
          loading = false;
        });
        AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message']?.toString() ??
                "Something went wrong.",
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

  Future addsharedpref(LoginModel model) async {
    await Prefs.setLoggedIn("isLogged", true);
    await Prefs.setFullName("fullName", "");

    await Prefs.setEmpID("Id", model.user!.empID.toString());
    await Prefs.setToken("token", model.token.toString());

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => DashboardScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void onexitpopup() {
    Navigator.of(context).pop();
  }
}
