import "dart:async";

import "package:country_code_picker/country_code_picker.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:opencv_flutter_bridge/main.dart";

class VerifyEmail extends StatefulWidget {
  final String email;

  const VerifyEmail({super.key, required this.email});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool emailVerified = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        setState(() {
          emailVerified = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 17.0),
              child: Text(
                "We have send an email verification link to ${widget.email}, Please Verify your Email Address",
                style: const TextStyle(
                  color: Color(0xFF475466),
                  fontSize: 20,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  // height: 0.07,
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 45,
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color:
                    emailVerified ? Color(0xFF3481FF) : const Color(0xFFF2F4F7),
              ),
              child: TextButton(
                onPressed: emailVerified
                    ? () {
                        print("email is verified");

                        /// go to main dashboard
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MyHomePage(title: "Flutter Open CV")),
                        );
                      }
                    : null,
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: Center(
                  child: Text(
                    'Let\'s know more about you',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      color: emailVerified
                          ? Colors.white
                          : const Color(0xFF98A2B3),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if (!emailVerified)
              Text(
                "Please verify your email address, to proceed",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  // height: 0.07,
                ),
              )
          ],
        ),
      ),
    );
  }
}
