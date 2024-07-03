// ignore_for_file: use_build_context_synchronously
// ignore: must_be_immutable

import "package:country_code_picker/country_code_picker.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_svg/flutter_svg.dart";

import "email_verify.dart";

// ignore: must_be_immutable
class RegisterNow extends StatefulWidget {
  final String phone;
  final CountryCode? countryCode;

  RegisterNow({super.key, required this.phone, this.countryCode});

  bool isPasswordVisible = false;

  bool isLoading = false;

  @override
  State<RegisterNow> createState() => _RegisterNowState();
}

class _RegisterNowState extends State<RegisterNow> {
  bool isButtonEnabled = false;
  String? errorMessage;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(updateButtonState);
    passwordController.addListener(updateButtonState);
  }

  void updateButtonState() {
    print("upfate");
    setState(() {
      isButtonEnabled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
      errorMessage = null;
    });
  }

  // This Function is used to create a new User using the email and the password send by the new user.
  void createUser() async {
    print("create");
    setState(() {
      widget.isLoading = true;
    });
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage = "Please fill all details";
      setState(() {
        widget.isLoading = false;
      });
    } else {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        )
            .then((_) async {
          print("user added");
          await FirebaseAuth.instance.currentUser!
              .sendEmailVerification()
              .onError((err, st) {
            print("err on seneding mail >>  $err");
            setState(() {
              errorMessage =
                  'Error sending verification link, please try again';
            });
          }).then((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyEmail(
                        email: emailController.text,
                      )),
            );
          });
        });

        /// navigate to varify email
        // Get.offAll(() => VerifyEmail(
        //   phone: widget.phone
        //   , countryCode: widget.countryCode,
        // ));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          setState(() {
            errorMessage = 'Account Already exists please login.';
          });
        } else if (e.code == 'weak-password') {
          setState(() {
            errorMessage = 'Weak password try some other password';
          });
        } else if (emailController.text.isEmpty ||
            passwordController.text.isEmpty) {
          errorMessage = "Please fill all details";
        }
      } finally {
        setState(() {
          widget.isLoading = false;
        });
      }
    }
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
                // height: 50,
                padding: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    hintText: "Enter Your Email",
                    hintStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      color: Color(0xFF98A2B3),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // password container
              Container(
                width: double.infinity,
                height: 50,
                padding: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: !widget.isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Create new Password",
                    suffixIcon: InkWell(
                      splashColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: Icon(
                        widget.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: widget.isPasswordVisible
                            ? const Color(0xFF3481FF)
                            : Color(0xFF98A2B3),
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
                  onPressed:
                      widget.isLoading || !isButtonEnabled ? null : createUser,
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'SF Pro',
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
              // back button
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: const Color(0xFFF2F4F7),
                ),
                child: TextButton(
                  onPressed: () {
                    /// get baack
                    Navigator.pop(context);
                    //  Get.back();
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
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                          color: Color(0xFF98A2B3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
