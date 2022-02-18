import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'email.dart';
import 'invitation.dart';
import 'mobile.dart';
import 'name.dart';
import 'otp.dart';

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
                      },
                      child: Icon(Icons.arrow_back),
                    )
                  : SizedBox(),
      Consumer<UserProvider>(
        builder: (_, prov, __) => userProvider.currentIndex != 0
            ?   FloatingActionButton(
                onPressed: () {
                if(!prov.isLoading){
                  if(userProvider.currentIndex ==0){
                    userProvider.controller.animateToPage(1,  duration: Duration(milliseconds: 500), curve: Curves.ease);
                  }else if(userProvider.currentIndex ==1){
                    if(userProvider.usermobile.text.isEmpty){
                      Fiberchat.toast('Please enter mobile number !');
                    }else{
                      userProvider.verifyPhoneNumber(context,widget.isaccountapprovalbyadminneeded, widget.accountApprovalMessage,widget.prefs,widget.issecutitysetupdone);
                    }

                  }else if(userProvider.currentIndex ==2){
                    userProvider.controller.animateToPage(3,  duration: Duration(milliseconds: 500), curve: Curves.ease);

                  }else if(userProvider.currentIndex ==3){
                    if(userProvider.otpfield.text.length!=6){
                      Fiberchat.toast('Enter valid otp !');
                    }else{
                      userProvider.controller.animateToPage(4,  duration: Duration(milliseconds: 500), curve: Curves.ease);

                    }

                  }else if(userProvider.currentIndex ==4){

                    userProvider.username.text=userProvider.firstname.text+userProvider.lastname.text;
                    print(userProvider.codeverify);
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
                    itemCount: 5,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      return Container(
                        child: i == 0
                            ? InvitationWidget()
                            : i == 1?MobileWidget(
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
                                : i == 2
                                    ? EmailWiget()
                                    : i == 3
                                        ? OtpWidget()
                                        : i == 4
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
