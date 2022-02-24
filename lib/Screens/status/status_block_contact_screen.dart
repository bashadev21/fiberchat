import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Configs/app_constants.dart';
import '../call_history/callhistory.dart';
import '../chat_screen/chat.dart';

class StatusBlockContactScreen extends StatefulWidget {
  const StatusBlockContactScreen({Key? key}) : super(key: key);

  @override
  _StatusBlockContactScreenState createState() =>
      _StatusBlockContactScreenState();
}

class _StatusBlockContactScreenState extends State<StatusBlockContactScreen> {
  List<String> _blockUserList = [];

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) {
      List<String>? _tempBlockList = value.getStringList(Dbkeys.statusBlock);
      if (_tempBlockList != null) {
        _blockUserList = _tempBlockList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Status Privacy"),
      ),
      body: Consumer<AvailableContactsProvider>(
        builder: (context, availableContacts, _child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
                Text(
                  "  Hide Status From ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
              ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(00),
                      itemCount: availableContacts
                          .joinedUserPhoneStringAsInServer.length,
                      itemBuilder: (context, idx) {
                        JoinedUserModel user = availableContacts
                            .joinedUserPhoneStringAsInServer
                            .elementAt(idx);
                        String phone = user.phone;
                        String name = user.name ?? user.phone;
                        return FutureBuilder(
                          future: availableContacts.getUserDoc(phone),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData && snapshot.data.exists) {
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                child: Row(children: [
                                  customCircleAvatar(
                                      url: snapshot.data[Dbkeys.photoUrl],
                                      radius: 22),
                               Expanded(child: Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(snapshot.data[Dbkeys.nickname],
                                         style: TextStyle(color: fiberchatBlack)),
                                     SizedBox(height: 3),
                                     Text(phone,
                                         style: TextStyle(color: fiberchatGrey)),
                                   ],
                                 ),
                               ))
                                ],),
                              );
                            }
                            return ListTile(
                              tileColor: Colors.white,
                              leading: customCircleAvatar(radius: 22),
                              title: Text(name,
                                  style: TextStyle(color: fiberchatBlack)),
                              subtitle: Text(phone,
                                  style: TextStyle(color: fiberchatGrey)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 22.0, vertical: 0.0),
                              onTap: () {
                                hidekeyboard(context);
                              },
                            );
                          },
                        );
                      },
                    ),
            ],
          );
        },
      ),
    );
  }
}
