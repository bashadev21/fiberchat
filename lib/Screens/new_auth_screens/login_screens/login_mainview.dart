import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Screens/new_auth_screens/first_view.dart';
import 'package:fiberchat/Screens/new_auth_screens/login_screens/login_email.dart';
import 'package:fiberchat/Screens/new_auth_screens/login_screens/login_email_otp.dart';
import 'package:fiberchat/Screens/new_auth_screens/login_screens/login_mobile.dart';
import 'package:fiberchat/Screens/new_auth_screens/login_screens/login_mobile_otp.dart';
import 'package:fiberchat/Screens/new_auth_screens/mobile_otp.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginMainView extends StatefulWidget {
  LoginMainView(
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
  State<LoginMainView> createState() => _LoginMainViewState();
}

class _LoginMainViewState extends State<LoginMainView> {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 34),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              userProvider.loginViewIndex != 0
                  ? FloatingActionButton(
                      onPressed: () {
                        if (userProvider.currentIndex == 1) {
                          userProvider.loginViewController.animateToPage(0,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        } else if (userProvider.currentIndex == 2) {
                          userProvider.loginViewController.animateToPage(1,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        }
                      },
                      child: Icon(Icons.arrow_back),
                    )
                  : SizedBox(),
              Consumer<UserProvider>(
                  builder: (_, prov, __) => FloatingActionButton(
                        onPressed: () async {
                          if (userProvider.loginViewIndex == 0) {
                            var response =
                                await userProvider.checkIfAccountExists(
                                    userProvider.userEmail.text.trim());
                            if (response != null) {
                              var verificationResponse =
                                  await userProvider.sendVerificationEmail(
                                      userProvider.userEmail.text.trim(),
                                      '1.2.3.4');

                              if (verificationResponse != null) {
                                if (verificationResponse['status'] ==
                                    'SUCCESS') {
                                  userProvider.loginViewController
                                      .animateToPage(1,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease);
                                }
                                Fiberchat.toast(verificationResponse['msg']);
                              }

                              Fiberchat.toast(response['msg']);
                            }
                          } else if (userProvider.loginViewIndex == 1) {
                            if (userProvider.otpfield.text.length != 6) {
                              Fiberchat.toast('Enter valid otp !');
                            } else {
                              var verifyResult =
                                  await userProvider.verifyEmailOTP(
                                      userProvider.userEmail.text.trim(),
                                      userProvider.otpfield.text);

                              if (verifyResult != null) {
                                if (verifyResult['status'] == 'SUCCESS') {
                                  userProvider.loginViewController.animateToPage(2,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                }
                                Fiberchat.toast(verifyResult['msg']);
                              }
                            }
                          } else if (userProvider.loginViewIndex == 2) {
                            if (userProvider.usermobile.text.isEmpty) {
                              Fiberchat.toast('Please enter mobile number !');
                            } else {
                              userProvider.verifyPhoneNumber(
                                  context,
                                  widget.isaccountapprovalbyadminneeded,
                                  widget.accountApprovalMessage,
                                  widget.prefs,
                                  widget.issecutitysetupdone);

                              if (userProvider.isverficationsent) {
                                userProvider.loginViewController.animateToPage(
                                    3,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease);
                              }
                            }
                          } else if (userProvider.loginViewIndex == 3) {
                            userProvider.username.text =  widget.prefs.getString(Dbkeys.nickname).toString();
                            userProvider.handleSignIn(
                                context,
                                widget.isaccountapprovalbyadminneeded,
                                widget.accountApprovalMessage,
                                widget.prefs,
                                widget.issecutitysetupdone);
                          }
                        },
                        child: userProvider.isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Icon(userProvider.loginViewIndex == 2
                                ? Icons.check
                                : Icons.arrow_forward),
                      )),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Text(
                    'WELCOME TO PUNK PANDA',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: fiberchatBlue),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                    onPageChanged: (o) {
                      setState(() {
                        userProvider.loginViewIndex = o;
                      });
                    },
                    controller: userProvider.loginViewController,
                    itemCount: 4,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      return Container(
                        child: i == 0
                            ? LoginEmailWiget()
                            : i == 1
                                ? LoginEmailOtpWidget()
                                : i == 2
                                    ? LoginMobileWidget(
                                        issecutitysetupdone:
                                            widget.issecutitysetupdone,
                                        isaccountapprovalbyadminneeded: widget
                                            .isaccountapprovalbyadminneeded,
                                        accountApprovalMessage:
                                            widget.accountApprovalMessage,
                                        prefs: widget.prefs,
                                        isblocknewlogins:
                                            widget.isblocknewlogins)
                                    : i == 3
                                        ? LoginMobileOtpWidget()
                                        : Container(),
                      );
                    }),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
