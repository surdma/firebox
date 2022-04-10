import 'dart:io';

import 'package:fire_box/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum VerificationState { showMobile, showOTPScreen }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  VerificationState currentState = VerificationState.showMobile;

  final _numberController = TextEditingController();
  final _otpController = TextEditingController();
  late ConfirmationResult _confirmationResult;

  var _verificationID;
  bool showLoading = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Container(
        child: showLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : currentState == VerificationState.showMobile
                ? _loginScreen(context)
                : _otpScreen(context),
      ),
    );
  }

  _loginScreen(context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              "LOGIN",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _numberController,
                    maxLength: 10,
                    decoration: InputDecoration(
                      prefix: const Text("+234"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      counterText: "",
                      label: const Text("Phone Number"),
                      contentPadding: const EdgeInsets.only(
                        left: 10,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        showLoading = true;
                      });

                      if (Platform.isLinux || Platform.isWindows) {
                        _confirmationResult =
                            await _firebaseAuth.signInWithPhoneNumber(
                                "+234" + _numberController.text);
                      } else {
                        await _firebaseAuth.verifyPhoneNumber(
                            phoneNumber: "+234" + _numberController.text,
                            verificationCompleted: (PhoneAuthCredential
                                phoneAuthCredential) async {
                              setState(() {
                                showLoading = false;
                              });
                            },
                            verificationFailed:
                                (FirebaseAuthException error) async {
                              debugPrint(error.message);
                            },
                            codeSent: (String verificationId,
                                int? forceResendingToken) async {
                              setState(() {
                                showLoading = false;
                                currentState = VerificationState.showOTPScreen;
                                _verificationID = verificationId;
                              });
                            },
                            codeAutoRetrievalTimeout:
                                (String verificationId) async {});
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 76, 199, 158),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _otpScreen(context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              "OTP SCREEN",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _otpController,
                    maxLength: 6,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      label: const Text("OTP Number"),
                      counterText: "",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      if (Platform.isLinux || Platform.isWindows) {
                        UserCredential _userCredential =
                            await _confirmationResult
                                .confirm(_otpController.text);
                      } else {
                        final _phoneAuthCredential =
                            PhoneAuthProvider.credential(
                                verificationId: _verificationID,
                                smsCode: _otpController.text);

                        signInWithPhone(_phoneAuthCredential);
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 76, 199, 158),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        "verify",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signInWithPhone(PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final _authCredential =
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
      setState(() {
        showLoading = false;
      });

      if (_authCredential.user != null) {
        debugPrint("Login successfully");
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      debugPrint(e.message);
    }
  }
}
