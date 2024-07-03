import 'package:country_code_picker/src/country_code.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;

import 'create_account.dart';
import 'forget_password.dart';

class EmailLoginPage extends StatefulWidget {
  final String phone;
  final CountryCode? countryCode;

  EmailLoginPage({super.key, required this.countryCode, required this.phone});

  bool isPasswordVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  bool isButtonEnabled = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    widget.emailController.addListener(updateButtonState);
    widget.passwordController.addListener(updateButtonState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: 354,
          padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your Email",
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                  color: Color(0xFF475467),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: widget.emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    hintText: "Enter Your Email",
                    hintStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      color: Color(0xFF98A2B3),
                    ),
                    errorStyle: TextStyle(height: 0.3),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: widget.passwordController,
                  obscureText: !widget.isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Password",
                    suffixIcon: InkWell(
                      splashColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: Icon(
                        widget.isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: widget.isPasswordVisible
                            ? Color(0xFF3481FF)
                            : Colors.grey.shade600,
                      ),
                      onTap: () {
                        setState(() {
                          widget.isPasswordVisible = !widget.isPasswordVisible;
                        });
                      },
                    ),
                    hintStyle: const TextStyle(
                      fontFamily: 'SF Pro',
                      color: Color(0xFF98A2B3),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      /// navigate to forgot password
                      // Navigator.pushNamed(context, Routes.forgotPasswordScreen,
                      //     arguments: {
                      //       "countryCode": widget.countryCode,
                      //       "phone": widget.phone
                      //     });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgetPassword(
                                  phone: widget.phone,
                                  countryCode: widget.countryCode,
                                )),
                      );
                      // Get.to(
                      // ForgetPassword(
                      //   countryCode: widget.countryCode,
                      //   phone: widget.phone,
                      // ),
                      // );
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: const Text(
                      "Forgot Password ?",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                        color: Color(0xFF98A2B3),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              if (errorMessage != null)
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/image/red.svg',
                      width: 16,
                      height: 16,
                      fit: BoxFit.scaleDown,
                    ),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isButtonEnabled
                      ? const Color(0xFF3481FF)
                      : const Color(0xFFF2F4F7),
                ),
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: isButtonEnabled
                      ? widget.isLoading
                          ? null
                          : () async {
                              setState(() {
                                widget.isLoading = true;
                              });

                              checkUserHasEmailData();
                            }
                      : null,
                  child: Center(
                    child: isButtonEnabled
                        ? widget.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Continue',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: isButtonEnabled
                                      ? Colors.white
                                      : const Color(0xFF3481FF),
                                ),
                              )
                        : Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                              color: isButtonEnabled
                                  ? Colors.white
                                  : const Color(0xFF98A2B3),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: const Color(0xFFF2F4F7),
                ),
                child: TextButton(
                  onPressed: () {
                    /// navigate to login screen
                    //  Get.offAll(() => Login());
                    // Navigator.pushReplacementNamed(context, Routes.loginScreen);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => LoginSc),
                    // );
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: const Center(
                    child: Center(
                      child: Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                          color: Color(0xFF98A2B3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    "New to PathFinder? ",
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF475467),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      /// navigate to register screen
                      // Navigator.pushNamed(
                      //   context,
                      //   Routes.createAccountScreen,
                      //   arguments: {
                      //     'phone': widget.phone,
                      //     'countryCode': widget.countryCode,
                      //   },
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterNow(
                                  phone: widget.phone,
                                  countryCode: widget.countryCode,
                                )),
                      );
                      // await Get.to(() => RegisterNow(
                      //       phone: widget.phone,
                      //       countryCode: widget.countryCode,
                      //     ));
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                        color: Color(0xFF3481FF),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void updateButtonState() {
    setState(() {
      isButtonEnabled = widget.emailController.text.isNotEmpty &&
          widget.passwordController.text.isNotEmpty;
      errorMessage = null;
    });
  }

  // This function is used to login a user if user data is not updated yet this will make ask the user to fill all it details before using the app.
  void checkUserHasEmailData() {
    /// checks user count via email

    Map getJsonData() {
      Map<dynamic, dynamic> jsonData = {
        "user_email": widget.emailController.text
      };
      return jsonData;
    }

    var name = '';
    var email = '';
    var userId = '';
    var phoneNumber = '';
    try {
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      print("e>>>> ${e.code == "invalid-credential"}");
      if (e.code == 'user-not-found') {
        setState(() {
          errorMessage = 'Account does not exist.';
        });
      } else if (e.code == "invalid-credential") {
        setState(() {
          errorMessage = 'Invalid credentials';
          widget.isLoading = false;
        });
      }
      if (widget.emailController.text.isEmpty ||
          widget.passwordController.text.isEmpty) {
        errorMessage = "Please fill all details";
      } else {
        setState(() {
          errorMessage = 'Check your email or password';
        });
      }
    }
  }
}
