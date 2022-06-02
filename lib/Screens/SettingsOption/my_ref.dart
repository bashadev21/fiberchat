import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

import '../../Configs/Enum.dart';
import '../../Configs/app_constants.dart';
import '../../Services/Providers/user_provider.dart';
import '../../Services/localization/language_constants.dart';

class MyRef extends StatefulWidget {
  const MyRef({Key? key}) : super(key: key);

  @override
  _MyRefState createState() => _MyRefState();
}

class _MyRefState extends State<MyRef> {
  var useremail='';
  @override
  void initState() {


    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 24,
            color: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatWhite
                : fiberchatBlack,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: DESIGN_TYPE == Themetype.whatsapp
            ? fiberchatDeepGreen
            : fiberchatWhite,
        title: Text(
          'My referrals',
          style: TextStyle(
              color: DESIGN_TYPE == Themetype.whatsapp
                  ? fiberchatWhite
                  : fiberchatBlack,
              fontSize: 18.5),
        ),
      ),
      body: WebView(
        initialUrl: 'http://www.pandasapi.com/panda_chat/api/my_referrals?reg_em=${userProvider.adminemail}&ref_code=${userProvider.ref_code_ID}',
      ),
    );
  }
}
