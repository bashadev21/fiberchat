import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Screens/new_auth_screens/first_view.dart';
import 'package:fiberchat/Screens/new_auth_screens/mobile_otp.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'email.dart';
import 'invitation.dart';
import 'mobile.dart';
import 'name.dart';
import 'otp.dart';
import 'package:fiberchat/Utils/unawaited.dart';

class MainViewAuth extends StatefulWidget {

   MainViewAuth(
       {Key? key,
         this.title,
         required this.issecutitysetupdone,
         required this.isaccountapprovalbyadminneeded,
         required this.accountApprovalMessage,
         required this.prefs,
         required this.isblocknewlogins}) : super(key: key);
   final String? title;
   final bool issecutitysetupdone;
   final bool? isblocknewlogins;
   final bool? isaccountapprovalbyadminneeded;
   final String? accountApprovalMessage;
   final SharedPreferences prefs;

  @override
  State<MainViewAuth> createState() => _MainViewAuthState();
}

class _MainViewAuthState extends State<MainViewAuth> {

  sendVerificationEmail(String email, String ip_addr) async {
  var query_string = 'reg_em=' + email + '&ip_addr=' +  ip_addr;
  var response = await Dio().get('http://www.pandasapi.com/panda_chat/api/send_reg_otp?' + query_string);
   
    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint(data.toString());
      return jsonDecode(data);
    }
    else {
      Fiberchat.toast('some error occurred');
    }
  }

  verifyEmailOTP(String email, String otp) async {
    var query_string = 'reg_em=' + email + '&otp=' + otp;
    var response = await Dio().get('http://www.pandasapi.com/panda_chat/api/verify_reg_otp?' + query_string);
   
    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint(data.toString());
      return jsonDecode(data);
    }
    else {
      Fiberchat.toast('some error occurred');
    }
  }

  checkIfAccountExists(String email) async {
    var query_string = 'reg_em=' + email;
    var response = await Dio().get('http://www.pandasapi.com/panda_chat/api/check_em?' + query_string);
   
    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint(data.toString());
      return jsonDecode(data);
    }
    else {
      Fiberchat.toast('some error occurred');
    }
  }


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
              userProvider.currentIndex != 0
                  ? FloatingActionButton(
                      onPressed: () {
                        if(userProvider.currentIndex ==1){
                          userProvider.controller.animateToPage(0,  duration: Duration(milliseconds: 500), curve: Curves.ease);
                        }else if(userProvider.currentIndex ==2){
                          userProvider.controller.animateToPage(1,  duration: Duration(milliseconds: 500), curve: Curves.ease);

                        }else if(userProvider.currentIndex ==3){
                          userProvider.controller.animateToPage(2,  duration: Duration(milliseconds: 500), curve: Curves.ease);

                        }
                        else if(userProvider.currentIndex ==4){
                          userProvider.controller.animateToPage(3,  duration: Duration(milliseconds: 500), curve: Curves.ease);

                        }
                        else if(userProvider.currentIndex ==5){
                          userProvider.controller.animateToPage(4,  duration: Duration(milliseconds: 500), curve: Curves.ease);

                        }
                      },
                      child: Icon(Icons.arrow_back),
                    )
                  : SizedBox(),
      Consumer<UserProvider>(
        builder: (_, prov, __) => userProvider.currentIndex != 0
            ?   FloatingActionButton(
                onPressed: () async {
                if(!prov.isLoading){
                  if(userProvider.currentIndex ==0){
                    userProvider.controller.animateToPage(1,  duration: Duration(milliseconds: 500), curve: Curves.ease);
                  }else if(userProvider.currentIndex ==1){
                    if(userProvider.usermobile.text.isEmpty){
                      Fiberchat.toast('Please enter mobile number !');
                    }else{
                      userProvider.verifyPhoneNumber(context,widget.isaccountapprovalbyadminneeded, widget.accountApprovalMessage,widget.prefs,widget.issecutitysetupdone);
                      userProvider.controller.animateToPage(2,  duration: Duration(milliseconds: 500), curve: Curves.ease);
                    }
                  }
                  
                  else if(userProvider.currentIndex == 2){
                    userProvider.controller.animateToPage(3,  duration: Duration(milliseconds: 500), curve: Curves.ease);
                  }

                  else if(userProvider.currentIndex ==3){
                    var response = await checkIfAccountExists(userProvider.userEmail.text.trim());
                      if (response != null) {
                        if (response['status'] == 'SUCCESS') {
                              var verificationResponse = await sendVerificationEmail(userProvider.userEmail.text.trim(), '1.2.3.4');

                              if (verificationResponse != null) {
                                if (verificationResponse['status'] == 'SUCCESS') {
                                    userProvider.controller.animateToPage(4,  duration: Duration(milliseconds: 500), curve: Curves.ease);
                                }
                                Fiberchat.toast(verificationResponse['msg']);
                              }
                          }
                          Fiberchat.toast(response['msg']);
                      }
                     
                  }else if(userProvider.currentIndex ==4){
                    if(userProvider.otpfield.text.length!=6){
                      Fiberchat.toast('Enter valid otp !');
                    }else{
                      var verifyResult = await verifyEmailOTP(userProvider.userEmail.text.trim(), userProvider.otpfield.text);

                      if (verifyResult != null) {
                        if (verifyResult['status'] == 'SUCCESS') {
                            userProvider.controller.animateToPage(5,  duration: Duration(milliseconds: 500), curve: Curves.ease);
                        }
                        Fiberchat.toast(verifyResult['msg']);
                      }
                    }

                  }else if(userProvider.currentIndex ==5){
                    userProvider.username.text=userProvider.firstname.text+userProvider.lastname.text;
                    userProvider.handleSignIn( context, widget.isaccountapprovalbyadminneeded, widget.accountApprovalMessage, widget.prefs, widget.issecutitysetupdone);
                  }

                }
                },
                child:prov.isLoading?CircularProgressIndicator(
                  color: Colors.white,
                ): Icon(userProvider.currentIndex==4?Icons.check:Icons.arrow_forward),
              ):SizedBox()),
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
              // Row(
              //   children: [
              //     Text(
              //       'Sign-up step ${userProvider.currentIndex+1}/5',
              //       style: TextStyle(
              //         fontSize: 18,
              //       ),
              //     ),
              //   ],
              // ),
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
                       userProvider.currentIndex = o;
                     });

                    },
                    controller: userProvider.controller,
                    itemCount: 6,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      return Container(
                        child: i == 0
                            ? InvitationWidget()
                            : i == 1 ? MobileWidget(
                            prefs: widget.prefs,
                            accountApprovalMessage:
                            widget.accountApprovalMessage,
                            isaccountapprovalbyadminneeded:
                            widget.isaccountapprovalbyadminneeded,
                            isblocknewlogins:widget.isblocknewlogins,
                            title: getTranslated(context, 'signin'),
                            issecutitysetupdone:
                            widget.issecutitysetupdone,
                        )
                        //         ? LoginScreen(
                        //   prefs: widget.prefs,
                        //   accountApprovalMessage:
                        //   widget.accountApprovalMessage,
                        //   isaccountapprovalbyadminneeded:
                        //   widget.isaccountapprovalbyadminneeded,
                        //   isblocknewlogins:widget.isblocknewlogins,
                        //   title: getTranslated(context, 'signin'),
                        //   issecutitysetupdone:
                        //   widget.issecutitysetupdone,
                        //
                        // )    
                                : i == 2 ? MobileOtpWidget()
                                : i == 3
                                    ? EmailWiget()
                                    : i == 4
                                        ? OtpWidget()
                                        : i == 5
                                            ? NameWidget()
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
