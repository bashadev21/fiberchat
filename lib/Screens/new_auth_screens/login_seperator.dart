import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AuthSeperator extends StatelessWidget {
  const AuthSeperator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    ElevatedButton(
      onPressed: () {},
      child: Text('    Login    '),
      style: ElevatedButton.styleFrom(shape: StadiumBorder()),
    ),
    ElevatedButton(
      onPressed: () {
        userProvider.controller.animateToPage(1,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      },
      child: Text('  Sign Up  '),
      style: ElevatedButton.styleFrom(
          primary: Colors.orangeAccent,
          
          shape: StadiumBorder()),
    )
  ],
),
          Image.asset('assets/appicon/loginimg.jpeg',height: 100,)
        ],
      ),
    );
  }
}
