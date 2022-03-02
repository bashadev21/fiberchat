import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/new_auth_screens/mainview.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/unawaited.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'email.dart';
import 'invitation.dart';
import 'mobile.dart';
import 'name.dart';
import 'otp.dart';

class FirstViewAuth extends StatefulWidget {
  FirstViewAuth(
      {Key? key,
      this.title,
      required this.issecutitysetupdone,
      required this.isaccountapprovalbyadminneeded,
      required this.accountApprovalMessage,
      required this.prefs,
      required this.isblocknewlogins})
      : super(key: key);
  final String? title;
  final bool issecutitysetupdone;
  final bool? isblocknewlogins;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  @override
  _FirstViewAuthState createState() => _FirstViewAuthState();
}

class _FirstViewAuthState extends State<FirstViewAuth> {
  proceedSignUp(context) {
    unawaited(Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
            builder: (context) => new MainViewAuth(
                  prefs: widget.prefs,
                  accountApprovalMessage: widget.accountApprovalMessage,
                  isaccountapprovalbyadminneeded:
                      widget.isaccountapprovalbyadminneeded,
                  isblocknewlogins: widget.isblocknewlogins,
                  title: 'Main View',
                  issecutitysetupdone: widget.issecutitysetupdone,
                ))));
  }

  proceedSignIn(context) {}

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    onPressed: () {
                      proceedSignIn(context);
                    },
                    color: fiberchatBlue,
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      proceedSignUp(context);
                    },
                    color: Colors.orangeAccent,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: s.height / 5),
              Column(
                children: [
                  SizedBox(
                    width: s.width / 3,
                    child: Image.asset('assets/images/applogo_white.jpeg'),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'PUNK',
                      style: TextStyle(
                        color: fiberchatBlue,
                        fontSize: 30,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'PANDA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: fiberchatBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                    ),
                    child: Text('Use it - Share it - Own it'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
