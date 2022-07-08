import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';

class OtpWidget extends StatelessWidget {
   OtpWidget({Key? key}) : super(key: key);
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(
          color: fiberchatBlue,
          width: 2
      ),
      borderRadius: BorderRadius.circular(3.0),
    );
  }
  final TextEditingController tcon=TextEditingController();
  @override
  Widget build(BuildContext context) {
    final _h=MediaQuery.of(context).size.height;
    final _w=MediaQuery.of(context).size.width;
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      height: _h*.8,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Enter OTP sent to your E-mail id',style: TextStyle(
                  fontSize: 20
              ),),
              SizedBox(
                height: 8,
              ),

              PinPut(
                autofocus: true,
                 controller: userProvider.otpfield,
                  onChanged: (o) {
                    userProvider.codeverify=userProvider.otpfield.text;
                    print("otp ==>  ${userProvider.codeverify}");
                  },
                  eachFieldPadding: const EdgeInsets.all(10),
                  eachFieldHeight: 35,
                  eachFieldWidth: 35,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]')),
                  ],

                  followingFieldDecoration: BoxDecoration(
                    border: Border.all(
                        color: fiberchatBlue,
                        width: 2
                    ),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  keyboardType: TextInputType.number,
                  submittedFieldDecoration:
                  _pinPutDecoration.copyWith(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  selectedFieldDecoration: _pinPutDecoration,
                  fieldsCount: 6),
              SizedBox(
                height: 20,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Edit Email',style: TextStyle(
              //       color: Colors.red
              //     ),),
              //     Text('Re-send OTP',style: TextStyle(
              //         color: Colors.red
              //     ),),
              //   ],
              // )


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
              SizedBox(
                height: 10,
              ),
              Text(
                'Please check your inbox/spam for the OTP',
                style: TextStyle(fontSize: 19),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
