import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginEmailWiget extends StatelessWidget {
  LoginEmailWiget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _h = MediaQuery.of(context).size.height;
    final _w = MediaQuery.of(context).size.width;

    final UserProvider userProvider = Provider.of<UserProvider>(context);

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
                      'Enter your E-mail id ',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                InpuTextBox(
                  inputFormatter: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  controller: userProvider.userEmail,
                  leftrightmargin: 0,
                  showIconboundary: false,
                  boxcornerradius: 5.5,
                  boxheight: 50,
                  hinttext: 'email',
                  // hinttext:
                  // getTranslated(context, 'name_hint'),
                  prefixIconbutton: Icon(
                    Icons.mail,
                    color: Colors.grey.withOpacity(0.5),
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
                      style: TextStyle(color: fiberchatBlue, fontSize: 21),
                    ),
                  ],
                ),
                Text(
                  'Ensure you enter the right email id as you will receive OTP',
                  style: TextStyle(fontSize: 19),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ));
  }
}
