import 'dart:io';
import 'package:fiberchat/Models/E2EE/e2ee.dart' as e2ee;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Screens/homepage/homepage.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Services/localization/language.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/phonenumberVariantsGenerator.dart';
import 'package:fiberchat/Utils/unawaited.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class MobileWidget extends StatefulWidget {
   MobileWidget({Key? key,
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
  State<MobileWidget> createState() => _MobileWidgetState();
}

final _phoneNo = TextEditingController();
final TextEditingController con = TextEditingController();

class _MobileWidgetState extends State<MobileWidget> {
  @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {


    final _h = MediaQuery.of(context).size.height;
    final _w = MediaQuery.of(context).size.width;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    userProvider.setdeviceinfo();
    userProvider.seletedlanguage = Language.languageList()
        .where((element) => element.languageCode == 'en')
        .toList()[0];
    return Container(
      height: _h * .8,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Text(
                    'Enter your mobile number ',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Form(
                child: MobileInputWithOutline(
                  buttonhintTextColor: fiberchatGrey,
                  borderColor: fiberchatGrey.withOpacity(0.2),
                  controller: userProvider.usermobile,
                  initialCountryCode: DEFAULT_COUNTTRYCODE_ISO,
                  onSaved: (phone) {
                    setState(() {
                      userProvider.phoneCode = phone!.countryCode;
                    });
                  },
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Note:',
                    style: TextStyle(color: fiberchatBlue,fontSize:21),
                  ),
                ],
              ),
              Text(
                'Ensure you enter the correct mobile number and choose the right country code for smooth contact list sync',
                style: TextStyle(fontSize: 19),
              ),
            ],
          ),

          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

}
