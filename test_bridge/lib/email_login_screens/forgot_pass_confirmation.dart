import "dart:async";

import "package:country_code_picker/country_code_picker.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:opencv_flutter_bridge/email_login_screens/email_login.dart";

class ForogtPasswordMailConfirmation extends StatefulWidget {
  final String email;

  const ForogtPasswordMailConfirmation({super.key, required this.email});

  @override
  State<ForogtPasswordMailConfirmation> createState() =>
      _ForogtPasswordMailConfirmationState();
}

class _ForogtPasswordMailConfirmationState
    extends State<ForogtPasswordMailConfirmation> {
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
                "We have sent a link to your email address (${widget.email}). Please use this link to reset your password and then log in with your new password.",
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
                color: Color(0xFF3481FF),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmailLoginPage(
                              countryCode: CountryCode.fromCountryCode("IN"),
                              phone: '',
                            )),
                  );
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: const Center(
                  child: Text(
                    'Login with new password',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
