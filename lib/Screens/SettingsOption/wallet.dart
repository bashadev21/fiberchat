import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:flutter/material.dart';

class WalletView extends StatelessWidget {
  const WalletView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: Icon(Icons.redeem),
            label: Text(
              '   Redeem   ',
              style: TextStyle(color: Colors.white),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
            backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatDeepGreen
                : fiberchatWhite,
            title: Text(
              'Wallet',
              style: TextStyle(
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite
                    : fiberchatBlack,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            )),
        body: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'This Week',
                            style: TextStyle(
                              color: DESIGN_TYPE == Themetype.whatsapp
                                  ? fiberchatBlack
                                  : fiberchatWhite,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            '₹ 123456',
                            style: TextStyle(
                              color: DESIGN_TYPE == Themetype.whatsapp
                                  ? fiberchatBlack
                                  : fiberchatWhite,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Total Earnings',
                            style: TextStyle(
                              color: DESIGN_TYPE == Themetype.whatsapp
                                  ? fiberchatBlack
                                  : fiberchatWhite,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            '₹ 123456',
                            style: TextStyle(
                              color: DESIGN_TYPE == Themetype.whatsapp
                                  ? fiberchatBlack
                                  : fiberchatWhite,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (context, index) {
              return ExpansionTile(title: Text('12/12/2022'));
            })
          ],
        ));
  }
}
