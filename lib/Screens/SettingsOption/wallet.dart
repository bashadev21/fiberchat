import 'package:flutter/material.dart';

class WalletView extends StatelessWidget {
  const WalletView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton.extended(
                onPressed: () {},
                icon: Icon(Icons.download),
                label: Text(
                  '   Stake   ',
                  style: TextStyle(color: Colors.white),
                )),
            FloatingActionButton.extended(
                onPressed: () {},
                icon: Icon(Icons.upload),
                label: Text(
                  '   Unstake   ',
                  style: TextStyle(color: Colors.white),
                )),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
            actions: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.upload_outlined,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      'Withdraw',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                  ],
                ),
              )
            ],
            leading: BackButton(
              color: Colors.black,
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            title: Text(
              'Wallet',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            )),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Balance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 6,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 24,
                          ),
                          Text(
                            '₹ 123456',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 9,
                          ),
                          Container(
                            height: 0,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.withOpacity(0.2)),
                child: Column(
                  children: [
                    ListTile(
                      trailing: Text('1222'),
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text('Stacked'),
                    ),
                    ListTile(
                      trailing: Text('1222'),
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.lock_clock_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text('Locked'),
                    ),
                    ListTile(
                      trailing: Text('1222'),
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.green.withOpacity(0.7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text('Available'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 9,
                          ),
                          Container(
                            height: 0,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'History',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 9,
                          ),
                          Container(
                            height: 0,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
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
                    return ListTile(
                      trailing: Column(
                        children: [
                          Text('1222'),
                          Text(
                            'Completed',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.green.withOpacity(0.7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text('Punk Panda reward'),
                      subtitle: Text('March 12 2020'),
                    );
                  })
            ],
          ),
        ));
  }
}