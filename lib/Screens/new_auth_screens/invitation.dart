import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';

class InvitationWidget extends StatefulWidget {
  const InvitationWidget({Key? key}) : super(key: key);

  @override
  State<InvitationWidget> createState() => _InvitationWidgetState();
}

class _InvitationWidgetState extends State<InvitationWidget> {
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(
          color: fiberchatBlue,
          width: 2
      ),
      borderRadius: BorderRadius.circular(3.0),
    );
  }
  final TextEditingController name=new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final _h=MediaQuery.of(context).size.height;
    final _w=MediaQuery.of(context).size.width;

    return Container(
      height: _h*.8,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Enter Pandapal invitation code',style: TextStyle(
                fontSize: 20
              ),),
              SizedBox(
                height: 8,
              ),

              PinPut(
                  controller: userProvider.refCode,
                  onChanged: (o) {
                    setState(() {
                      print( userProvider.refCode.text);
                      if(o.length==8){
                        userProvider.checkInvitation(isnav: false);
                      }
                    });

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
                  keyboardType: TextInputType.numberWithOptions(signed: true,),
                  submittedFieldDecoration:
                  _pinPutDecoration.copyWith(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  selectedFieldDecoration: _pinPutDecoration,
                  fieldsCount: 8),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(

                  style: ElevatedButton.styleFrom(
                      primary:   fiberchatBlue,
                      shape: StadiumBorder()),
                  onPressed:userProvider.refCode.text.length!=8?null: (){if( userProvider.refCode.text.length!=8){
                    Fiberchat.toast(
                      'Enter valid invitation code'
                    );
                  }else if(userProvider.refCode.text.length!=8){
                    Fiberchat.toast(
                        'Enter valid Ref code'
                    );
                  }else{
                    userProvider.checkInvitation();
                  }

                  }, child: Text('       N E X T      '),)

            ],
          ),
          Column(
            children: [
           Text('You are invited by:',style: TextStyle(
             color: fiberchatBlue,
             fontSize: 20
           ),),

    Consumer<UserProvider>(
    builder: (_, prov, __) =>  TextField(
      enabled: false,
                textAlign: TextAlign.center,

                controller: prov.invitationame,
              ))
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
